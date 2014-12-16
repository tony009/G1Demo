//
//  DeviceConfigViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface DeviceConfigViewController : BaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *shanghuNameText; //商户名

@property (strong, nonatomic) IBOutlet UITextField *shangHuEditor; //商户号

@property (strong, nonatomic) IBOutlet UITextField *zhongDuanEditor; //终端号

@property (strong, nonatomic) IBOutlet UITextField *caoZhuoYuanEditor; //操作员
@property (strong, nonatomic) IBOutlet UITextField *hostEditor; //主机号
@property (strong, nonatomic) IBOutlet UITextField *portEditor; //端口号


@property (strong, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)downloadPulicKey:(UIButton *)sender;
- (IBAction)downloadAID:(UIButton *)sender;
- (IBAction)saveSettingValue:(UIButton *)sender;

@end
