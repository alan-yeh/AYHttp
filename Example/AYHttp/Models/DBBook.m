//
//  DBBook.m
//  AYHttp
//
//  Created by PoiSon on 16/8/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "DBBook.h"

@implementation DBBook
- (instancetype)initWithJsonObject:(NSDictionary *)json{
    if (self = [super init]) {
        self.title = json[@"title"];
        self.summary = json[@"summary"];
        self.url = json[@"url"];
    }
    return self;
}
@end
