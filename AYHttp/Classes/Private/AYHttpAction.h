//
//  AYHttpAction.h
//  Pods
//
//  Created by Alan Yeh on 2017/2/10.
//
//

#import <Foundation/Foundation.h>

@interface AYHttpAction : NSObject
+ (NSArray<AYHttpAction *> *)actionsInRouter:(Class)router forUrlPattern:(NSString *)url;

@property (nonatomic, copy) NSString *urlPattern;
@property (nonatomic, assign) Class router;
@property (nonatomic, assign) SEL selector;
@end
