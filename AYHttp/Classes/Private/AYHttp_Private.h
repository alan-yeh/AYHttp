//
//  AYHttpRequest_Private.h
//  Pods
//
//  Created by PoiSon on 16/7/25.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AYHttpRequest.h"
#import "AYHttpResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYHttpRequest ()
@property (nonatomic, retain) NSMutableDictionary<NSString *, id> *parameters;
@property (nonatomic, retain) __kindof NSURLSessionDataTask *task;
@end

@interface AYHttpResponse ()
@property (nonatomic, retain) AYHttpRequest *request;

- (instancetype)initWithRequest:(AYHttpRequest *)request andData:(NSData *)responseData andFile:(NSURL *)responseFile;
@end

@interface AFHTTPSessionManager ()
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

NS_ASSUME_NONNULL_END