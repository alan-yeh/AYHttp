//
//  AYHttp.m
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
//
//

#import "AYHttp.h"
#import <AFNetworking/AFNetworking.h>
#import <AYFile/AYFile.h>
#import <AYCategory/AYCategory.h>
#import <AYQuery/AYQuery.h>
#import "AYHttp_Private.h"
#import "AYHttpAction.h"

NSString const *AYHttpReachabilityChangedNotification = @"AYHttpReachabilityChangedNotification";
NSString const *AYHttpErrorResponseKey = @"AYHttpErrorResponseKey";

@interface AYHttp ()
@property (nonatomic, assign) AYNetworkStatus currentNetworkStatus;

@property (nonatomic, retain) AFHTTPSessionManager *session;

@property (nonatomic, retain) NSMutableDictionary<id, AFHTTPRequestSerializer *> *requestSerializers;

@property (nonatomic, retain) NSMutableDictionary *staticRoute;
@end

@implementation AYHttp{
    NSMutableDictionary *_cookies;
    NSMutableDictionary *_headers;
}
- (instancetype)_init{
    if (self = [super init]) {
        _cookies = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)client{
    static AYHttp *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AYHttp alloc] _init];
        _instance.timeoutInterval = 10;
        _instance.session = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        _instance.session.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _instance.session.securityPolicy.allowInvalidCertificates = YES;
        _instance.session.securityPolicy.validatesDomainName = NO;
        _instance.session.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _instance;
}

+ (void)load{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [AYHttp client].currentNetworkStatus = (AYNetworkStatus)status;
        if ([[AYHttp client].delegate respondsToSelector:@selector(reachabilityChanged:)]) {
            [[AYHttp client].delegate reachabilityChanged:[AYHttp client].currentNetworkStatus];
        }
    }];
}

- (NSURL *)baseURL{
    return self.session.baseURL;
}

- (void)setBaseURL:(NSURL *)url{
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    self.session.baseURL = url;
}

- (AFHTTPRequestSerializer *)serializerWithEncoding:(NSStringEncoding)encoding{
    static NSMutableDictionary *serializer_encoding_mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer_encoding_mapping = [NSMutableDictionary new];
    });
    
    AFHTTPRequestSerializer *serializer = [serializer_encoding_mapping objectForKey:@(encoding)];
    if (serializer == nil) {
        serializer = [AFHTTPRequestSerializer serializer];
        serializer.stringEncoding = encoding;
        [serializer_encoding_mapping setObject:serializer forKey:@(encoding)];
    }
    
    serializer.timeoutInterval = self.timeoutInterval;
    return serializer;
}

- (NSMutableDictionary *)staticRoute{
    return _staticRoute ?: (_staticRoute = [NSMutableDictionary new]);
}
@end

@implementation AYHttp (Cookies)
#pragma - header
- (NSDictionary<NSString *,NSString *> *)headers{
    return [_headers copy];
}

- (AYHttp * (^)(NSString *, id))withHeader{
    return ^(NSString *key, id value){
        [_headers setObject:value forKey:key];
        return self;
    };
}

- (AYHttp * (^)(NSDictionary<NSString *,id> *))withHeaders{
    return ^(NSDictionary<NSString *,id> *params){
        [_headers setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttp * (^)(NSString *, ...))removeHeader{
    return ^(NSString *keys, ...){
        [_headers removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while ((key = va_arg(args, id)) != nil) {
            [_headers removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}

#pragma - cookie
- (NSDictionary<NSString *,NSString *> *)cookies{
    return [_cookies copy];
}

- (AYHttp * (^)(NSString *, id))withCookie{
    return ^(NSString *key, id value){
        [_cookies setObject:value forKey:key];
        return self;
    };
}

- (AYHttp * (^)(NSDictionary<NSString *,id> *))withCookies{
    return ^(NSDictionary<NSString *,id> *params){
        [_cookies setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttp * (^)(NSString *, ...))removeCookie{
    return ^(NSString *keys, ...){
        [_cookies removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while ((key = va_arg(args, id)) != nil) {
            [_cookies removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}@end

@implementation AYHttp (Operation)
- (NSSet<NSString *> *)multipartMethods{
    return [NSSet setWithObjects:@"POST", @"PUT", nil];
}

- (NSString *)buildQueryParams:(NSDictionary<NSString *, id> *)params withEncoding:(NSStringEncoding)encoding{
    NSMutableString *query = [NSMutableString new];
    for (NSString *key in params) {
        if (query.length) {
            [query appendString:@"&"];
        }
        [query appendFormat:@"%@=%@", [key ay_URLEncodingWithEncoding:encoding], [[[params objectForKey:key] description] ay_URLEncodingWithEncoding:encoding]];
    }
    return query;
}

/// 处理path param
- (NSString *)parsePathParams:(NSString *)urlString params:(NSDictionary *)params{
    if ([urlString rangeOfString:@"{"].location == NSNotFound) {
        return urlString;
    }
    
    __block NSString *result = urlString;
    
    params.query.each(^(AYPair *param){
        NSString *replacement = NSStringWithFormat(@"{%@}", param.key);
        if ([result containsString:replacement]) {
            result = [result stringByReplacingOccurrencesOfString:replacement withString:[param.value description]];
        }
    });
    
    return result;
}

- (AYPromise<NSMutableURLRequest *> *)parseRequest:(AYHttpRequest *)request{
    NSParameterAssert(request.method.length);
    NSParameterAssert(request.URLString.length);

    NSString *URLString = [self parsePathParams:request.URLString params:request.pathParams];

    NSURL *URL = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
    URLString = [URL absoluteString];
    NSAssert(URLString.length, @"URLString is not valid");
    
    
    NSString *query = [self buildQueryParams:request.queryParams withEncoding:request.encoding];
    if (query.length) {
        URLString = NSStringWithFormat(URL.query ? @"%@&%@" : @"%@?%@", URLString, query);
    }
    
    return AYPromiseWith(^id{
        NSMutableURLRequest *urlRequest = nil;
        
        //找出上传文件的参数
        AYQueryable *fileParams = request.bodyParams.query.findAll(^(AYPair *item){
            return [item.value isKindOfClass:[AYHttpFileParam class]];
        });
        
        //排除上传文件的参数
        AYQueryable *parameters = request.bodyParams.query.exclude(fileParams);
        
        if (!(!(fileParams.count && ![self.multipartMethods containsObject:request.method]))) {
            return NSErrorMake(nil, @"request method %@ can not append multipart data", request.method);
        }
        
        NSError *error;
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];

        if (![serializer.HTTPMethodsEncodingParametersInURI containsObject:[request.method uppercaseString]]) {
            if (fileParams.count) {
                urlRequest = [serializer multipartFormRequestWithMethod:request.method
                                                              URLString:URLString
                                                             parameters:parameters.toDictionary(nil)
                                              constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                  fileParams.each(^(AYPair *item){
                                                      AYHttpFileParam *param = item.value;
                                                      [formData appendPartWithFileData:param.data
                                                                                  name:item.key
                                                                              fileName:param.filename
                                                                              mimeType:@"application/octet-stream"];
                                                  });
                                              }
                                                                  error:&error];
            }else{
                urlRequest = [serializer requestWithMethod:request.method
                                                 URLString:URLString
                                                parameters:parameters.toDictionary(nil)
                                                     error:&error];
            }
        }else{
            urlRequest = [serializer requestWithMethod:request.method
                                             URLString:URLString
                                            parameters:nil
                                                 error:&error];
        }
        
        
        if (error) {
            return NSErrorMake(error, @"can not parse <AYHttpReqeust %p> to NSURLRequest", request);
        }
    
        
        NSString *domain = [NSURL URLWithString:URLString].host;
        // process cookie header
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        
        NSArray<NSHTTPCookie *> *cookies = cookieStorage.cookies.query
        .findAll(^(NSHTTPCookie *cookie){
            return [cookie.domain isEqualToString:domain];
        })
        .include([NSHTTPCookie cookieWithProperties:request.cookies])
        .toArray();
        
        //process other header
        NSDictionary<NSString *, NSString *> *headerProperties = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        
        headerProperties.query.include(self.headers).include(request.headers).each(^(AYPair *item){
            [urlRequest setValue:item.value forHTTPHeaderField:item.key];
        });
        
        return urlRequest;
    });
}


- (AYPromise<AYHttpRequest *> *)executeRequest:(AYHttpRequest *)request{
    return [self parseRequest:request]
    .thenPromise(^(NSURLRequest *URLRequest, AYResolve resolve){
        AYHttpAction *action = [self.staticRoute objectForKey:URLRequest.URL.absoluteString];
        if (action) {
            AYHttpRouter *router = [[action.router alloc] init];
            router.request = request;
            router.response = ^(NSDictionary *result, NSError *error){
                if (error) {
                    resolve(error);
                }else{
                    AYHttpResponse *httpResponse = [[AYHttpResponse alloc] initWithRequest:request
                                                                                   andData:nil
                                                                                   andFile:nil
                                                                                   andJson:result];
                    resolve(httpResponse);
                }
            };
            SuppressPerformSelectorLeakWarning([router performSelector:action.selector]);
        }else{
            AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
            self.session.requestSerializer = serializer;
            
            request.task = [self.session dataTaskWithRequest:URLRequest
                                              uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                                                  if (request.uploadProgress) {
                                                      request.uploadProgress(uploadProgress);
                                                  }
                                              }
                                            downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                                                if (request.downloadProgress) {
                                                    request.downloadProgress(downloadProgress);
                                                }
                                            }
                                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                               AYHttpResponse *httpResponse = [[AYHttpResponse alloc] initWithRequest:request
                                                                                                              andData:responseObject
                                                                                                              andFile:nil
                                                                                                              andJson:nil];
                                               if ([self.delegate respondsToSelector:@selector(client:hasReturn:)]) {
                                                   AYPromise *promise = [self.delegate client:self hasReturn:httpResponse];
                                                   if (promise != nil) {
                                                       resolve(promise);
                                                       return;
                                                   }
                                               }
                                               
                                               if (error) {
                                                   resolve(NSErrorWithUserInfo(@{AYHttpErrorResponseKey: httpResponse}, @"网络请求失败"));
                                               }else{
                                                   resolve(httpResponse);
                                               }
                                           }];
            [request.task resume];
        }
    });
}

- (AYPromise<AYHttpRequest *> *)downloadRequest:(AYHttpRequest *)request{
    return [self parseRequest:request]
    .thenPromise(^(NSURLRequest *URLRequest, AYResolve resolve){
        
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
        self.session.requestSerializer = serializer;
        
        
        request.task = [self.session downloadTaskWithRequest:URLRequest
                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
                                                        if (request.downloadProgress) {
                                                            request.downloadProgress(downloadProgress);
                                                        }
                                                    }
                                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                     if (response.suggestedFilename.length > 0) {
                                                         NSMutableString *suggestedFilename = [NSMutableString stringWithString:response.suggestedFilename];
                                                         [suggestedFilename replaceOccurrencesOfString:@"+"
                                                                                 withString:@" "
                                                                                    options:NSLiteralSearch
                                                                                      range:NSMakeRange(0, [suggestedFilename length])];
                                                         NSString *decodedFilename = [suggestedFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                                         return [NSURL fileURLWithPath:[[targetPath.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:decodedFilename]];
                                                     }else{
                                                         return targetPath;
                                                     }
                                                 }
                                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                               
                                               AYHttpResponse *httpResponse = [[AYHttpResponse alloc] initWithRequest:request
                                                                                                              andData:nil
                                                                                                              andFile:[AYFile fileWithURL:filePath]
                                                                                                              andJson:nil];
                                               if ([self.delegate respondsToSelector:@selector(client:hasReturn:)]) {
                                                   AYPromise *promise = [self.delegate client:self hasReturn:httpResponse];
                                                   if (promise != nil) {
                                                       resolve(promise);
                                                       return;
                                                   }
                                               }
                                               
                                               if (error) {
                                                   resolve(NSErrorWithUserInfo(@{AYHttpErrorResponseKey: httpResponse}, @"网络请求失败"));
                                               }else{
                                                   resolve(httpResponse);
                                               }
                                           }];
        [request.task resume];
    });
}

- (AYPromise<AYFile *> *)suspendDownloadRequest:(AYHttpRequest *)request{
    return AYPromiseWithResolve(^(AYResolve  _Nonnull resolve) {
        NSURLSessionDownloadTask *task = request.task;
        if (![task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            resolve(NSErrorMake(nil, @"Only download request can suspend."));
        }
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            resolve([[AYFile tmp] write:resumeData withName:[[NSUUID UUID].UUIDString stringByAppendingString:@".ayhttp.cfg"]]);
        }];
    });
}

- (AYPromise<AYHttpResponse *> *)resumeDownloadRequest:(AYHttpRequest *__autoreleasing  _Nullable *)request withConfig:(AYFile *)configFile{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AYPromise<AYHttpResponse *> *promise = AYPromiseAsyncWithResolve(^(AYResolve  _Nonnull resolve) {
        __block AYHttpRequest *downloadRequest = [AYHttpRequest new];
        if (request) {
            *request = downloadRequest;
        }
        downloadRequest.task = [self.session downloadTaskWithResumeData:configFile.data
                                                               progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                   if (downloadRequest.downloadProgress) {
                                                                       downloadRequest.downloadProgress(downloadProgress);
                                                                   }
                                                               }
                                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                return targetPath;
                                                            }
                                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                          AYHttpResponse *httpResponse = [[AYHttpResponse alloc] initWithRequest:downloadRequest
                                                                                                                         andData:nil
                                                                                                                         andFile:[AYFile fileWithURL:filePath]
                                                                                                                         andJson:nil];
                                                          if (error) {
                                                              resolve(NSErrorWithUserInfo(@{AYHttpErrorResponseKey: httpResponse,
                                                                                            AYPromiseInternalErrorsKey: error}, @"下载失败"));
                                                          }else{
                                                              resolve(httpResponse);
                                                          }
                                                      }];
        [downloadRequest.task resume];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return promise;
}

- (void)cancelRequest:(AYHttpRequest *)request{
    NSURLSessionDownloadTask *task = request.task;
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        //remove download cache
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData.length) {
                NSDictionary *config = [NSJSONSerialization JSONObjectWithData:resumeData options:kNilOptions error:nil];
                if (config) {
                    AYFile *cacheFile = [[AYFile tmp] child:config[@"NSURLSessionResumeInfoTempFileName"]];
                    [cacheFile delete];
                }
            }
        }];
    }else{
        [task cancel];
    }
}
@end

@implementation AYHttp (StaticRoute)
- (void)registerUrlPattern:(NSString *)url forRouter:(Class)router{
    NSArray *actions = [AYHttpAction actionsInRouter:router forUrlPattern:url];
    
    for (AYHttpAction *action in actions) {
        id exist = [self.staticRoute objectForKey:action.urlPattern];
        if (exist) {
            NSAssert(NO, @"url pattern 冲突: \n1. %@\n2. %@", exist, action);
        }
        [self.staticRoute setObject:action forKey:action.urlPattern];
    }
}

@end
