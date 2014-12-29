//
//  UIUtils.h
//  WXMovie
//
//  Created by wei.chen on 13-9-9.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtils : NSObject

//将字符串格式化为Date对象
+ (NSDate *)dateFromString:(NSString *)datestring formate:(NSString *)formate;
//将日期格式化为NSString对象
+ (NSString *)stringFromDate:(NSDate *)date formate:(NSString *)formate;
//计算目录下面所有文件的大小
+ (long long)countDirectorySize:(NSString *)directory;
//翻转视图
+ (void)flipViewAction:(UIView *)forView direction:(int)flag;
//检索手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//时间转换
+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *) formate;

//时间戳转化为时间
+(NSString *)formateDate:(NSString *)timeIntervalStr;

//视图截图
+ (UIImage *)imageFromView:(UIView *)theView;

//获取设备的UUID
+ (NSString*)getMyMachine;

//判断是否为正确的ip
+ (BOOL)isCorrectIP:(NSString *)ip;

//判断是否为纯数字
+ (BOOL)isCorrectNumber:(NSString*)numer;

//根据文字内容，字体大小获取宽度
+ (CGFloat)getWithWithString:(NSString *)string font:(CGFloat)fontSize;
@end
