//
//  DetailsPlugin.m
//  AYHttp
//
//  Created by Alan Yeh on 2017/2/10.
//  Copyright © 2017年 Alan Yeh. All rights reserved.
//

#import "DetailsRouter.h"
#import "DetailsViewController.h"
#import <AYCategory/AYCategory.h>



@implementation DetailsRouter

+ (void)load{
    [AYHttpClient registerUrlPattern:@"example://api.yerl.cn/contact/:selector" forRouter:[DetailsRouter class]];
}

- (void)details{
    UIViewController *context = [self.request paramForKey:@"context"];
    
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithDetails:[self.request paramForKey:@"details"]];
    [detailsViewController setAy_onControllerResult:^(UIViewController *controller, NSUInteger resultCode, NSDictionary *data) {
        if (resultCode == 200) {
            self.response(data, nil);
        }else{
            self.response(nil, NSErrorWithUserInfo(data, @""));
        }
    }];
    
    id showType = [self.request paramForKey:@"showType"] ;
    if (showType == nil) {
        self.response(@{@"controller": detailsViewController}, nil);
    }else if ([showType isEqualToString:@"push"]) {
        [context.navigationController pushViewController:detailsViewController animated:YES];
    }else{
        [context presentViewController:detailsViewController animated:YES completion:nil];
    }
}

- (void)list{
    
}

- (void)main{
    
}


@end
