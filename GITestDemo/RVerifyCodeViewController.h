//
//  RVerifyCodeViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/6/4.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface RVerifyCodeViewController : RootViewController
@property (strong, nonatomic) IBOutlet UILabel *phoneNo;
@property (strong, nonatomic) IBOutlet UITextField *verificationCode;
@property (strong, nonatomic) IBOutlet UIButton *getVerCodeBtn;

@property (strong, nonatomic) IBOutlet UILabel *getVerCodeLabel;



@end

