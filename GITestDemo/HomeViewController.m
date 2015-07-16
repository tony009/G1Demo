//
//  HomeViewController.m
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "HomeViewController.h"
#import "SwipingCardViewController.h"
#import "CustomAlertView.h"
#import "AFNetworking.h"
#import "ConnectDeviceViewController.h"
#include "des.h"
#import "UIUtils.h"
@interface HomeViewController ()
{
    NSTimer *timer;
    NSString *sendValue;

}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *shangHuName  = [[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName];
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kHostEditor];
    NSString *port = [[NSUserDefaults standardUserDefaults] stringForKey:kPortEditor];
    
    
    if (!host) {
        [[NSUserDefaults standardUserDefaults] setObject:kPosIP forKey:kHostEditor];
    }
    if (!port) {
        
        [[NSUserDefaults standardUserDefaults] setObject:kPosPort forKey:kPortEditor];
    }
    if (!shangHuName) {
        [[NSUserDefaults standardUserDefaults] setObject:@"周黑鸭" forKey:kShangHuName];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    MiniPosSDKInit();
    MiniPosSDKRegisterDeviceInterface(GetBLEDeviceInterface());

}





-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    MiniPosSDKInit();
    

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UIViewController *send=segue.destinationViewController;
    if ([send respondsToSelector:@selector(setType:)]) {
        [send setValue:sendValue forKey:@"type"];
    }
    
    NSLog(@"prepareForSegue");
    
}


//签到
- (IBAction)siginAction:(UIButton *)sender {
    

    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else{
    
        
        if(MiniPosSDKPosLogin()>=0)
        {
            
            [self showHUD:@"正在签到"];
            
        }
        
    }
    
    
}

//消费
- (IBAction)consumeAction:(UIButton *)sender {
 
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else{
        
        if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
            
            [self performSegueWithIdentifier:@"xiaofei" sender:self];
            
        }else{
            [self showTipView:@"设备繁忙，稍后再试"];
        }
        
    }
    
}
//撤销
- (IBAction)unconsumeAction:(UIButton *)sender {
    
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else {
        
        NSString *pingZhengHao = [[NSUserDefaults standardUserDefaults] objectForKey:KLastPingZhengHao];
        
        if (!pingZhengHao || [pingZhengHao isEqualToString:@""]) {
            [self showTipView:@"没有可以撤销的交易"];
            
            return ;
        }
        
        if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
            
            [self performSegueWithIdentifier:@"chexiao" sender:self];
        }else {
            [self showTipView:@"设备繁忙，稍后再试"];
        }
        
    }
    
    
}
//查询余额
- (IBAction)checkAccountAction:(id)sender {
    sendValue = @"查询余额";
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else {
        
        
        if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
            
            [self performSegueWithIdentifier:@"chaxun" sender:self];
            
        }
        
        if(MiniPosSDKQuery()>=0)
        {
            NSLog(@"正在查询余额...");
        }

        
    }
    

    
}
//签退
- (IBAction)sginOutAction:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else {

        
        if(MiniPosSDKPosLogout()>=0)
        {
            [self showHUD:@"正在签退..."];
        }
    }
    
    

}
//结算
- (IBAction)payoffAction:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else {

        if(MiniPosSDKSettleTradeCMD(NULL)>=0)
        {
            [self showHUD:@"正在结算..."];
        }
        
    }
    
    

}
//更新参数
- (IBAction)updataKeyAction:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showConnectionAlert];
        return;
    }

        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *sn = @"G1000100130";
        NSString *phoneNo = @"13202264038";
        NSString *merchantNo  = [[NSUserDefaults standardUserDefaults] stringForKey:kMposG1MerchantNo];
        NSString *terminalNo  = [[NSUserDefaults standardUserDefaults]stringForKey:kMposG1TerminalNo];
        NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/keyIssued.action?sn=%@&user=%@&mid=%@&tid=%@&flag=0800364",kServerIP,kServerPort,sn,phoneNo,merchantNo,terminalNo];
        NSLog(@"url:%@",url);
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"responseObject:%@",responseObject);
            NSLog(@"msg:%@",responseObject[@"resultMap"][@"msg"]);
            
            int code = [responseObject[@"resultMap"][@"code"]intValue];
            
            if (code == 3 ) {
                
                [self showHUD:@"正在写入参数"];
                
                
                NSString *mainKey  = [self decryptMainKey:responseObject[@"resultMap"][@"tmk"]];
                NSString *tid = responseObject[@"resultMap"][@"tid"];
                NSString *mid = responseObject[@"resultMap"][@"mid"];
                NSLog(@"mainKey:%@",mainKey);
                
                NSDictionary *dictionary = @{@"商户号":mid,@"终端号":tid,@"主密钥1":mainKey};
                
                [self setPosWithParams:dictionary success:nil];
                
                [[NSUserDefaults standardUserDefaults]setObject:mid forKey:kMposG1MerchantNo];
                [[NSUserDefaults standardUserDefaults]setObject:tid forKey:kMposG1TerminalNo];
                [[NSUserDefaults standardUserDefaults]setObject:mainKey forKey:kMposG1MainKey];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                
                
            }else{
                
                [self showTipView:responseObject[@"resultMap"][@"msg"]];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self hideHUD];
            NSLog(@"failure");
            [self showTipView:@"网络异常"];
        }];

    
}



- (IBAction)getDeviceMsgAction:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        
        [self showConnectionAlert];
        return;
    }else {
        
        if(MiniPosSDKGetDeviceInfoCMD()>=0)
        {
            [self showHUD:@"正在获取设备信息"];
                    }
    }
    

}



-(void) showResultWithString:(NSString *)str{
    [self hideHUD];
    [self showTipView:str];
}






#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
     NSLog(@"Hooooooooooooooom");
    
    if (alertView.tag == 44) {
        if (buttonIndex == 0) {
            ConnectDeviceViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CD"];
            [self.navigationController pushViewController:cdvc animated:YES];
            //[self presentViewController:cdvc animated:YES completion:nil];
        }
    }
    
}


#pragma mark - 复写接受方法
- (void)recvMiniPosSDKStatus
{
    
    [super recvMiniPosSDKStatus];
    
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到成功"]]) {
        [self hideHUD];
        NSLog(@"LoginViewController ----签到成功");
        
        [self showTipView:self.statusStr];
    }
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到失败"]]) {
        [self hideHUD];
        NSLog(@"LoginViewController ----签到失败");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"签到失败！" message:self.displayString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
    }
    
    
    if ([self.statusStr isEqualToString:@"签退成功"]){
        
        [self hideHUD];
        
        [self showTipView:self.statusStr];
        
        [self performSelector:@selector(backToLogin) withObject:nil afterDelay:1.0];
        

    }
    
    if ([self.statusStr isEqualToString:@"获取设备信息成功"] ) {
        
        
        
            
            [self hideHUD];
            
            NSString *info = [NSString stringWithFormat:@"机身号:%s\n内核版本：%s\n应用版本：%s\nApp版本：%@",MiniPosSDKGetDeviceID(),MiniPosSDKGetCoreVersion(),MiniPosSDKGetAppVersion(),@"iOS20150604003"];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
            
            SIAlertView *salertView = [[SIAlertView alloc] initWithTitle:NULL andMessage:info];
            [salertView addButtonWithTitle:@"确定"
                                      type:SIAlertViewButtonTypeDefault
                                   handler:^(SIAlertView *alertView) {
                                       
                                   }];
            salertView.cornerRadius = 10;
            salertView.buttonFont = [UIFont boldSystemFontOfSize:15];
            salertView.transitionStyle = SIAlertViewTransitionStyleSlideFromTop;
            [salertView show];
            

    }
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"开始下载"]]) {
        
        
    }
    
    
    if ([self.statusStr isEqualToString:@"结算成功"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }

    
    if ([self.statusStr isEqualToString:@"设备未连接"]) {
       
    }
    
    if ([self.statusStr isEqualToString:@"获取参数成功"]) {
        //NSLog(@"SnNo:%s,TerminalNo:%s,MerchantNo:%s",MiniPosSDKGetParam("SnNo"), MiniPosSDKGetParam("TerminalNo"), MiniPosSDKGetParam("MerchantNo"));
    }
    
    if ([self.statusStr isEqualToString:@"消费响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:@"撤销响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:@"查询余额响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:@"签退响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:@"结算响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:@"获取设备信息响应超时"] ) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    

    
    self.statusStr=@"";
    
    
}


-(void)backToLogin{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
