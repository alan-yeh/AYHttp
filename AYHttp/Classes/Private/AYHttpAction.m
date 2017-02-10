//
//  AYHttpAction.m
//  Pods
//
//  Created by Alan Yeh on 2017/2/10.
//
//

#import "AYHttpAction.h"
#import <objc/runtime.h>
#import <AYCategory/AYCategory.h>

@implementation AYHttpAction
+ (NSArray<AYHttpAction *> *)actionsInRouter:(Class)router forUrlPattern:(NSString *)url{
    NSMutableArray *result = [NSMutableArray new];
    
    unsigned int methodCount;
    Method *methodList = class_copyMethodList(router, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i ++) {
        
        SEL action = method_getName(methodList[i]);
        
        NSMethodSignature *actionSignature = [router instanceMethodSignatureForSelector:action];
        if (strcmp(actionSignature.methodReturnType, "v") == 0 && actionSignature.numberOfArguments == 2) {
            AYHttpAction *newAction = [[AYHttpAction alloc] init];
            newAction.selector = action;
            newAction.router = router;
            newAction.urlPattern = [url stringByReplacingOccurrencesOfString:@":selector" withString:NSStringFromSelector(action)];
            [result addObject:newAction];
        }
    }
    
    free(methodList);
    
    return result;
}

- (NSString *)description{
    return NSStringWithFormat(@"<AYHttpAction %p>:{\n   urlPattern: %@\n   router: %@,\n   selector: %@ \n}", self, self.urlPattern, NSStringFromClass(self.router), NSStringFromSelector(self.selector));
}
@end
