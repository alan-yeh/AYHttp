//
//  DBServices.m
//  AYHttp
//
//  Created by Alan Yeh on 16/8/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "DBServices.h"
#import <AYHttp/AYHttp.h>

@implementation DBServices
- (AYPromise<DBBook *> *)getBookByID:(NSString *)bookID{
    [AYHttp client].baseURL = [NSURL URLWithString:@"https://api.douban.com"];
    return [[AYHttp client] executeRequest:[AYHttpRequest GET:@"v2/book/{bookID}" withParams:@{
                                                                                               @"bookID": bookID
                                                                                               }].restful]
    .then(^(AYHttpResponse *response){
        return [[DBBook alloc] initWithJsonObject:response.responseJson];
    });
}

@end
