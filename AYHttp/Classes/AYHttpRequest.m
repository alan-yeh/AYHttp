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
        
        _headers = [NSMutableDictionary new];
        _cookies = [NSMutableDictionary new];
    }
    return self;
}

//无参构造函数
#define CONSTRUCTOR(METHOD) \
+ (instancetype)METHOD:(NSString *)URLString{ \
    return [[self alloc] initWithMethod:@#METHOD URL:URLString]; \
}
CONSTRUCTOR(GET)
CONSTRUCTOR(POST)
CONSTRUCTOR(PUT)
CONSTRUCTOR(DELETE)
CONSTRUCTOR(HEAD)
#undef CONSTRUCTOR

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString{
    if (self = [self init]) {
        self.method = method;
        self.URLString = URLString;
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
        while ((key = va_arg(args, id)) != nil) {
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
        while ((key = va_arg(args, id)) != nil) {
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
        while ((key = va_arg(args, id)) != nil) {
            [_bodyParams removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}


@end

@implementation AYHttpRequest (Header)
#pragma - header
- (NSDictionary<NSString *,NSString *> *)headers{
    return [_headers copy];
}

- (AYHttpRequest * (^)(NSString *, NSString *))withHeader{
    return ^(NSString *key, NSString * value){
        [_headers setObject:value forKey:key];
        return self;
    };
}

- (AYHttpRequest * (^)(NSDictionary<NSString *, NSString *> *))withHeaders{
    return ^(NSDictionary<NSString *, NSString *> *params){
        [_headers setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttpRequest * (^)(NSString *, ...))removeHeader{
    return ^(NSString *keys, ...){
        [_headers removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while ((key = va_arg(args, id)) != nil) {
            [_headers removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
}

#pragma - cookie
- (NSDictionary<NSString *,NSString *> *)cookies{
    return [_cookies copy];
}

- (AYHttpRequest * (^)(NSString *, NSString *))withCookie{
    return ^(NSString *key, NSString *value){
        [_cookies setObject:value forKey:key];
        return self;
    };
}

- (AYHttpRequest * (^)(NSDictionary<NSString *, NSString *> *))withCookies{
    return ^(NSDictionary<NSString *, NSString *> *params){
        [_cookies setValuesForKeysWithDictionary:params];
        return self;
    };
}

- (AYHttpRequest * (^)(NSString *, ...))removeCookie{
    return ^(NSString *keys, ...){
        [_cookies removeObjectForKey:keys];
        
        va_list args;
        va_start(args, keys);
        id key = nil;
        while ((key = va_arg(args, id)) != nil) {
            [_cookies removeObjectForKey:key];
        }
        va_end(args);
        return self;
    };
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
