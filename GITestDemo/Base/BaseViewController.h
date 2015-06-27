//
//  BaseViewController.h
//  MovePower
//
//  Created by Femto03 on 14-6-5.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MiniPosSDK.h"
#include "BLEDriver.h"

@class MBProgressHUD;
@interface BaseViewController : UIViewController<UIAlertViewDelegate>


@property (assign, nonatomic) MiniPosSDKSessionType sessionType;
@property (assign, nonatomic) MiniPosSDKSessionError responceCode;
@property (strong, nonatomic) NSMutableString *codeString;
@property (strong, nonatomic) NSMutableString *displayString;

@property (copy, nonatomic) NSString *statusStr;


@property (nonatomic, strong) MBProgressHUD  *hud;


//显示连接蓝牙提示
- (void)showConnectionAlert;

- (void)backAction:(UIButton *)button;

//隐藏加载
- (void)hideHUD;

- (void)showHUDDelayHid:(NSString *)title;

//显示加载
- (void)showHUD:(NSString *)title;

//隐藏加载显示加载完成提示
- (void)hideHUDWithTitle:(NSString *)title;

//显示提示
- (void)showTipView:(NSString *)tip;

//回调
- (void)recvMiniPosSDKStatus;
//初始化BLE SDK
- (void)initBLESDK;
@end
