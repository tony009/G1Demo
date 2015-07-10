//
//  Common.h
//  GITest
//
//  Created by Femto03 on 14/11/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#ifndef GITest_Common_h
#define GITest_Common_h

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define isIPhone5 [UIScreen mainScreen].bounds.size.height > 480 ? YES:NO
#define isIOS_5 (([[[UIDevice currentDevice] systemVersion] floatValue] <= 6.0)? (YES):(NO))
#define isIOS_7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)? (YES):(NO))
#define isIOS_8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

//通过三色值获取颜色对象
#define rgb(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#import "BleManager.h"

#define KUUIDService @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
#define kUUIDRead @"49535343-1E4D-4BD9-BA61-23C647249616"
#define kUUIDWrite @"49535343-8841-43F4-A8D4-ECBE34729BB3"

#define KUUIDService1 @"FFFF"
#define kUUIDRead1 @"FF01"
#define kUUIDWrite1 @"FF02"

#define kDidDiscoverDevice @"didDiscoverDevice"
#define kDidConnectDevice @"didConnectDevice"

#define kLastConnectedDevice @"lastConnectedDevice"

#define KLastPingZhengHao @"lastPingZhengHao"
#define KLastJiaoYiJinE @"lastJiaoYiJinE"


#define kShangHuName @"shanghuName"  
#define kShangHuEditor @"shangHuEditor"
#define kZhongDuanEditor @"zhongDuanEditor"
#define kCaoZhuoYuanEditor @"caoZhuoYuanEditor"
#define kHostEditor @"hostEditor"
#define kPortEditor @"portEditor"
#define kRememberPassword @"RememberPassword" //是否记住密码
#define kSignUpPhoneNo @"SignUpPhoneNo" //注册时验证通过的手机号码
#define kLoginPhoneNo @"LoginPhoneNo" //登录成功的手机号码
#define KPassword @"Password" //登录成功的密码

#define kMposG1SN @"SnNo"  //mposSN号
#define kMposG1TerminalNo @"TerminalNo" //mpos终端号
#define kMposG1MerchantNo @"MerchantNo" //mpos商户号
#define kMposG1MainKey  @"MainKey"  //mpos主密钥

////腾氏测试
//#define kServerIP @"122.112.12.25" //注册登录的ip
//#define kServerPort @"18081" //注册登录的端口
//#define kPosIP @"122.112.12.25"
//#define kPosPort @"25679"
//#define kDecryptKey "22222222222222222222222222222222"

//腾氏生产
#define kServerIP @"122.112.12.29" //注册登录的ip
#define kServerPort @"8081" //注册登录的端口
#define kPosIP @"122.112.12.24"
#define kPosPort @"5679"
#define kDecryptKey "00000003000011650000000300001165"

//铜元
//#define kServerIP @"122.112.12.20" //注册登录的ip
//#define kServerPort @"8081" //注册登录的端口
//#define kPosPort @"6889"
//#define kDecryptKey "01CCA5D0712519DE01CCA5D0712519DE"
//#define kPosIP @"122.112.12.20"

#define DEBUG false
//#define DEBUG true



#endif

NSMutableArray *searchDevices;

BOOL _isConnect;
BOOL _isNeedAutoConnect;

int _type; //1、消费 2、撤销
