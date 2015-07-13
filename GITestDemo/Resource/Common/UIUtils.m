//
//  UIUtils.m
//  WXMovie
//
//  Created by wei.chen on 13-9-9.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (NSDate *)dateFromString:(NSString *)datestring formate:(NSString *)formate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formate];
    NSDate *date = [dateFormatter dateFromString:datestring];
    
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date formate:(NSString *)formate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formate];
    NSString *datestring = [dateFormatter stringFromDate:date];
    
    return datestring;
}

+ (long long)countDirectorySize:(NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取到目录下面所有的文件名
    NSArray *fileNames = [fileManager subpathsOfDirectoryAtPath:directory error:nil];
    
    long long sum = 0;
    for (NSString *fileName in fileNames) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        
        NSDictionary *attribute = [fileManager attributesOfItemAtPath:filePath error:nil];
        
        //        NSNumber *filesize = [attribute objectForKey:NSFileSize];
        long long size = [attribute fileSize];
        
        sum += size;
    }
    
    return sum;
}

+ (void)flipViewAction:(UIView *)forView direction:(int)flag {
    
    //判断翻转方向
    UIViewAnimationTransition transition =UIViewAnimationTransitionFlipFromLeft;
    switch (flag) {
        case 0:
            transition = UIViewAnimationTransitionFlipFromLeft;
            break;
        case 1:
            transition = UIViewAnimationTransitionFlipFromRight;
            break;
        case 2:
            transition = UIViewAnimationTransitionCurlUp;
            break;
        case 3:
            transition = UIViewAnimationTransitionCurlDown;
            break;
            
        default:
            break;
    }
    
    
    //给翻转按钮的父视图添加翻转动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:transition forView:forView cache:YES];
    [UIView commitAnimations];
    
    //    //调换两个子视图的位置
    //    [forView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0-25-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *) formate
{
    
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formate];
        
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
        if (time<=60) {  //// 1分钟以内的
            dateStr = @"刚刚";
        }else if(time<=60*60){  ////  一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
            
        }else if(time<=60*60*24){   //// 在两天内的
            
            [dateFormatter setDateFormat:@"YYYY/MM/dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
                dateStr = [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                [dateFormatter setDateFormat:@"MM月dd日"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
    
    
}

+(NSString *)formateDate:(NSString *)timeIntervalStr
{
    //转换指定时间戳-》时间
    NSString *fomt = @"YYYY-MM-dd HH:mm";
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fomt];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeIntervalStr floatValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    NSTimeInterval  timeInterval = [confromTimesp timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;

    
    temp = timeInterval/60/60/24;
    if (temp < 1) {
        return [[confromTimespStr componentsSeparatedByString:@" "] lastObject];
    } else if (temp < 2) {
        return @"昨天";
    } else {
        return [[confromTimespStr componentsSeparatedByString:@" "] firstObject];
    }
    return @"";
}


// iphone 截屏方法
+ (UIImage *)imageFromView:(UIView *)theView
{
    //  CGSize size=CGSizeMake(theView.frame.size.width*2, theView.frame.size.height*2);
    // UIGraphicsBeginImageContext(theView.frame.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//获取设备的UUID
+ (NSString*)getMyMachine
{
    UIDevice * device = [UIDevice currentDevice];
    NSString* str = [[device identifierForVendor] UUIDString];
    return str;
    
}

+ (BOOL)isCorrectNumber:(NSString*)numer
{
    const char *str = numer.UTF8String;
    int len = numer.length;
    
    if(len<=0)
        return FALSE;
    
    for(int i=0;i<len;i++)
    {
        if(str[i]<'0'||str[i]>'9')
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

+ (BOOL)isCorrectIP:(NSString *)ip{
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"" options:0 error:NULL];
    
    NSString *regex = @"^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)($|(?!\\.$)\\.)){4}$";

    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch            = [pred evaluateWithObject:ip];
    
    
    return isMatch;
}

//根据文字内容，字体大小获取宽度
+ (CGFloat)getWithWithString:(NSString *)string font:(CGFloat)fontSize
{
    
    UILabel *label = [[UILabel alloc] init];
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    label.font = fnt;
    label.text = string;
    
    // 根据字体得到NSString的尺寸
    CGSize size1 = [label.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
    
    CGFloat nameW = size1.width;
    
    return nameW;
}

+ (BOOL)isCorrectPhoneNo:(NSString *)number{
    
    NSString *regex = @"^1\\d{10}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:number];
    
    return isMatch;
}
//判断是否为正确的银行卡号
+ (BOOL)isCorrectBankCardNumber:(NSString *)str{
    
    NSString *regex = @"^(\\d{15,30})";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
    
}

//判断是否为正确的身份证号码
+ (BOOL)isCorrectID:(NSString *)str{
    
    NSString *regex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
    
}
//判断是否为正确的密码
+ (BOOL)isCorrectPassword:(NSString *)str{
    NSString *regex = @"^[0-9A-Za-z]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
//判断是否未空字符串
+ (BOOL)isEmptyString:(NSString *)str{
    
    
    if (str == nil|| [str isEqualToString:@""]) {
        return true;
    }else{
        return false;
    }
    
}
+ (char *)UTF8_To_GB2312:(NSString*)utf8string
{
    NSStringEncoding encoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    const char *gb2312 = [utf8string cStringUsingEncoding:encoding];
    return gb2312;
}

+ (NSString*) GB2312_To_UTF8:(char *)gb2312string
{
    NSStringEncoding encoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *gb2312 = [NSString stringWithCString:gb2312string encoding:encoding];
    return gb2312;
}

@end
