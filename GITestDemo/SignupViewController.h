//
//  SignupViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/4/16.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//
#import "DemoTextField.h"
#import "BaseViewController.h"
#import "QRadioButton.h"
@interface SignupViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *basicInfo;

@property (strong, nonatomic) IBOutlet DemoTextField *merType;  //商户类型  
@property (strong, nonatomic) IBOutlet DemoTextField *brCname; //商户中文简称
@property (strong, nonatomic) IBOutlet DemoTextField *areaCode; //地区编码
@property (strong, nonatomic) IBOutlet DemoTextField *phone; //手机号码
@property (strong, nonatomic) IBOutlet DemoTextField *linkMan; //联系人
@property (strong, nonatomic) IBOutlet DemoTextField *linkPhone; //联系电话
@property (strong, nonatomic) IBOutlet DemoTextField *certType; //法人有效证件种类
@property (strong, nonatomic) IBOutlet DemoTextField *certNo; //法人有效证件号码
@property (strong, nonatomic) IBOutlet DemoTextField *certExpdate; //法人证件有效日期
@property (strong, nonatomic) IBOutlet DemoTextField *mchAddr; //商户营业地址

@property (strong, nonatomic) IBOutlet DemoTextField *accountType; //账号类型
@property (strong, nonatomic) IBOutlet DemoTextField *isPrivate; //对公或对私账户标识
@property (strong, nonatomic) IBOutlet DemoTextField *bankName; //开户行全称
@property (strong, nonatomic) IBOutlet DemoTextField *province; //开户行所在省
@property (strong, nonatomic) IBOutlet DemoTextField *city; //开户行所在市
@property (strong, nonatomic) IBOutlet DemoTextField *bankBranch; //支行名称
@property (strong, nonatomic) IBOutlet DemoTextField *settleAccno; //开户行账号
@property (strong, nonatomic) IBOutlet DemoTextField *accName; //开户名称

@property (strong, nonatomic) IBOutlet DemoTextField *sn; //机身码


@property (strong,nonatomic) NSString *validateResultString;











@end
