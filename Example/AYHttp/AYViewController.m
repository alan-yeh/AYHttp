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

@interface AYViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvSummary;

@end

@implementation AYViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)fetch:(id)sender {
    AYPromiseWith(^{
        //任务开始前显示HUD提示
        [SVProgressHUD showWithStatus:@"加载中"];
    }).then(^{
        //获取详情
        return [[DBServices new] getBookByID:@"1220562"];
    }).then(^(DBBook *book){
        //将实体中的信息绑定到界面元素中
        self.tfTitle.text = book.title;
        self.tvSummary.text = book.summary;
    }).catch(^(NSError *error){
        //统一处理所有错误
        [[[UIAlertView alloc] initWithTitle:@"错误"
                                   message:error.localizedDescription
                                  delegate:nil
                         cancelButtonTitle:@"确认"
                          otherButtonTitles:nil] show];
    }).always(^{
        //在处理完毕之后，统一将HUD隐藏掉
        [SVProgressHUD dismiss];
    });
}
@end
