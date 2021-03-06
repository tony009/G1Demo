//
//  LoginViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "LoginViewController.h"
#import "UIUtils.h"
@interface LoginViewController ()<UIAlertViewDelegate>
{
    UITapGestureRecognizer *disMissTap;
    NSTimer *timer;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isNeedAutoConnect = YES;
    
    //NSLog(@"沙盒路径：%@",NSHomeDirectory());
    //NSString *Path = [[NSBundle mainBundle] pathForResource:@"kernel" ofType:@""];
    
    //NSLog(@"kernel:%@",Path);
    
    [self _initSubViews];
    
    NSString *shangHu = [[NSUserDefaults standardUserDefaults] stringForKey:kShangHuEditor];
    NSString *zhongDuan = [[NSUserDefaults standardUserDefaults] stringForKey:kZhongDuanEditor];
    NSString *caoZhuoYuan = [[NSUserDefaults standardUserDefaults] stringForKey:kCaoZhuoYuanEditor];
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kHostEditor];
    NSString *port = [[NSUserDefaults standardUserDefaults] stringForKey:kPortEditor];
      
    
    if (!shangHu) {
        shangHu  = @"898100012340003";
    }
    if (!zhongDuan) {
        zhongDuan = @"10700028";
    }
    if (!caoZhuoYuan) {
        caoZhuoYuan = @"01";
    }
    if (!host) {
        host = @"122.112.12.227";
    }
    if (!port) {
        port = @"5555";
    }
    
    MiniPosSDKInit();
    NSLog(@"LoginViewController-host:%s,port:%d",host.UTF8String,port.intValue);
    MiniPosSDKSetPublicParam(shangHu.UTF8String, zhongDuan.UTF8String, caoZhuoYuan.UTF8String);
    MiniPosSDKSetPostCenterParam(host.UTF8String, port.intValue, 0);
    [self.connectDeviceButton setTitle:@"正在连接设备..." forState:UIControlStateNormal];
    
    [self bleConnectAction];
    
    
    // Do any additional setup after loading the view.
}


- (void)bleConnectAction {
    
    DeviceDriverInterface *t;
    t=GetBLEDeviceInterface();
    MiniPosSDKRegisterDeviceInterface(t);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
    if (MiniPosSDKDeviceState() == 0) {
        [self.connectDeviceButton setTitle:@"设备已连接" forState:UIControlStateNormal];
    } else {
        [self.connectDeviceButton setTitle:@"请先选择连接移动终端" forState:UIControlStateNormal];
        self.connectDeviceButton.enabled = YES;
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

} 

- (void)keyboardWillshow:(NSNotification *)notification
{
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
    
//    LoginModalToHome
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
    imageView1.image = [UIImage imageNamed:@"incon_me2.png"];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView2.backgroundColor = [UIColor clearColor];
    imageView2.image = [UIImage imageNamed:@"icon_password1.png"];
    
    
    self.controlNoText.leftView = imageView1;
    self.pwdText.leftView = imageView2;
    self.controlNoText.leftViewMode = UITextFieldViewModeAlways;
    self.pwdText.leftViewMode = UITextFieldViewModeAlways;
    
    self.controlNoText.layer.cornerRadius = 3.0;
    self.pwdText.layer.cornerRadius = 3.0;
    self.controlNoText.layer.masksToBounds = YES;
    self.pwdText.layer.masksToBounds = YES;

  
}


- (IBAction)connectDeviceAction:(UIButton *)sender {
    [self performSegueWithIdentifier:@"loginModalToConnect" sender:self];
    
}

- (IBAction)configAction:(id)sender {
    
    
    
    //MiniPosSDKDownParam("000000000", [UIUtils UTF8_To_GB2312:@"主密钥1"], "3E61C7071A836483628567ADB6F8F2EC");
    //return;
    
    if (![self.controlNoText.text isEqualToString:@"99"] || ![self.pwdText.text isEqualToString:@"937927"]) {
        
        [self showTipView:@"操作员号或密码错误！请检查后重试。"];
        
        return;
    }
    
    [self performSegueWithIdentifier:@"loginModalToConfig" sender:self];
}

- (IBAction)siginAction:(UIButton *)sender {
    
    //[self performSegueWithIdentifier:@"loginModalToHome" sender:self];
    
    //return;

    
    if (![self.controlNoText.text isEqualToString:@"01"] || ![self.pwdText.text isEqualToString:@"0000"]) {
        
        [self showTipView:@"操作员号或密码错误！请检查后重试。"];
        
        return;
    }
    
    NSString *shanghuName = [[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName];
    NSString *ip = [[NSUserDefaults standardUserDefaults]objectForKey:kHostEditor];
    NSString *port = [[NSUserDefaults standardUserDefaults]objectForKey:kPortEditor];
    
    if (shanghuName ==nil || ip ==nil || port == nil) {
        [self showTipView:@"请先进入系统设置完成参数设置。"];
        return;
    }
    
    
    if (MiniPosSDKDeviceState() == 0) {
        if(MiniPosSDKPosLogin()>=0)
        {
            
            [self showHUD:@"正在签到..."];
            
            
        }
    }else{
        [self showTipView:@"设备未连接"];
    }
    

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
        [alertView show];
        
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
    
//    if ([self.statusStr isEqualToString:@"未知"]) {
//        [self hideHUD];
//        [self showTipView:self.statusStr];
//    }
    
    self.statusStr = @"";
}

#pragma mark -
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==99)
    [self performSegueWithIdentifier:@"loginModalToHome" sender:self];
}





@end
