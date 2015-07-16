//
//  HomeViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"
#import "SIAlertView.h"
@class UIButton;

@interface HomeViewController : BaseViewController <UIScrollViewDelegate,UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UIView *controlView;


@property (strong, nonatomic) IBOutlet UILabel *status;


- (IBAction)consumeAction:(UIButton *)sender; //消费

- (IBAction)unconsumeAction:(UIButton *)sender; //撤销

- (IBAction)checkAccountAction:(UIButton *)sender; //查询余额

- (IBAction)sginOutAction:(UIButton *)sender; //签退

- (IBAction)payoffAction:(UIButton *)sender; //结算

- (IBAction)updataKeyAction:(UIButton *)sender; //更新参数

- (IBAction)getDeviceMsgAction:(UIButton *)sender; //获取设备信息

@end
