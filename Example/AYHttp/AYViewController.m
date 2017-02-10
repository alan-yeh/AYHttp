//
//  AYViewController.m
//  AYHttp
//
//  Created by Alan Yeh on 07/22/2016.
//  Copyright (c) 2016 Alan Yeh. All rights reserved.
//

#import "AYViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "DBServices.h"
#import <AYHttp/AYHttp.h>

@interface AYViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvSummary;

@end

@implementation AYViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    AYPromise *req1 = [AYHttpClient executeRequest:AYPOSTRequest(@"example://api.yerl.cn/contact/main")
                       //     .withBodyParam(@"details", book)
                       .withBodyParam(@"context", self)];
    
    AYPromise *req2 = [AYHttpClient executeRequest:AYPOSTRequest(@"example://api.yerl.cn/message/main")
                       //     .withBodyParam(@"details", book)
                       .withBodyParam(@"context", self)];
    
    
    AYPromise *req3 = [AYHttpClient executeRequest:AYPOSTRequest(@"example://api.yerl.cn/task/main")
                       //     .withBodyParam(@"details", book)
                       .withBodyParam(@"context", self)];
    
    AYPromiseWith(@[req1, req2, req3]).then(^(NSArray<AYHttpResponse *> *result){
        
    });
}


- (IBAction)fetch:(id)sender {
    

    
//    AYPromiseWith(^{
//        //任务开始前显示HUD提示
//        [SVProgressHUD showWithStatus:@"加载中"];
//    }).then(^{
//        //获取详情
//        return [[DBServices new] getBookByID:@"1220562"];
//    }).then(^(NSDictionary *book){
//        
//        [AYHttpClient executeRequest:AYPOSTRequest(@"example://api.yerl.cn/contact/details")
//         .withBodyParam(@"details", book)
//         .withBodyParam(@"context", self)].then(^(AYHttpResponse *resp){
//            UIViewController *controller = resp.responseJson[@"controller"];
//            
//        });
//        
//    }).catch(^(NSError *error){
//        //统一处理所有错误
//        [[[UIAlertView alloc] initWithTitle:@"错误"
//                                   message:error.localizedDescription
//                                  delegate:nil
//                         cancelButtonTitle:@"确认"
//                          otherButtonTitles:nil] show];
//    }).always(^{
//        //在处理完毕之后，统一将HUD隐藏掉
//        [SVProgressHUD dismiss];
//    });
}
@end
