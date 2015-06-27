//
//  FunctionMenuViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/27.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "FunctionMenuViewController.h"
#import "WDImageButton.h"
@interface FunctionMenuViewController ()

@end

@implementation FunctionMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initSubViews];
}

-(void)_initSubViews{
    
    NSArray *labelArray = @[@"话费充值",@"机票服务",@"游戏点卡",@"基金理财",@"信用卡还款",@"余额查询",@"卡卡转账",@"交通违章",@"水电煤代缴"];
    NSArray *imgArray = @[@"话费充值",@"机票服务",@"游戏点卡",@"基金理财",@"信用卡还款",@"余额查询",@"卡卡转账",@"交通违章",@"水电煤代缴"];
    
    for (int i =0 ; i < 4; i++) {
        WDImageButton *button = (WDImageButton *)[self.functionView viewWithTag:i+10];
        button.imageName = [imgArray objectAtIndex:i];
        button.text = labelArray[i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.navigationItem.title = @"功能界面";
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
