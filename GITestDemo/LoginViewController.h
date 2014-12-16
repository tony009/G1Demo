//
//  LoginViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController


@property (strong, nonatomic) IBOutlet UITextField *controlNoText;
@property (strong, nonatomic) IBOutlet UITextField *pwdText;


@property (strong, nonatomic) IBOutlet UIButton *siginButton;

@property (strong, nonatomic) IBOutlet UIButton *configButton;
@property (strong, nonatomic) IBOutlet UILabel *connectStateLabel;
@property (strong, nonatomic) IBOutlet UIButton *connectDeviceButton;

- (IBAction)connectDeviceAction:(UIButton *)sender;

- (IBAction)configAction:(id)sender;

- (IBAction)siginAction:(UIButton *)sender;


@end
