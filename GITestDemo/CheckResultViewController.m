//
//  CheckResultViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/12/2.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "CheckResultViewController.h"

@interface CheckResultViewController ()

@end

@implementation CheckResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSubViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_initSubViews
{
    self.logImgView.layer.cornerRadius = 25.0;
    self.logImgView.layer.masksToBounds = YES;
}


- (void)backAction:(UIButton *)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
