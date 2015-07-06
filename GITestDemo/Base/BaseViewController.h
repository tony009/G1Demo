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

//解密从服务器获取的主密钥
-(NSString *)decryptMainKey:(NSString *)mainKey;
//向pos端写入参数
- (void)setPosWithParams:(NSDictionary *)dictionary success:(void (^)())success;
//验证pos端的参数，成功后执行block
- (void) verifyParamsSuccess:(void (^)())success;

//显示连接蓝牙提示
- (void)showConnectionAlert;

- (void)backAction:(UIButton *)button;

-(void)showHUD:(NSString *)title afterTime:(double)seconds failStr:(NSString *)str;

//隐藏加载
- (void)hideHUD;

-(void)showProgressWithStatus:(NSString *)status;
-(void)hideProgressAfterDelaysInSeconds:(float)seconds;
-(void)hideProgressAfterDelaysInSeconds:(float)seconds withCompletion:(void (^)())completion;

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
