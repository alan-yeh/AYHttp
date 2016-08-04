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

#pragma mark - Cookies
//@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *cookies;
//- (void)clearCookies;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@end

@interface AYHttp (Operation)
- (NSURLRequest *)parseRequest:(AYHttpRequest *)request;

- (AYPromise<AYHttpRequest *> *)executeRequest:(AYHttpRequest *)request;
- (AYPromise<AYHttpRequest *> *)downloadRequest:(AYHttpRequest *)request;

- (AYPromise<AYFile *> *)suspendRequest:(AYHttpRequest *)request;
- (AYPromise<AYHttpResponse *> *)resumeWithConfig:(AYFile *)configFile forRequest:(AYHttpRequest *_Nullable*_Nullable)request;
- (void)cancelRequest:(AYHttpRequest *)request;
@end

@protocol AYHttpDelegate <NSObject>
- (nullable AYPromise *)client:(AYHttp *)client hasReturn:(AYHttpResponse *)response;
- (void)reachabilityChanged:(AYNetworkStatus)status;/**< 检测网络状态 */
@end

NS_ASSUME_NONNULL_END