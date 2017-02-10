//
//  DetailsViewController.m
//  AYHttp
//
//  Created by Alan Yeh on 2017/2/10.
//  Copyright © 2017年 Alan Yeh. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvSummary;

@end

@implementation DetailsViewController{
    NSDictionary *_details;
}

- (instancetype)initWithDetails:(NSDictionary *)details{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _details = [details copy];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lbTitle.text = _details[@"title"];
    self.tvSummary.text = _details[@"summary"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
