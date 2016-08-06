//
//  DBServices.h
//  AYHttp
//
//  Created by PoiSon on 16/8/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AYPromise/AYPromise.h>
#import "DBBook.h"

@interface DBServices : NSObject
/**
 *  通过bookID获取豆瓣书的详情
 */
- (AYPromise<DBBook *> *)getBookByID:(NSString *)bookID;
@end
