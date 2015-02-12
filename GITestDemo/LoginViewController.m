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
#import "Reachability.h"
#import "AFNetworking.h"
@interface LoginViewController ()<UIAlertViewDelegate>
{
    UITapGestureRecognizer *disMissTap;
    NSTimer *timer;
    
    NSString *_zhongduanhao;
    NSString *_shanghuhao;
    NSString *_shanghuming;
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
    
    if ([Reachability reachabilityWithHostName:@"www.apple.com"]!=NotReachable) {
        NSLog(@"网络已经连接");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //http://mpos.100pay.com.cn:8080/pms/authentication/check?merchantNo=898100012340003&terminalNo=10700028
        //http://mpos.100pay.com.cn/app/version/ios/e-swipe.json
        [manager GET:@"http://mpos.100pay.com.cn/app/version/ios/e-swipe.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSDictionary *response = responseObject;
            NSLog(@"JSON: %@", responseObject);
            NSString *curVerCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString *url = responseObject[@"downloadUrl"];
            BOOL forceUpdate = [responseObject[@"forceUpdate"] boolValue];
            NSString *verCode = responseObject[@"version"];
            
            
            SIAlertView *salertView = [[SIAlertView alloc] initWithTitle:@"有更新" andMessage:@"点击进入更新页面！"];
            [salertView addButtonWithTitle:@"确认"
                                      type:SIAlertViewButtonTypeDefault
                                   handler:^(SIAlertView *alertView) {
                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                   }];
            if (!forceUpdate) {
                [salertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                    
                }];
            }
            
            salertView.titleColor = [UIColor blueColor];
            salertView.cornerRadius = 10;
            salertView.buttonFont = [UIFont boldSystemFontOfSize:15];
            salertView.transitionStyle = SIAlertViewTransitionStyleSlideFromTop;
            
            if ([verCode compare:curVerCode options:NSNumericSearch] == NSOrderedDescending) {
                [salertView show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        
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

  
    _checkBox = [[QCheckBox alloc]initWithDelegate:nil];
    _checkBox.frame = CGRectMake(20, 6, 120, 30);
    [_checkBox setTitle:@"我已阅读并同意" forState:UIControlStateNormal];
    _checkBox.titleLabel.font =[UIFont systemFontOfSize: 10];
    [_checkBox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_checkBox setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [_checkBox setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_checkBox setImage:[UIImage imageNamed:@"uncheck_icon.png"] forState:UIControlStateNormal];
    [_checkBox setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateSelected];
    [self.protocolView addSubview:_checkBox];
    [_checkBox setChecked:YES];
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
//    MiniPosSDKUploadParam("00000000", [UIUtils UTF8_To_GB2312:@"商户号"]);
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        MiniPosSDKUploadParam("00000000", [UIUtils UTF8_To_GB2312:@"终端号"]);
//    });
//    return;
    if (!self.checkBox.checked) {
        
        [self showTipView:@"请先勾选服务协议"];
        return;
    }
    
    
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
    
    NSString *url = [NSString stringWithFormat:@"http://mpos.100pay.com.cn:8080/pms/authentication/check?merchantNo=%@&terminalNo=%@",_shanghuhao,_zhongduanhao];
    //url = @"http://mpos.100pay.com.cn:8080/pms/authentication/check?merchantNo=884210054117002&terminalNo=44700907";
    NSLog(@"url:%@",url);
    
    
    //NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];

    //NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"str:%@",dic);
    
    _shanghuming = dic[@"result"][@"mname"];
    
    if (_shanghuming != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:_shanghuming forKey:kShangHuName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSLog(@"_shanghuming:%@",_shanghuming);
    
    
    
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
        //[alertView show];
        
        
        SIAlertView *salertView = [[SIAlertView alloc] initWithTitle:@"签到成功！" andMessage:@"点击进入操作页面！"];
        [salertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [self performSegueWithIdentifier:@"loginModalToHome" sender:self];
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
        

    }
    else
    {
        self.connectDeviceButton.enabled = YES;
        [self.connectDeviceButton setTitle:@"请先选择连接移动终端" forState:UIControlStateNormal];

    }
    
    if ([self.statusStr isEqualToString:@"设备已插入"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MiniPosSDKUploadParam("00000000", [UIUtils UTF8_To_GB2312:@"商户号"]);
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MiniPosSDKUploadParam("00000000", [UIUtils UTF8_To_GB2312:@"终端号"]);
        });
    }
    
    
    if ([self.statusStr isEqualToString:@"签到响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    
    if ([self.statusStr isEqualToString:@"获取商户号成功"]) {
        //[self hideHUD];
        _shanghuhao = [NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding];
        //[self showTipView:[NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding]];
    }
    
    if ([self.statusStr isEqualToString:@"获取终端号成功"]) {
        //[self hideHUD];
        _zhongduanhao = [NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding];
        //[self showTipView:[NSString stringWithCString:MiniPosSDKGetParamValue() encoding:NSASCIIStringEncoding]];
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
