//
//  SignupViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/4/16.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "SignupViewController.h"
#import "ConnectDeviceViewController.h"
#import "AFNetworking.h"
#import "WDPickView.h"
#import "MiniPosSDK.h"
#include "BLEDriver.h"
@interface SignupViewController ()<UITextFieldDelegate,WDPickViewDelegate,QRadioButtonDelegate>

@end

@implementation SignupViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    QRadioButton *_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"merType"];
    _radio1.frame = CGRectMake(130, 48, 100, 40);
    _radio1.tag = 1;
    [_radio1 setTitle:@"企业Mpos" forState:UIControlStateNormal];
    [self.scrollView addSubview:_radio1];
    [_radio1 setChecked:YES];
    QRadioButton *_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"merType"];
    _radio2.frame = CGRectMake(220, 48, 100, 40);
    _radio2.tag = 2;
    [_radio2 setTitle:@"个人Mpos" forState:UIControlStateNormal];
    [self.scrollView addSubview:_radio2];
    
    
    QRadioButton *certType_radio1 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    QRadioButton *certType_radio2 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    QRadioButton *certType_radio3 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    QRadioButton *certType_radio4 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    QRadioButton *certType_radio5 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    QRadioButton *certType_radio6 = [[QRadioButton alloc]initWithDelegate:self groupId:@"certType"];
    certType_radio1.tag =1;
    [certType_radio1 setTitle:@"身份证" forState:UIControlStateNormal];
    certType_radio1.frame = CGRectMake(100, 276, 100, 40);
    [certType_radio1 setChecked:YES];
    [self.scrollView addSubview:certType_radio1];
    certType_radio2.tag =2;
    [certType_radio2 setTitle:@"护照" forState:UIControlStateNormal];
    certType_radio2.frame = CGRectMake(170, 276, 100, 40);
    [self.scrollView addSubview:certType_radio2];
    certType_radio3.tag =3;
    [certType_radio3 setTitle:@"军(警)官证" forState:UIControlStateNormal];
    certType_radio3.frame = CGRectMake(240, 276, 100, 40);
    [self.scrollView addSubview:certType_radio3];
    certType_radio4.tag =4;
    [certType_radio4 setTitle:@"士兵证" forState:UIControlStateNormal];
    certType_radio4.frame = CGRectMake(100, 314, 100, 40);
    [self.scrollView addSubview:certType_radio4];
    certType_radio5.tag =5;
    [certType_radio5 setTitle:@"台胞证" forState:UIControlStateNormal];
    certType_radio5.frame = CGRectMake(170, 314, 100, 40);
    [self.scrollView addSubview:certType_radio5];
    certType_radio6.tag =6;
    [certType_radio6 setTitle:@"回乡证" forState:UIControlStateNormal];
    certType_radio6.frame = CGRectMake(240, 314, 100, 40);
    [self.scrollView addSubview:certType_radio6];
    
    QRadioButton *accountType_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"accountType"];
    accountType_radio1.frame = CGRectMake(130, 521, 100, 40);
    accountType_radio1.tag = 1;
    [accountType_radio1 setTitle:@"借记卡" forState:UIControlStateNormal];
    [self.scrollView addSubview:accountType_radio1];
    [accountType_radio1 setChecked:YES];
    QRadioButton *accountType_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"accountType"];
    accountType_radio2.frame = CGRectMake(220, 521, 100, 40);
    accountType_radio2.tag = 2;
    [accountType_radio2 setTitle:@"贷记卡" forState:UIControlStateNormal];
    [self.scrollView addSubview:accountType_radio2];
    
    QRadioButton *isPrivate_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"isPrivate"];
    isPrivate_radio1.frame = CGRectMake(130, 559, 100, 40);
    isPrivate_radio1.tag = 1;
    [isPrivate_radio1 setTitle:@"对私" forState:UIControlStateNormal];
    [self.scrollView addSubview:isPrivate_radio1];
    [isPrivate_radio1 setChecked:YES];
    QRadioButton *isPrivate_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"isPrivate"];
    isPrivate_radio2.frame = CGRectMake(220, 559, 100, 40);
    isPrivate_radio2.tag = 0;
    [isPrivate_radio2 setTitle:@"对公" forState:UIControlStateNormal];
    [self.scrollView addSubview:isPrivate_radio2];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    

    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 950);
    

    WDPickView *pickView = [[WDPickView alloc]initPickViewWithPlistName:@"Address"];
    pickView.delegate = self;
    self.areaCode.inputView = pickView;
    
    self.merType.delegate = self;
    self.merType.label = @"商户类型";
    self.brCname.delegate = self;
    self.brCname.label = @"商户名称";
    self.areaCode.delegate = self;
    self.areaCode.label = @"地区编码";
    self.phone.delegate = self;
    self.phone.label = @"手机号码";
    self.linkMan.delegate = self;
    self.linkMan.label = @"联系人";
    self.linkPhone.delegate = self;
    self.linkPhone.label = @"联系电话";
    self.certType.delegate = self;
    self.certType.label = @"证件种类";
    self.certNo.delegate = self;
    self.certNo.label = @"证件号码";
    self.certExpdate.delegate = self;
    self.certExpdate.label = @"证件有效期";
    self.mchAddr.delegate = self;
    self.mchAddr.label = @"营业地址";
    self.accountType.delegate = self;
    self.accountType.label = @"商户类型";
    self.isPrivate.delegate = self;
    self.isPrivate.label = @"账号标识";
    self.bankName.delegate = self;
    self.bankName.label = @"开户行全称";
    self.province.delegate = self;
    self.province.label = @"开户行所在省";
    self.city.delegate = self;
    self.city.label = @"开户行所在市";
    self.bankBranch.delegate = self;
    self.bankBranch.label = @"支行名称";
    self.settleAccno.delegate = self;
    self.settleAccno.label = @"开户行账号";
    self.accName.delegate = self;
    self.accName.label = @"开户名称";
    self.sn.delegate = self;
    self.sn.label = @"SN号";
    
    
    self.certExpdate.isDateField = YES;
    
    self.merType.required = YES;
    self.areaCode.required = YES;
    self.phone.required = YES;
    self.linkMan.required = YES;
    self.linkPhone.required = YES;
    self.certType.required = YES;
    self.certNo.required = YES;
    self.accountType.required = YES;
    self.isPrivate.required = YES;
    self.bankName.required = YES;
    self.province.required = YES;
    self.city.required = YES;
    self.bankBranch.required = YES;
    self.settleAccno.required = YES;
    self.accName.required = YES;
    
    
     NSLog(@"basicInfo x:%lf,y:%lf",self.basicInfo.origin.x,self.basicInfo.origin.y);
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     NSLog(@"x:%lf,y:%lf",self.scrollView.origin.x,self.scrollView.origin.y);
     NSLog(@"basicInfo x:%lf,y:%lf",self.basicInfo.origin.x,self.basicInfo.origin.y);
}

- (BOOL)validateInputInView:(UIView*)view
{
    for(UIView *subView in view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]])
            return [self validateInputInView:subView];
        
        if ([subView isKindOfClass:[DemoTextField class]]){
            if (![(MHTextField*)subView validate]){
                self.validateResultString = [NSString stringWithFormat:@"请输入正确的%@",((MHTextField*)subView).label];
                return NO;
            }
        }
    }
    
    return YES;
}

- (IBAction)submit:(UIButton *)sender {
    

    
    if (![self validateInputInView:self.view]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:self.validateResultString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alertView show];
    }
    
    
    
    NSString *str = @"http://ip:端口/MposApp/register.action?merType=%@&brCname=%@&areaCode=%@&phone=%@&linkMan=%@&linkPhone=%@&certType=%@&certNo=%@&certExpdate=%@&mchAddr=%@&accountType=%@&isPrivate=%@&bankName=%@&province=%@&city=%@&bankBranch=%@&settleAccno=%@&accName=%@&sn=%@";
    
   
    NSString *urlStr = [[NSString alloc]initWithFormat:str,self.merType.text,self.brCname.text,self.areaCode.text,self.phone.text,self.linkMan.text,self.linkPhone.text,self.certType.text,self.certNo.text,self.certExpdate.text,self.mchAddr.text,self.accountType.text,self.isPrivate.text,self.bankName.text,self.province.text,self.city.text,self.bankBranch.text,self.settleAccno.text,self.accName.text,self.sn.text ];
    
    
    NSLog(@"url:%@",urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    //[[NSOperationQueue mainQueue] addOperation:op];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)toolBarDoneBtnHaveClicked:(WDPickView *)pickView resultString:(NSString *)resultString{
    self.areaCode.text = resultString;
}

- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId{
    if([groupId isEqualToString:@"merType"]){
        self.merType.text = [NSString stringWithFormat:@"%d",radio.tag];
    }else if ([groupId isEqualToString:@"certType"]){
        self.certType.text = [NSString stringWithFormat:@"%d",radio.tag];
    }else if ([groupId isEqualToString:@"accountType"]){
        self.accountType.text = [NSString stringWithFormat:@"%d",radio.tag];
    }else if ([groupId isEqualToString:@"isPrivate"]){
        self.isPrivate.text = [NSString stringWithFormat:@"%d",radio.tag];
    }


}

- (IBAction)getSN:(id)sender {
    
    if(MiniPosSDKDeviceState()<0){
    
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设备未连接"
                                                                       message:@"点击跳转设备连接界面"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  ConnectDeviceViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CD"];
                                                                  [self.navigationController pushViewController:cdvc animated:YES];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        

        
        return;
    }
    
    MiniPosSDKGetDeviceInfoCMD();
}

- (void)recvMiniPosSDKStatus{
    [super recvMiniPosSDKStatus];
    
    if ([self.statusStr isEqualToString:@"获取设备信息成功"]) {
        NSString *sn = [NSString stringWithFormat:@"%s",MiniPosSDKGetDeviceID()];
        self.sn.text = sn;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
