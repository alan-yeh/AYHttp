//
//  AYHttpRequest.m
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
//
//


#import <AYPromise/AYPromise.h>
#import <AYFile/AYFile.h>

#import "AYHttpRequest.h"
#import "AYHttp_Private.h"

@implementation AYHttpRequest{
    NSMutableDictionary<NSString *, NSString *> *_headers;
    NSMutableDictionary<NSString *, NSString *> *_cookies;
}

- (instancetype)init{
    if (self = [super init]) {
        self.encoding = NSUTF8StringEncoding;
    }
    return self;
}
#define CONSTRUCTOR(METHOD) \
+ (instancetype)METHOD:(NSString *)URLString withParams:(NSDictionary<NSString *,id> *)params{ \
    return [[self alloc] initWithMethod:@#METHOD URL:URLString andParams:params]; \
}
CONSTRUCTOR(GET)
CONSTRUCTOR(POST)
CONSTRUCTOR(PUT)
CONSTRUCTOR(DELETE)
#undef CONSTRUCTOR

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString andParams:(NSDictionary<NSString *,id> *)params{
    if (self = [self init]) {
        self.method = method;
        self.URLString = URLString;
        [self.parameters setDictionary:params];
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AFHttpRequest %p>:{\n    URL: %@\n    method: %@\n    params: %@\n    header: %@\n}", self, self.URLString, self.method, self.params, self.headers];
}

- (NSMutableDictionary<NSString *,id> *)parameters{
    return _parameters ? _parameters : (_parameters = [NSMutableDictionary new]);
}

- (NSDictionary<NSString *,id> *)params{
    return self.parameters.copy;
}

- (void)putParam:(id)param forKey:(NSString *)key{
    [self.parameters setObject:param forKey:key];
}

- (id)removeParamForKey:(NSString *)key{
    id param = self.parameters[key];
    [self.parameters removeObjectForKey:key];
    return param;
}

- (id)paramForKey:(NSString *)key{
    return self.parameters[key];
}

- (void)setMethod:(NSString *)method{
    _method = method.uppercaseString.copy;
}

- (instancetype)parseUrlParam{
    NSMutableArray<NSString *> *removedKeys = [NSMutableArray new];
    
    for (NSString *key in self.parameters) {
        NSString *replacement = [NSString stringWithFormat:@"{%@}", key];
        if ([self.URLString containsString:replacement]) {
            self.URLString = [self.URLString stringByReplacingOccurrencesOfString:replacement withString:[NSString stringWithFormat:@"%@", self.parameters[key]]];
            [removedKeys addObject:key];
        }
    }
    
    [self.parameters removeObjectsForKeys:removedKeys];
    return self;
}

- (instancetype)parseUrlParam:(NSDictionary<NSString *,id> *)urlParams{
    for (NSString *key in urlParams) {
        NSString *replacement = [NSString stringWithFormat:@"{%@}", key];
        if ([self.URLString containsString:replacement]) {
            self.URLString = [self.URLString stringByReplacingOccurrencesOfString:replacement withString:[NSString stringWithFormat:@"%@", urlParams[key]]];
        }
    }
    
    return self;
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
