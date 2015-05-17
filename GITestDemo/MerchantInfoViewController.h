//
//  MerchantInfoViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantInfoViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *area;
@property (strong, nonatomic) IBOutlet UITextField *address;

@end
