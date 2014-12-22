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



#endif

NSMutableArray *searchDevices;

BOOL _isConnect;
BOOL _isNeedAutoConnect;

int _type; //1、消费 2、撤销
