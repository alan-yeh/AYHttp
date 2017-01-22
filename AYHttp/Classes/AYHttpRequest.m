//
//  AYHttpRequest.m
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
//
//


#import <AYPromise/AYPromise.h>
#import <AYFile/AYFile.h>
#import <AYCategory/AYCategory.h>
#import <AYQuery/AYQuery.h>

#import "AYHttpRequest.h"
#import "AYHttp_Private.h"


#define C_CONSTRUCTOR_IMP(METHOD) \
AYHttpRequest *AY##METHOD##Request(NSString *URLString) {\
    return [AYHttpRequest METHOD:URLString]; \
}

C_CONSTRUCTOR_IMP(GET)
C_CONSTRUCTOR_IMP(POST)
C_CONSTRUCTOR_IMP(PUT)
C_CONSTRUCTOR_IMP(DELETE)
C_CONSTRUCTOR_IMP(HEAD)

#undef C_CONSTRUCTOR

@implementation AYHttpRequest{
    NSMutableDictionary<NSString *, NSString *> *_headers;
    NSMutableDictionary<NSString *, NSString *> *_cookies;
    
    NSMutableDictionary<NSString *, id> *_queryParams;
    NSMutableDictionary<NSString *, id> *_pathParams;
    NSMutableDictionary<NSString *, id> *_bodyParams;
}

- (instancetype)init{
    if (self = [super init]) {
        self.encoding = NSUTF8StringEncoding;
        _queryParams = [NSMutableDictionary new];
        _pathParams = [NSMutableDictionary new];
        _bodyParams = [NSMutableDictionary new];
    }
    return self;
}

//无参构造函数
#define CONSTRUCTOR(METHOD) \
+ (instancetype)METHOD:(NSString *)URLString{ \
    return [[self alloc] initWithMethod:@#METHOD URL:URLString andParams:nil]; \
}
CONSTRUCTOR(GET)
CONSTRUCTOR(POST)
CONSTRUCTOR(PUT)
CONSTRUCTOR(DELETE)
CONSTRUCTOR(HEAD)
#undef CONSTRUCTOR

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString andParams:(NSDictionary<NSString *,id> *)params{
    if (self = [self init]) {
        self.method = method;
        self.URLString = URLString;
        [self.parameters setDictionary:params];
        
    }
    return self;
}

NSArray *AYSupportedHTTPMethods(){
    return @[@"GET", @"POST", @"PUT", @"DELETE", @"HEAD"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AFHttpRequest %p>:{\n    URL: %@\n    method: %@\n    path params: %@\n    query params: %@\n    body params: %@\n    header: %@\n}", self, self.URLString, self.method, self.pathParams, self.queryParams, self.bodyParams, self.headers];
}


- (void)setMethod:(NSString *)method{
    _method = method.uppercaseString;
    if (![AYSupportedHTTPMethods() containsObject:_method]) {
        @throw NSErrorMake(nil, @"%@ is not supported", _method);
    }
}


//- (NSString *)buildQueryParams:(NSDictionary<NSString *, id> *)params withEncoding:(NSStringEncoding)encoding{
//    NSMutableString *query = [NSMutableString new];
//    for (NSString *key in params) {
//        if (query.length) {
//            [query appendString:@"&"];
//        }
//        [query appendFormat:@"%@=%@", [key ay_URLEncodingWithEncoding:encoding], [[[params objectForKey:key] description] ay_URLEncodingWithEncoding:encoding]];
//    }
//    return query;
//}
//
///// 处理path param
//- (NSString *)parsePathParams:(NSString *)urlString params:(NSDictionary *)params{
//    if ([urlString rangeOfString:@"{"].location == NSNotFound) {
//        return urlString;
//    }
//    
//    __block NSString *result = urlString;
//    
//    params.query.each(^(AYPair *param){
//        NSString *replacement = NSStringWithFormat(@"{%@}", param.key);
//        if ([result containsString:replacement]) {
//            result = [result stringByReplacingOccurrencesOfString:replacement withString:[param.value description]];
//        }
//    });
//    
//    return result;
//}
//
//- (NSMutableURLRequest *)URLRequest{
//    NSString *URLString = [self parsePathParams:self.URLString params:self.pathParams];
//    
//    NSURL *URL = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
//    
//    URLString = [URL absoluteString];
//    NSAssert(URLString.length, @"URLString is not valid");
//    
//    
//    NSString *query = [self buildQueryParams:request.queryParams withEncoding:request.encoding];
//    if (query.length) {
//        URLString = NSStringWithFormat(URL.query ? @"%@&%@" : @"%@?%@", URLString, query);
//    }
//}
@end

@implementation AYHttpRequest (Params)
#pragma - query param
- (NSDictionary<NSString *,id> *)queryParams{
    return [_queryParams copy];
}

- (AYHttpRequest * (^)(NSString *, id))withQueryParam{
    return ^(NSString *key, id value){
        [_queryParams setObject:value forKey:key];
        return self;
    };
}

- (AYHttpRequest * (^)(NSDictionary<NSString *,id> *))withQueryParams{
    return ^(NSDictionary<NSString *,id> *params){
        [_queryParams setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttpRequest * (^)(NSString *, ...))removeQueryParam{
    return ^(NSString *keys, ...){
        [_queryParams removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while (key = va_arg(args, id)) {
            [_queryParams removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}

#pragma - path param
- (NSDictionary<NSString *,id> *)pathParams{
    return [_pathParams copy];
}

- (AYHttpRequest * (^)(NSString *, id))withPathParam{
    return ^(NSString *key, id value){
        [_pathParams setObject:value forKey:key];
        return self;
    };
}

- (AYHttpRequest * (^)(NSDictionary<NSString *,id> *))withPathParams{
    return ^(NSDictionary<NSString *,id> *params){
        [_pathParams setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttpRequest * (^)(NSString *, ...))removePathParam{
    return ^(NSString *keys, ...){
        [_pathParams removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while (key = va_arg(args, id)) {
            [_pathParams removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}

#pragma - body param
- (NSDictionary<NSString *,id> *)bodyParams{
    return [_bodyParams copy];
}

- (AYHttpRequest * (^)(NSString *, id))withBodyParam{
    return ^(NSString *key, id value){
        [_bodyParams setObject:value forKey:key];
        return self;
    };
}

- (AYHttpRequest * (^)(NSDictionary<NSString *,id> *))withBodyParams{
    return ^(NSDictionary<NSString *,id> *params){
        [_bodyParams setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttpRequest * (^)(NSString *, ...))removeBodyParam{
    return ^(NSString *keys, ...){
        [_bodyParams removeObjectForKey:keys];
        
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while (key = va_arg(args, id)) {
            [_bodyParams removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}


@end

@implementation AYHttpRequest (Header)
- (NSMutableDictionary<NSString *,NSString *> *)headers{
    return _headers ?: (_headers = [NSMutableDictionary new]);
}

- (NSMutableDictionary<NSString *,NSString *> *)cookies{
    return _cookies ?: (_cookies = [NSMutableDictionary new]);
}

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key{
    [self.headers setObject:value forKey:key];
}

- (NSString *)headerValueForKey:(NSString *)key{
    return [self.headers objectForKey:key];
}

- (void)setCookieValue:(NSString *)cookieValue forKey:(NSString *)key{
    [self.cookies setObject:cookieValue forKey:key];
}

- (NSString *)cookieValueForKey:(NSString *)key{
    return [self.cookies objectForKey:key];
}

@end

@implementation AYHttpFileParam
+ (instancetype)paramWithFile:(AYFile *)file{
    return [[self alloc] initWithData:file.data andName:file.name];
}

+ (instancetype)paramWithData:(NSData *)data andName:(NSString *)fileName{
    return [[self alloc] initWithData:data andName:fileName];
}

- (instancetype)initWithData:(NSData *)data andName:(NSString *)fileName{
    NSParameterAssert(data != nil && fileName.length > 0 && data.length >0);
    if (self = [super init]) {
        self.data = data;
        self.filename = fileName;
    }
    return self;
}

@end
