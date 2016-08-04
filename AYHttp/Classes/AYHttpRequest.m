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

@implementation AYHttpRequest
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
#undef CONSTRUCTOR

- (instancetype)initWithMethod:(NSString *)method URL:(NSString *)URLString andParams:(NSDictionary<NSString *,id> *)params{
    if (self = [self init]) {
        self.method = method;
        self.URLString = URLString;
        [self.parameters setDictionary:params];
    }
    return self;
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

@end

@implementation AYHttpFileParam
+ (instancetype)paramWithFile:(AYFile *)file{
    return [[self alloc] initWithData:file.data andName:file.name];
}

+ (instancetype)paramWithData:(NSData *)data andName:(NSString *)fileName{
    return [[self alloc] initWithData:data andName:fileName];
}

- (instancetype)initWithData:(NSData *)data andName:(NSString *)fileName{
    if (self = [super init]) {
        self.data = data;
        self.filename = fileName;
    }
    return self;
}

@end