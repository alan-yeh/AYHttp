//
//  AYHttp.m
//  Pods
//
//  Created by PoiSon on 16/7/22.
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

@implementation AYHttp
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
        _instance.session.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _instance;
}

+ (void)load{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [AYHttp client].currentNetworkStatus = status;
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

@implementation AYHttp (Operation)

- (AYPromise<NSMutableURLRequest *> *)parseRequest:(AYHttpRequest *)request{
    return AYPromiseWith(^id{
        NSError *error;
        NSMutableURLRequest *urlRequest = [self.session.requestSerializer requestWithMethod:request.method
                                                URLString:request.URLString
                                               parameters:request.params
                                                    error:&error];
        if (error) {
            return NSErrorMake(error, @"can not parse <AYHttpReqeust %p> to NSURLRequest", request);
        }else{
            return urlRequest;
        }
    });
}


- (AYPromise<AYHttpRequest *> *)executeRequest:(AYHttpRequest *)request{
    return AYPromiseWithResolve(^(PSResolve  _Nonnull resolve) {
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
        
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
        serializer.timeoutInterval = self.timeoutInterval;
        self.session.requestSerializer = serializer;
        
        if (fileParams.count < 1) {
            request.task = [self.session dataTaskWithHTTPMethod:request.method
                                                      URLString:request.URLString
                                                     parameters:parameters
                                                 uploadProgress:nil
                                               downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                                                   if (request.progress) {
                                                       request.progress(downloadProgress);
                                                   }
                                               }
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                            request.task = task;
                                                            resolve([[AYHttpResponse alloc] initWithRequest:request
                                                                                                    andData:responseObject
                                                                                                    andFile:nil]);
                                                        }
                                                        failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                                            resolve(NSErrorMake(error, @"访问网络失败"));
                                                        }];
            [request.task resume];
            
        }else{
            NSAssert([request.method isEqualToString:@"POST"], @"only POST method can upload");
            self.session.requestSerializer = [AFHTTPRequestSerializer serializer];
            request.task = [self.session POST:request.URLString
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
                                     progress:^(NSProgress * _Nonnull downloadProgress) {
                                         if (request.progress) {
                                             request.progress(downloadProgress);
                                         }
                                     }
                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                          request.task = task;
                                          resolve([[AYHttpResponse alloc] initWithRequest:request andData:responseObject andFile:nil]);
                                      }
                                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                          resolve(NSErrorMake(error, @"访问网络失败"));
                                      }];
        }
        
    });
}

- (AYPromise<AYHttpRequest *> *)downloadRequest:(AYHttpRequest *)request{
    return AYPromiseWith(^{
        AFHTTPRequestSerializer *serializer = [self serializerWithEncoding:request.encoding];
        serializer.timeoutInterval = self.timeoutInterval;
        self.session.requestSerializer = serializer;
    }).then(^{
        return [self parseRequest:request];
    }).thenPromise(^(NSMutableURLRequest *URLRequest, PSResolve resolve){
        request.task = [self.session downloadTaskWithRequest:URLRequest
                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
                                                        if (request.progress) {
                                                            request.progress(downloadProgress);
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
                                               if (error) {
                                                   resolve(NSErrorMake(error, @"访问网络失败"));
                                               }else{
                                                   resolve([[AYHttpResponse alloc] initWithRequest:request andData:nil andFile:filePath]);
                                               }
                                           }];
        [request.task resume];
    });
}

- (AYPromise<AYFile *> *)suspendRequest:(AYHttpRequest *)request{
    return AYPromiseWithResolve(^(PSResolve  _Nonnull resolve) {
        NSURLSessionDownloadTask *task = request.task;
        if (![task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            resolve(NSErrorMake(nil, @"Only download request can suspend."));
        }
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            resolve([[AYFile tmp] write:resumeData withName:[[NSUUID UUID].UUIDString stringByAppendingString:@".ayhttp.cfg"]]);
        }];
    });
}

- (AYPromise<AYHttpResponse *> *)resumeWithConfig:(AYFile *)configFile forRequest:(AYHttpRequest *__autoreleasing *)request{
    return AYPromiseWithResolve(^(PSResolve  _Nonnull resolve) {
        AYHttpRequest *downloadRequest = [AYHttpRequest new];
        if (request) {
            *request = downloadRequest;
        }
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithResumeData:configFile.data
                                                                         progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                             if (downloadRequest.progress) {
                                                                                 downloadRequest.progress(downloadProgress);
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
    });
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
