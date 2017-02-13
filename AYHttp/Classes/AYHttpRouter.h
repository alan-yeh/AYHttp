//
//  AYHttpRouter.h
//  Pods
//
//  Created by Alan Yeh on 2017/2/10.
//
//

#import <Foundation/Foundation.h>

@class AYHttpRequest;

NS_ASSUME_NONNULL_BEGIN
@interface AYHttpRouter : NSObject

@property (nonatomic, readonly) AYHttpRequest *request;
@property (nonatomic, readonly) void (^response)(NSDictionary *_Nullable result, NSError *_Nullable error);

@end
NS_ASSUME_NONNULL_END
