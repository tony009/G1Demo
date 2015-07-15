//
//  HomeViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"
#import "SIAlertView.h"
@class ImgTButton;

@interface HomeViewController : BaseViewController <UIScrollViewDelegate,UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UIView *controlView;


@property (strong, nonatomic) IBOutlet UILabel *status;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)consumeAction:(ImgTButton *)sender; //消费

- (IBAction)unconsumeAction:(ImgTButton *)sender; //撤销

- (IBAction)checkAccountAction:(ImgTButton *)sender; //查询余额

- (IBAction)sginOutAction:(ImgTButton *)sender; //签退

- (IBAction)payoffAction:(ImgTButton *)sender; //结算

- (IBAction)updataKeyAction:(ImgTButton *)sender; //更新参数

- (IBAction)getDeviceMsgAction:(ImgTButton *)sender; //获取设备信息

@end
