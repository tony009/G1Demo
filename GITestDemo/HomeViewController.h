//
//  HomeViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
@class ImgTButton;

@interface HomeViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UIView *controlView;


@property (strong, nonatomic) IBOutlet UILabel *status;



- (IBAction)customAction:(ImgTButton *)sender;

- (IBAction)reCustomAction:(ImgTButton *)sender;

- (IBAction)checkAccountAction:(ImgTButton *)sender;

- (IBAction)sginOutAction:(ImgTButton *)sender;

- (IBAction)payoffAction:(ImgTButton *)sender;

- (IBAction)updataKeyAction:(ImgTButton *)sender;

- (IBAction)getDviceMsgAction:(ImgTButton *)sender;

- (IBAction)moreAction:(ImgTButton *)sender;


@end
