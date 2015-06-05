//
//  RNewPasswordViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/6/5.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
@interface RNewPasswordViewController : RootViewController
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UISwitch *st;

@property (strong,nonatomic) NSString *phoneNo;
@end
