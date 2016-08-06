//
//  DBBook.h
//  AYHttp
//
//  Created by Alan Yeh on 16/8/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  豆瓣书
 */
@interface DBBook : NSObject
- (instancetype)initWithJsonObject:(NSDictionary *)json;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *summary;
@end
