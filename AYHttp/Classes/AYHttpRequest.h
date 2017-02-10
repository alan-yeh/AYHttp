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
@class AYHttpRequest;

NS_ASSUME_NONNULL_BEGIN

#define C_CONSTRUCTOR(METHOD) \
AYHttpRequest *AY##METHOD##Request(NSString *URLString);

C_CONSTRUCTOR(GET)
C_CONSTRUCTOR(POST)
C_CONSTRUCTOR(PUT)
C_CONSTRUCTOR(DELETE)
C_CONSTRUCTOR(HEAD)

#undef C_CONSTRUCTOR

@interface AYHttpRequest : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, assign) NSStringEncoding encoding;/**< default is UTF8Encoding */

+ (instancetype)GET:(NSString *)URLString;
+ (instancetype)POST:(NSString *)URLString;
+ (instancetype)PUT:(NSString *)URLString;
+ (instancetype)DELETE:(NSString *)URLString;
+ (instancetype)HEAD:(NSString *)URLString;

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString;

/** download progress callback*/
@property (nonatomic, copy) void (^downloadProgress)(NSProgress *);
- (void)setDownloadProgress:(void(^)(NSProgress *progress))progress;

/** upload progress callback*/
@property (nonatomic, copy) void (^uploadProgress)(NSProgress *);
- (void)setUploadProgress:(void (^)(NSProgress *progress))progress;
@end


/**
 *  处理参数
 */
@interface AYHttpRequest (Params)
// 参数拼接在URL
@property (nonatomic, readonly) NSDictionary<NSString *, id> *queryParams;
@property (nonatomic, readonly) AYHttpRequest *(^removeQueryParam)(NSString *key, ...);
@property (nonatomic, readonly) AYHttpRequest *(^withQueryParam)(NSString *key, id value);
@property (nonatomic, readonly) AYHttpRequest *(^withQueryParams)(NSDictionary<NSString *, id> *params);

// RESTful url 传参，使用{}进行占位
@property (nonatomic, readonly) NSDictionary<NSString *, id> *pathParams;
@property (nonatomic, readonly) AYHttpRequest *(^removePathParam)(NSString *key, ...);
@property (nonatomic, readonly) AYHttpRequest *(^withPathParam)(NSString *key, id value);
@property (nonatomic, readonly) AYHttpRequest *(^withPathParams)(NSDictionary<NSString *, id> *params);

// 参数拼接在Body
@property (nonatomic, readonly) NSDictionary<NSString *, id> *bodyParams;
@property (nonatomic, readonly) AYHttpRequest *(^removeBodyParam)(NSString *key, ...);
@property (nonatomic, readonly) AYHttpRequest *(^withBodyParam)(NSString *key, id value);
@property (nonatomic, readonly) AYHttpRequest *(^withBodyParams)(NSDictionary<NSString *, id> *params);

/**
 * 获取参数
 * 顺序：
 * Query -> Body -> Path
 */
- (id)paramForKey:(NSString *)key;
@end



/**
 *  处理Header
 */
@interface AYHttpRequest (Header)
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, readonly) AYHttpRequest *(^removeHeader)(NSString *key, ...);
@property (nonatomic, readonly) AYHttpRequest *(^withHeader)(NSString *key, NSString *value);
@property (nonatomic, readonly) AYHttpRequest *(^withHeaders)(NSDictionary<NSString *, NSString *> *headers);


@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *cookies;
@property (nonatomic, readonly) AYHttpRequest *(^removeCookie)(NSString *key, ...);
@property (nonatomic, readonly) AYHttpRequest *(^withCookie)(NSString *key, NSString *value);
@property (nonatomic, readonly) AYHttpRequest *(^withCookies)(NSDictionary<NSString *, NSString *> *cookies);
@end


@interface AYHttpFileParam : NSObject
+ (instancetype)paramWithFile:(AYFile *)file;
+ (instancetype)paramWithData:(NSData *)data andName:(NSString *)fileName;
- (instancetype)initWithData:(NSData *)data andName:(NSString *)fileName;

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *filename;
@end

NS_ASSUME_NONNULL_END
