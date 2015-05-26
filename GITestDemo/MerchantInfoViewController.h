//
//  MerchantInfoViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "UIUtils.h"
#import "WDPickView.h"
#import "BaseViewController.h"
@interface MerchantInfoViewController :BaseViewController<UITextFieldDelegate,WDPickViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *area;
@property (strong,nonatomic)  NSString *areaCode; //地区编码
@property (strong, nonatomic) IBOutlet UITextField *address;
@property (strong, nonatomic) IBOutlet UITextField *sn;

@end
