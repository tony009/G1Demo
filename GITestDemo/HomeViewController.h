//
//  HomeViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
#import "SIAlertView.h"
@class ImgTButton;

@interface HomeViewController : BaseViewController <UIScrollViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UIView *controlView;


@property (strong, nonatomic) IBOutlet UILabel *status;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)consumeAction:(ImgTButton *)sender;

- (IBAction)unconsumeAction:(ImgTButton *)sender;

- (IBAction)checkAccountAction:(ImgTButton *)sender;

- (IBAction)sginOutAction:(ImgTButton *)sender;

- (IBAction)payoffAction:(ImgTButton *)sender;

- (IBAction)updataKeyAction:(ImgTButton *)sender;

- (IBAction)getDeviceMsgAction:(ImgTButton *)sender;

- (IBAction)updateAction:(ImgTButton *)sender;


- (IBAction)changePage:(id)sender;

@end
