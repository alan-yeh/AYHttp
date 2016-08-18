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
#import "AYHttp_Private.h"

@interface AYHttp ()
@property (nonatomic, assign) AYNetworkStatus currentNetworkStatus;

@property (nonatomic, retain) AFHTTPSessionManager *session;

@property (nonatomic, retain) NSMutableDictionary<id, AFHTTPRequestSerializer *> *requestSerializers;
@end

@implementation AYHttp{
    NSMutableDictionary<NSString *, NSString *> *_headers;
}
- (instancetype)_init{
    return [super init];
}

+ (instancetype)client{
    static AYHttp *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AYHttp alloc] _init];
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

- (NSTimeInterval)timeoutInterval{
    return self.session.requestSerializer.timeoutInterval;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval{
    self.session.requestSerializer.timeoutInterval = timeoutInterval;
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
    return serializer;
}

@end

@implementation AYHttp (Cookies)
- (NSMutableDictionary<NSString *,NSString *> *)headers{
    return _headers ?: (_headers = [NSMutableDictionary new]);
}

- (void)clearHeaders{
    _headers = nil;
}

- (NSString *)headerValueForKey:(NSString *)key{
    return [_headers objectForKey:key];
}

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key{
    [self.headers setValue:value forKey:key];
}

- (void)setHeaderWithProperties:(NSDictionary<NSString *,NSString *> *)properties{
    [self.headers setValuesForKeysWithDictionary:properties];
}


- (NSDictionary<NSString *,NSString *> *)cookies{
    NSMutableDictionary *cookiePairs = [NSMutableDictionary new];
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookiePairs addEntriesFromDictionary:cookie.properties];
    }
    return cookiePairs.copy;
}

- (void)clearCookies{
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookieStore deleteCookie:cookie];
    }
}

- (id)cookieValueForKey:(NSString *)key{
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        id result = [cookie.properties objectForKey:key];
        if (result != nil) {
            return result;
        }
    }
    return nil;
}

- (void)setCookieValue:(id)value forKey:(NSString *)key{
    [self setCookieWithProperties:@{key: value}];
}

- (void)setCookieWithProperties:(NSDictionary<NSString *,id> *)properties{
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
@end

@implementation AYHttp (Operation)
- (NSSet<NSString *> *)multipartMethods{
    return [NSSet setWithObjects:@"POST", @"PUT", nil];
}

- (AYPromise<NSMutableURLRequest *> *)parseRequest:(AYHttpRequest *)request{
    NSParameterAssert(request.method.length);
    NSParameterAssert(request.URLString.length);
    
    NSString *URLString = [[NSURL URLWithString:request.URLString relativeToURL:self.baseURL] absoluteString];

    NSAssert(URLString.length, @"URLString, property of AYHttpRequest is not valid");
    
    return AYPromiseWith(^id{
        NSMutableURLRequest *urlRequest = nil;
        
        NSDictionary<NSString *, id> *params = request.params;
        
        NSMutableDictionary<NSString *, id> *parameters = [NSMutableDictionary new];
        NSMutableDictionary<NSString *, AYHttpFileParam *> *fileParams = [NSMutableDictionary new];
        
        for (NSString *key in params) {
            id param = [params objectForKey:key];
            if ([param isKindOfClass:[AYHttpFileParam class]]) {
                [fileParams setObject:param forKey:key];
            }else{
                [parameters setObject:param forKey:key];
            }
        }
        
        if (!(!(fileParams.count && ![self.multipartMethods containsObject:request.method]))) {
            return NSErrorMake(nil, @"request method %@ can not append multipart data", request.method);
        }
        
        NSError *error;
        if (fileParams.count) {
            urlRequest = [self.session.requestSerializer multipartFormRequestWithMethod:request.method
                                                                              URLString:URLString
                                                                             parameters:parameters
                                                              constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                                  for (NSString *key in fileParams) {
                                                                      AYHttpFileParam *param = fileParams[key];
                                                                      [formData appendPartWithFileData:param.data
                                                                                                  name:key
                                                                                              fileName:param.filename
                                                                                              mimeType:@"application/octet-stream"];
                                                                  }
                                                              }
                                                                                  error:&error];
        }else{
            urlRequest = [self.session.requestSerializer requestWithMethod:request.method
                                                                 URLString:URLString
                                                                parameters:request.params
                                                                     error:&error];
        }
        
        if (error) {
            return NSErrorMake(error, @"can not parse <AYHttpReqeust %p> to NSURLRequest", request);
        }
        
        // process cookie header
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *sharedCookies = cookieStorage.cookies;
        
        
        NSString *domain = [NSURL URLWithString:URLString].host;
        
        NSMutableArray<NSHTTPCookie *> *cookies = [NSMutableArray new];
        if (sharedCookies.count > 0) {
            for (NSHTTPCookie *cookie in cookies) {
                if ([cookie.domain isEqualToString:domain]) {
                    [cookies addObject:cookie];
                }
            }
        }
        
        if (request.cookies.count > 0) {
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:request.cookies];
            [cookies addObject:cookie];
        }
        
        
        
        //process other header
        NSDictionary<NSString *, NSString *> *headerProperties = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        
        NSMutableDictionary<NSString *, NSString *> *headers = [NSMutableDictionary new];
        [headers addEntriesFromDictionary:headerProperties];
        [headers addEntriesFromDictionary:self.headers];
        [headers addEntriesFromDictionary:request.headers];
        
        
        for (NSString *key in headers) {
            [urlRequest setValue:headers[key] forHTTPHeaderField:key];
        }
        
        return urlRequest;
    });
}


- (AYPromise<AYHttpRequest *> *)executeRequest:(AYHttpRequest *)request{
    return AYPromiseWith(^{
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
        serializer.timeoutInterval = self.timeoutInterval;
        self.session.requestSerializer = serializer;
        return request;
    }).then(NSInvocationMake(self, @selector(parseRequest:)))
    .thenPromise(^(NSMutableURLRequest *urlRequest, AYResolve resolve){
        request.task = [self.session dataTaskWithRequest:urlRequest
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
                                                                                                          andFile:nil];
                                           if ([self.delegate respondsToSelector:@selector(client:hasReturn:)]) {
                                               AYPromise *promise = [self.delegate client:self hasReturn:httpResponse];
                                               if (promise != nil) {
                                                   resolve(promise);
                                                   return;
                                               }
                                           }
                                           
                                           if (error) {
                                               resolve(NSErrorMake(error, @"访问网络失败"));
                                           }else{
                                               resolve(httpResponse);
                                           }
                                       }];
        [request.task resume];
    });
}

- (AYPromise<AYHttpRequest *> *)downloadRequest:(AYHttpRequest *)request{
    return AYPromiseWith(^{
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
        serializer.timeoutInterval = self.timeoutInterval;
        self.session.requestSerializer = serializer;
    }).then(^{
        return [self parseRequest:request];
    }).thenPromise(^(NSMutableURLRequest *URLRequest, AYResolve resolve){
        request.task = [self.session downloadTaskWithRequest:URLRequest
                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
                                                        if (request.downloadProgress) {
                                                            request.downloadProgress(downloadProgress);
                                                        }
                                                    }
                                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                     if (response.suggestedFilename.length > 0) {
                                                         return [NSURL fileURLWithPath:[[targetPath.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:response.suggestedFilename]];
                                                     }else{
                                                         return targetPath;
                                                     }
                                                 }
                                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                               
                                               AYHttpResponse *httpResponse = [[AYHttpResponse alloc] initWithRequest:request
                                                                                                              andData:nil
                                                                                                              andFile:[AYFile fileWithURL:filePath]];
                                               if ([self.delegate respondsToSelector:@selector(client:hasReturn:)]) {
                                                   AYPromise *promise = [self.delegate client:self hasReturn:httpResponse];
                                                   if (promise != nil) {
                                                       resolve(promise);
                                                       return;
                                                   }
                                               }
                                               
                                               if (error) {
                                                   resolve(NSErrorMake(error, @"访问网络失败"));
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
        AYHttpRequest *downloadRequest = [AYHttpRequest new];
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
                                                          if (error) {
                                                              resolve(NSErrorMake(error, @"下载失败"));
                                                          }else{
                                                              AYHttpResponse *response = [[AYHttpResponse alloc] init];
                                                              resolve(response);
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
            NSDictionary *config = [NSJSONSerialization JSONObjectWithData:resumeData options:kNilOptions error:nil];
            if (config) {
                AYFile *cacheFile = [[AYFile tmp] child:config[@"NSURLSessionResumeInfoTempFileName"]];
                [cacheFile delete];
            }
        }];
    }else{
        [task cancel];
    }
}
@end
