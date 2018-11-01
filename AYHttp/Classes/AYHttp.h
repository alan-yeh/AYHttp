//
//  AYHttp.h
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
//
//

#import <Foundation/Foundation.h>
#import <AYPromise/AYPromise.h>
#import <AYHttp/AYHttpRequest.h>
#import <AYHttp/AYHttpResponse.h>


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString const *AYHttpReachabilityChangedNotification;
FOUNDATION_EXPORT NSString const *AYHttpErrorResponseKey;

@protocol AYHttpDelegate;

typedef NS_ENUM(NSInteger, AYNetworkStatus) {
    AYNetworkStatusUnknow = -1,            /** 未知网络状态 */
    AYNetworkStatusNotReachable = 0,       /** 无网络 */
    AYNetworkStatusReachableViaWWAN = 1,   /** 移动网络 */
    AYNetworkStatusReachableViaWiFi = 2    /** Wifi网络 */
};

#define AYHttpClient AYHttp.client
@interface AYHttp : NSObject
+ (instancetype)new __attribute__((unavailable("使用client来获取实例")));
- (instancetype)init __attribute__((unavailable("使用client来获取实例")));

@property (nonatomic, copy) NSURL *baseURL;

+ (instancetype)client;
@property (nonatomic, weak) id<AYHttpDelegate> delegate;
@property (nonatomic, assign, readonly) AYNetworkStatus currentNetworkStatus;

@property (nonatomic, assign) NSTimeInterval timeoutInterval; /**< default 10s */

@property (nonatomic, readonly) AYHttp *(^withQueryParam)(NSString *key, _Nullable id value); /**< add shared query param. send with every request. */
@end

/**
 *  Headers and cookies are shared with all request
 */
@interface AYHttp (Header)
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, readonly) AYHttp *(^removeHeader)(NSString *key, ...);
@property (nonatomic, readonly) AYHttp *(^withHeader)(NSString *key, NSString *value);
@property (nonatomic, readonly) AYHttp *(^withHeaders)(NSDictionary<NSString *, NSString *> *headers);


@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *cookies;
@property (nonatomic, readonly) AYHttp *(^removeCookie)(NSString *key, ...);
@property (nonatomic, readonly) AYHttp *(^withCookie)(NSString *key, NSString *value);
@property (nonatomic, readonly) AYHttp *(^withCookies)(NSDictionary<NSString *, NSString *> *cookies);
@end

@interface AYHttp (Operation)
- (AYPromise<NSURLRequest *> *)parseRequest:(AYHttpRequest *)request;

- (AYPromise<AYHttpResponse *> *)executeRequest:(AYHttpRequest *)request;
- (AYPromise<AYHttpResponse *> *)downloadRequest:(AYHttpRequest *)request;

- (void)cancelRequest:(AYHttpRequest *)request;

// Suspend download request, then return download config file
// use config file to resume the download request
- (AYPromise<AYFile *> *)suspendDownloadRequest:(AYHttpRequest *)request;
- (AYPromise<AYHttpResponse *> *)resumeDownloadRequest:(AYHttpRequest *_Nullable*_Nullable)request withConfig:(AYFile *)configFile;
@end

@protocol AYHttpDelegate <NSObject>
- (nullable AYPromise *)client:(AYHttp *)client hasReturn:(AYHttpResponse *)response;
- (void)reachabilityChanged:(AYNetworkStatus)status;/**< 检测网络状态 */
@end

NS_ASSUME_NONNULL_END
