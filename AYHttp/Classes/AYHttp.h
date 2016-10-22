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

@interface AYHttp : NSObject
+ (instancetype)new __attribute__((unavailable("使用client来获取实例")));
- (instancetype)init __attribute__((unavailable("使用client来获取实例")));

@property (nonatomic, copy) NSURL *baseURL;

+ (instancetype)client;
@property (nonatomic, weak) id<AYHttpDelegate> delegate;
@property (nonatomic, assign, readonly) AYNetworkStatus currentNetworkStatus;

@property (nonatomic, assign) NSTimeInterval timeoutInterval; /**< default 10s */
@end

/**
 *  Headers and cookies are shared with all request
 */
@interface AYHttp (Header)
@property (readonly) NSDictionary<NSString *, NSString *> *headers;
- (void)clearHeaders;
- (NSString *)headerValueForKey:(NSString *)key;
- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;
- (void)setHeaderWithProperties:(NSDictionary<NSString *, NSString *> *)properties;


@property (readonly) NSDictionary<NSString *, id> *cookies;
- (void)clearCookies;
- (id)cookieValueForKey:(NSString *)key;
- (void)setCookieValue:(id)value forKey:(NSString *)key;
- (void)setCookieWithProperties:(NSDictionary<NSString *, id> *)properties;
@end

@interface AYHttp (Operation)
- (AYPromise<NSMutableURLRequest *> *)parseRequest:(AYHttpRequest *)request;

- (AYPromise<AYHttpRequest *> *)executeRequest:(AYHttpRequest *)request;
- (AYPromise<AYHttpRequest *> *)downloadRequest:(AYHttpRequest *)request;

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
