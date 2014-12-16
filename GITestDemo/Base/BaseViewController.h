//
//  BaseViewController.h
//  MovePower
//
//  Created by Femto03 on 14-6-5.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MiniPosSDK.h"
#include "AudioDriver.h"
#include "BLEDriver.h"

@class MBProgressHUD;
@interface BaseViewController : UIViewController


@property (assign, nonatomic) MiniPosSDKSessionType sessionType;
@property (assign, nonatomic) MiniPosSDKSessionError responceCode;
@property (strong, nonatomic) NSMutableString *codeString;
@property (strong, nonatomic) NSMutableString *displayString;

@property (copy, nonatomic) NSString *statusStr;


@property (nonatomic, strong) MBProgressHUD  *hud;

- (void)backAction:(UIButton *)button;

//隐藏加载
- (void)hideHUD;

- (void)showHUDDelayHid:(NSString *)title;

//显示加载
- (void)showHUD:(NSString *)title;

//隐藏加载显示加载完成提示
- (void)hideHUDWithTitle:(NSString *)title;

- (void)showTipView:(NSString *)tip;


- (void)recvMiniPosSDKStatus;

@end
