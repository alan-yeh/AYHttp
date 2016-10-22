//
//  AYHttpRequest.h
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
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

+ (instancetype)GET:(NSString *)URLString;
+ (instancetype)POST:(NSString *)URL;
+ (instancetype)PUT:(NSString *)URL;
+ (instancetype)DELETE:(NSString *)URL;
+ (instancetype)HEAD:(NSString *)URL;

+ (instancetype)GET:(NSString *)URL withParams:(nullable NSDictionary<NSString *, id> *)params;/**< URL can be NSURL, AYRestURL, NSString */
+ (instancetype)POST:(NSString *)URL withParams:(nullable NSDictionary<NSString *, id> *)params;/**< URL can be NSURL, AYRestURL, NSString */
+ (instancetype)PUT:(NSString *)URL withParams:(nullable NSDictionary<NSString *, id> *)params;/**< URL can be NSURL, AYRestURL, NSString */
+ (instancetype)DELETE:(NSString *)URL withParams:(nullable NSDictionary<NSString *, id> *)params;/**< URL can be NSURL, AYRestURL, NSString */
+ (instancetype)HEAD:(NSString *)URL withParams:(nullable NSDictionary<NSString *, id> *)params;/**< URL can be NSURL, AYRestURL, NSString */

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString andParams:(nullable NSDictionary<NSString *, id> *)params;

@property (nonatomic, readonly) NSDictionary<NSString *, id> *params;
- (void)putParam:(id)param forKey:(NSString *)key;
- (id)removeParamForKey:(NSString *)key;
- (id)paramForKey:(NSString *)key;

/** download progress callback*/
@property (nonatomic, copy) void (^downloadProgress)(NSProgress *);
- (void)setDownloadProgress:(void(^)(NSProgress *progress))progress;

/** upload progress callback*/
@property (nonatomic, copy) void (^uploadProgress)(NSProgress *);
- (void)setUploadProgress:(void (^)(NSProgress *progress))progress;

@end

/**
 *  Headers and cookies are just use for current request.
 */
@interface AYHttpRequest (Header)
@property (nonatomic, retain, readonly) NSMutableDictionary<NSString *, NSString *> *headers;
@property (nonatomic, retain, readonly) NSMutableDictionary<NSString *, NSString *> *cookies;

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)headerValueForKey:(NSString *)key;

- (void)setCookieValue:(NSString *)cookieValue forKey:(NSString *)key;
- (NSString *)cookieValueForKey:(NSString *)key;
@end


@interface AYHttpFileParam : NSObject
+ (instancetype)paramWithFile:(AYFile *)file;
+ (instancetype)paramWithData:(NSData *)data andName:(NSString *)fileName;
- (instancetype)initWithData:(NSData *)data andName:(NSString *)fileName;

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *filename;
@end

NS_ASSUME_NONNULL_END
