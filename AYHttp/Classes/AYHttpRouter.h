//
//  AYHttpRouter.h
//  Pods
//
//  Created by Alan Yeh on 2017/2/10.
//
//

#import <Foundation/Foundation.h>

@class AYHttpRequest;

@interface AYHttpRouter : NSObject

@property (nonatomic, readonly) AYHttpRequest *request;
@property (nonatomic, readonly) void (^response)(NSDictionary *_Nullable result, NSError *_Nullable error);

@end
