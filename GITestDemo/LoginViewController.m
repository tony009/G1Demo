//
//  LoginViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "LoginViewController.h"
#import "UIUtils.h"
#import "QCheckBox.h"
#import "SIAlertView.h"
#import "AFNetworking.h"
#include "des.h"
#import "LeftSlideViewController.h"
#import "LeftSortsViewController.h"
#import "AppDelegate.h"
#import "KVNProgress.h"
@interface LoginViewController ()<UIAlertViewDelegate,QCheckBoxDelegate>
{
    UITapGestureRecognizer *disMissTap;
    NSTimer *timer;
    KVNProgressConfiguration *basicConfiguration;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;


    //_isNeedAutoConnect = YES;
    
    //NSLog(@"沙盒路径：%@",NSHomeDirectory());
    //NSString *Path = [[NSBundle mainBundle] pathForResource:@"kernel" ofType:@""];
    
    //NSLog(@"kernel:%@",Path);
    
    [self _initSubViews];
    
    [self initBLESDK];
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
//    if (MiniPosSDKDeviceState() == 0) {
//        [self.connectDeviceButton setTitle:@"设备已连接" forState:UIControlStateNormal];
//    } else {
//        [self.connectDeviceButton setTitle:@"请先选择连接移动终端" forState:UIControlStateNormal];
//        self.connectDeviceButton.enabled = YES;
//    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

} 

- (void)keyboardWillshow:(NSNotification *)notification
{
    NSLog(@"keyboardWillshow");
    //获取键盘的高度
    //    NSValue *sizeValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //    CGRect frame = [sizeValue CGRectValue];
    //    float height = CGRectGetHeight(frame);
    [self.view addGestureRecognizer:disMissTap];
    //    [UIView animateWithDuration:0.35 animations:^{
    //        self.bgScrollView.height = self.view.height - height;
    //    }];
    
}
- (void)keyboardWillhide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:disMissTap];
    //    [UIView animateWithDuration:0.35 animations:^{
    //        self.bgScrollView.height = self.view.height;
    //    }];
}

- (void)dismissAction
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)_initSubViews
{
    disMissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)];
    
    self.configButton.layer.cornerRadius = 3.0;
    self.configButton.layer.masksToBounds = YES;
    self.siginButton.layer.cornerRadius = 3.0;
    self.siginButton.layer.masksToBounds = YES;
    
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView1.backgroundColor = [UIColor clearColor];
    imageView1.image = [UIImage imageNamed:@"人物标志.png"];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView2.backgroundColor = [UIColor clearColor];
    imageView2.image = [UIImage imageNamed:@"密码标志.png"];
    
    
    self.phoneNo.leftView = imageView1;
    self.password.leftView = imageView2;
    self.phoneNo.leftViewMode = UITextFieldViewModeAlways;
    self.password.leftViewMode = UITextFieldViewModeAlways;
    
    self.phoneNo.layer.cornerRadius = 3.0;
    self.password.layer.cornerRadius = 3.0;
    self.phoneNo.layer.masksToBounds = YES;
    self.password.layer.masksToBounds = YES;

  
    _checkBox = [[QCheckBox alloc]initWithDelegate:self];
    _checkBox.frame = CGRectMake(20, 6, 120, 30);
    [_checkBox setTitle:@"记住密码" forState:UIControlStateNormal];
    _checkBox.titleLabel.font =[UIFont systemFontOfSize: 12];
    [_checkBox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_checkBox setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
//    [_checkBox setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_checkBox setImage:[UIImage imageNamed:@"小方框.png"] forState:UIControlStateNormal];
    [_checkBox setImage:[UIImage imageNamed:@"小方框2.png"] forState:UIControlStateSelected];
    [self.protocolView addSubview:_checkBox];
    
    BOOL b = [[NSUserDefaults standardUserDefaults]boolForKey:kRememberPassword];
    [_checkBox setChecked:b];
    
    self.phoneNo.text = [[NSUserDefaults standardUserDefaults]stringForKey:kLoginPhoneNo];
    
    if (b) {
        self.password.text  = [[NSUserDefaults standardUserDefaults]stringForKey:KPassword];
    }
}







- (IBAction)configAction:(id)sender {
    
    
    //MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"商户号"], "898100012340003");
   //MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"主密钥1"], "3E61C7071A836483628567ADB6F8F2EC");
   //return;
    
//    if (![self.phoneNo.text isEqualToString:@"99"] || ![self.password.text isEqualToString:@"937927"]) {
//        
//        [self showTipView:@"操作员号或密码错误！请检查后重试。"];
//        
//        return;
//    }
    
    [self performSegueWithIdentifier:@"loginModalToConfig" sender:self];
}

//登录
- (IBAction)siginAction:(UIButton *)sender {
    
//    char paramname[100];
//    
//    memset(paramname, 0x00, sizeof(paramname));
//    strcat(paramname, "TerminalNo");
//    strcat(paramname, "\x1C");
//    strcat(paramname, "MerchantNo");
//    strcat(paramname, "\x1C");
//    strcat(paramname, "SnNo");
//    
//    MiniPosSDKGetParams("88888888", paramname);
//    
//    
//    
//    return;
    
    [self dismissAction];
    
    NSString *shanghuName = [[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName];
    NSString *ip = [[NSUserDefaults standardUserDefaults]objectForKey:kHostEditor];
    NSString *port = [[NSUserDefaults standardUserDefaults]objectForKey:kPortEditor];
    
    if (shanghuName ==nil || ip ==nil || port == nil) {
        [self showTipView:@"请先进入系统设置完成参数设置。"];
        return;
    }
    
    if (DEBUG) {
        [[NSUserDefaults standardUserDefaults] setObject:self.phoneNo.text forKey:kLoginPhoneNo];
        [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:KPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"loginToHome" sender:self];
        return;
    }
    

    if(![UIUtils isCorrectPhoneNo:self.phoneNo.text]){
        [self showTipView:@"请输入正确的手机号"];
        return;
    }
    
    if ([self.password.text isEqualToString:@""]) {
        [self showTipView:@"密码不能为空"];
        return;
    }
    
    [KVNProgress showWithStatus:@"Loading..."];
    //[self showHUD:@"正在登陆"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
     NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/login.action?phone=%@&passwd=%@",kServerIP,kServerPort,self.phoneNo.text,self.password.text];
    NSLog(@"url:%@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject:%@",responseObject[@"resultMap"][@"msg"]);
        
        //[self hideHUD];
        
        //[self hideProgressAfterDelaysInSeconds:0];

        [self hideProgressAfterDelaysInSeconds:3 withCompletion:^{
            int code = [responseObject[@"resultMap"][@"code"]intValue];
            
            if(code == 0){
                
                [[NSUserDefaults standardUserDefaults] setObject:self.phoneNo.text forKey:kLoginPhoneNo];
                [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:KPassword];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //[self performSegueWithIdentifier:@"loginToHome" sender:self];
                
                AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                LeftSortsViewController *leftVC = [[LeftSortsViewController alloc]init];
                
                UINavigationController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
                
                LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc]initWithLeftView:leftVC andMainView:mainVC];
                tempAppDelegate.LeftSlideVC = leftSlideVC;
                
                [self presentViewController:leftSlideVC animated:YES completion:nil];
                
            }else{
                [self showTipView:responseObject[@"resultMap"][@"msg"] ];
            }
        }];
 
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[self hideHUD];
        [self hideProgressAfterDelaysInSeconds:1 withCompletion:^{
            NSLog(@"failure");
            [self showTipView:@"登录失败"];
        }];
 
    }];
    
    

}




#pragma mark - 
#pragma mark - /*******/
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到成功"]]) {
        [self hideHUD];
        NSLog(@"LoginViewController ----签到成功");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"签到成功！" message:@"点击进入操作页面！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag=99;
        //[alertView show];
        
        
        SIAlertView *salertView = [[SIAlertView alloc] initWithTitle:@"签到成功！" andMessage:@"点击进入操作页面！"];
        [salertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [self performSegueWithIdentifier:@"loginToHome" sender:self];
                              }];
//        [salertView addButtonWithTitle:@"Cancel"
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alertView) {
//                                  NSLog(@"Cancel Clicked");
//                                  //[salertView dismissAnimated:YES];
//                              }];
        salertView.titleColor = [UIColor blueColor];
        salertView.cornerRadius = 10;
        salertView.buttonFont = [UIFont boldSystemFontOfSize:15];
        salertView.transitionStyle = SIAlertViewTransitionStyleSlideFromTop;
        [salertView show];
    }

    //NSLog(@"%@",self.statusStr);
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到失败"]]) {
        [self hideHUD];
        NSLog(@"LoginViewController ----签到失败");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"签到失败！" message:self.displayString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
    }
    
    
    
    if(MiniPosSDKDeviceState()==0)
    {
        [self.connectDeviceButton setTitle:@"设备已连接" forState:UIControlStateNormal];
        NSLog(@"recvMiniPosSDKStatus:设备已连接");
        
    }
    else
    {
        self.connectDeviceButton.enabled = YES;
        [self.connectDeviceButton setTitle:@"请先选择连接移动终端" forState:UIControlStateNormal];

    }
    
    
    if ([self.statusStr isEqualToString:@"签到响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    
    if ([self.statusStr isEqualToString:@"获取商户号成功"]) {
        //[self hideHUD];
        //[self showTipView:[NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding]];
    }
    
    if ([self.statusStr isEqualToString:@"获取终端号成功"]) {
        //[self hideHUD];
        //[self showTipView:[NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding]];
    }
    
//    if ([self.statusStr isEqualToString:@"未知"]) {
//        [self hideHUD];
//        [self showTipView:self.statusStr];
//    }
    if ([self.statusStr isEqualToString:@"获取参数成功"]) {
        //NSLog(@"SnNo:%s,TerminalNo:%s,MerchantNo:%s",MiniPosSDKGetParam("SnNo"), MiniPosSDKGetParam("TerminalNo"), MiniPosSDKGetParam("MerchantNo"));
        
        NSString *SnNo = [NSString stringWithCString:MiniPosSDKGetParam("SnNo") encoding:NSUTF8StringEncoding];
        NSString *TerminalNo = [NSString stringWithCString:MiniPosSDKGetParam("TerminalNo") encoding:NSUTF8StringEncoding];
        NSString *MerchantNo = [NSString stringWithCString:MiniPosSDKGetParam("MerchantNo") encoding:NSUTF8StringEncoding];
        
        [[NSUserDefaults standardUserDefaults] setObject:SnNo forKey:kMposG1SN];
        [[NSUserDefaults standardUserDefaults] setObject:TerminalNo forKey:kMposG1TerminalNo];
        [[NSUserDefaults standardUserDefaults] setObject:MerchantNo forKey:kMposG1MerchantNo];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSLog(@"SnNo:%@,TerminalNo:%@,MerchantNo:%@",[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1SN],[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1TerminalNo],[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1MerchantNo]);

    }
    
    if([self.statusStr isEqualToString:@"设备已插入"]){

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            [self getPosParams];
            
        });
        
        
    }
    
    
    
    self.statusStr = @"";
}

-(void)getPosParams{
    
    NSLog(@"didConnectDevice");
    
    char paramname[100];
    
    memset(paramname, 0x00, sizeof(paramname));
    strcat(paramname, "TerminalNo");
    strcat(paramname, "\x1C");
    strcat(paramname, "MerchantNo");
    strcat(paramname, "\x1C");
    strcat(paramname, "SnNo");
    
    MiniPosSDKGetParams("88888888", paramname);
}


#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==99)
    [self performSegueWithIdentifier:@"loginToHome" sender:self];
}

#pragma mark - QCheckBoxDelegate

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{

    [[NSUserDefaults standardUserDefaults] setBool:checked forKey:kRememberPassword];
}




@end
