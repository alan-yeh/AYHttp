//
//  AYHttpRequest.h
//  Pods
//
//  Created by PoiSon on 16/7/22.
//
//

#import <Foundation/Foundation.h>

@class AYFile;
@class AYHttpFileParam;

NS_ASSUME_NONNULL_BEGIN

@interface AYHttpRequest : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, assign) NSStringEncoding encoding;/**< default is UTF8Encoding */

+ (instancetype)GET:(NSString *)URLString withParams:(nullable NSDictionary<NSString *, id> *)params;
+ (instancetype)POST:(NSString *)URLString withParams:(nullable NSDictionary<NSString *, id> *)params;

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString andParams:(nullable NSDictionary<NSString *, id> *)params;

@property (nonatomic, readonly) NSDictionary<NSString *, id> *params;
- (void)putParam:(id)param forKey:(NSString *)key;
- (id)removeParamForKey:(NSString *)key;
- (id)paramForKey:(NSString *)key;

@property (nonatomic, copy) void (^progress)(NSProgress *);
- (void)setProgress:(void(^)(NSProgress *progress))progress;

@end

//@interface AYHttpRequest (Header)
//@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;
//@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *cookies;
//
//- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;
//- (void)headerValueForKey:(NSString *)key;
//
//- (void)setCookieValue:(NSString *)cookieValue forKey:(NSString *)key;
//- (void)cookieValueForKey:(NSString *)key;
//@end


@interface AYHttpFileParam : NSObject
+ (instancetype)paramWithFile:(AYFile *)file;
+ (instancetype)paramWithData:(NSData *)data andName:(NSString *)fileName;
- (instancetype)initWithData:(NSData *)data andName:(NSString *)fileName;

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *filename;
@end

NS_ASSUME_NONNULL_END