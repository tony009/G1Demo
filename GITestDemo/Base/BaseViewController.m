//
//  BaseViewController.m
//  MovePower
//
//  Created by Femto03 on 14-6-5.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

#import "LPPopup.h"

@interface BaseViewController ()
{
    NSTimer *timer;
}
@end

@implementation BaseViewController

#pragma mark - HUB
//显示加载
- (void)showHUD:(NSString *)title {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = title;
}

- (void)showHUDDelayHid:(NSString *)title {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = title;
    
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1];
}

//隐藏加载
- (void)hideHUD {
    [self.hud hide:YES];
    
}

//隐藏加载显示加载完成提示
- (void)hideHUDWithTitle:(NSString *)title
{
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    
    self.hud.labelText = title;
    [self.hud hide:YES afterDelay:1];
    
}

#pragma mark -
#pragma mark - show tip
- (void)showTipView:(NSString *)tip
{
    LPPopup *popup = [LPPopup popupWithText:tip];
    popup.popupColor = [UIColor blackColor];
    popup.textColor = [UIColor whiteColor];
    
    [popup showInView:self.view
        centerAtPoint:self.view.center
             duration:kLPPopupDefaultWaitDuration
           completion:nil];
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =rgb(245, 245, 245, 1);
    
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 50, 50);
        leftButton.backgroundColor = [UIColor clearColor];
        [leftButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    

}

- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    MiniPosSDKAddDelegate((__bridge void*)self, MiniPosSDKResponce);
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    MiniPosSDKRemoveDelegate((__bridge void*)self);
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


static void MiniPosSDKResponce(void *userData,
                               MiniPosSDKSessionType sessionType,
                               MiniPosSDKSessionError responceCode,
                               const char *deviceResponceCode,
                               const char *displayInfo)
{
    BaseViewController *self = (__bridge BaseViewController*)userData;
    
    self.sessionType=sessionType;
    self.responceCode=responceCode;
    
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    if(deviceResponceCode)
        self.codeString=[NSMutableString stringWithCString:deviceResponceCode encoding:encode];
    else
        self.codeString=[[NSMutableString alloc] init];
    
    if(displayInfo)
        self.displayString=[NSMutableString stringWithCString:displayInfo encoding:encode];
    else
        self.displayString=[[NSMutableString alloc] init];
    
    [self performSelectorOnMainThread:@selector(deviceStatus) withObject:nil waitUntilDone:NO];
    
    NSLog(@"MiniPosSDKResponce sessionType: %d responceCode: %d",sessionType,responceCode);
}


- (void) deviceStatus
{
    //NSLog(@"deviceStatus sessionType: %d responceCode: %d",self.sessionType,self.responceCode);
    if(self.responceCode==SESSION_ERROR_ACK)
    {
        if(self.sessionType==SESSION_POS_LOGIN)
        {
            self.statusStr=@"签到成功";
        }
        else if(self.sessionType==SESSION_POS_LOGOUT)
        {
            self.statusStr=@"签退成功";
        }
        else if(self.sessionType==SESSION_POS_SALE_TRADE)
        {
            self.statusStr=@"消费成功";
        }
        else if(self.sessionType==SESSION_POS_VOIDSALE_TRADE)
        {
            self.statusStr=@"撤销消费成功";
        }
        else if(self.sessionType==SESSION_POS_QUERY)
        {
            self.statusStr=@"查询余额成功";
        }
        else if(self.sessionType==SESSION_POS_SETTLE)
        {
            self.statusStr=@"结算成功";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_KEY)
        {
            self.statusStr=@"下载公钥成功";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_AID_PARAM)
        {
            self.statusStr=@"下载AID参数成功";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_PARAM)
        {
            self.statusStr=@"下载参数成功";
        }
        else if(self.sessionType==SESSION_POS_CANCEL_READ_CARD)
        {
            self.statusStr=@"中断刷卡成功";
        }
        else if(self.sessionType==SESSION_POS_READ_IC_INFO)
        {
            self.statusStr=@"读取IC卡成功";
        }
        else if(self.sessionType==SESSION_POS_UPDATE_KEY)
        {
            self.statusStr=@"更新密钥成功";
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_INFO)
        {
            self.statusStr=@"获取设备信息成功";
            NSString *info = [NSString stringWithFormat:@"设备ID:%s\nCore版本号：%s\n应用版本号：%s",MiniPosSDKGetDeviceID(),MiniPosSDKGetCoreVersion(),MiniPosSDKGetAppVersion()];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
            [self performSelectorOnMainThread:@selector(recvMiniPosSDKStatus) withObject:nil waitUntilDone:NO];
            
            return;
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_ID)
        {
            self.statusStr=@"获取设备序列号成功";
            NSString *info = [NSString stringWithFormat:@"设备ID:%s",MiniPosSDKGetDeviceID()];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else if(self.sessionType==SESSION_POS_READ_CARD_INFO)
        {
            self.statusStr=@"获取磁道信息成功";
            NSString *info = [NSString stringWithFormat:@"磁道二: %s\n磁道三:%s\n磁道一：%s",MiniPosSDKGetTrack2(),MiniPosSDKGetTrack3(),MiniPosSDKGetTrack1()];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else if(self.sessionType==SESSION_POS_READ_PIN_CARD_INFO)
        {
            self.statusStr=@"获取磁道和密码信息成功";
            NSString *info = [NSString stringWithFormat:@"加密后卡密:%s\n磁道二: %s\n磁道三:%s\n磁道一：%s",MiniPosSDKGetEncryptPin(),MiniPosSDKGetTrack2(),MiniPosSDKGetTrack3(),MiniPosSDKGetTrack1()];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        self.statusStr = [NSString stringWithFormat:@"%@ [%@ %@]",self.statusStr,self.codeString,self.displayString];
    }
    else if(self.responceCode==SESSION_ERROR_NAK)
    {
        if(self.sessionType==SESSION_POS_LOGIN)
        {
            self.statusStr=@"签到失败";
        }
        else if(self.sessionType==SESSION_POS_LOGOUT)
        {
            self.statusStr=@"签退失败";
        }
        else if(self.sessionType==SESSION_POS_SALE_TRADE)
        {
            self.statusStr=@"消费失败";
        }
        else if(self.sessionType==SESSION_POS_VOIDSALE_TRADE)
        {
            self.statusStr=@"撤销消费失败";
        }
        else if(self.sessionType==SESSION_POS_QUERY)
        {
            self.statusStr=@"查询余额失败";
        }
        else if(self.sessionType==SESSION_POS_SETTLE)
        {
            self.statusStr=@"结算失败";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_KEY)
        {
            self.statusStr=@"下载公钥失败";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_AID_PARAM)
        {
            self.statusStr=@"下载AID参数失败";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_PARAM)
        {
            self.statusStr=@"下载参数失败";
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_INFO)
        {
            self.statusStr=@"获取设备信息失败";
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_ID)
        {
            self.statusStr=@"获取设备序列号失败";
        }
        else if(self.sessionType==SESSION_POS_READ_CARD_INFO)
        {
            self.statusStr=@"获取磁道信息失败";
        }
        else if(self.sessionType==SESSION_POS_READ_PIN_CARD_INFO)
        {
            self.statusStr=@"获取磁道密码失败";
        }
        else if(self.sessionType==SESSION_POS_READ_IC_INFO)
        {
            self.statusStr=@"读取IC卡失败";
        }
        else if(self.sessionType==SESSION_POS_UPDATE_KEY)
        {
            self.statusStr=@"更新密钥失败";
        }
        else if(self.sessionType==SESSION_POS_CANCEL_READ_CARD)
        {
            self.statusStr=@"中断刷卡失败";
        }
        
        self.statusStr = [NSString stringWithFormat:@"%@ [%@ %@]",self.statusStr,self.codeString,self.displayString];
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_PLUG_IN)
    {
        self.statusStr=@"设备已插入";
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_PLUG_OUT)
    {
        self.statusStr=@"设备已拔出";
    }
    else if(self.responceCode==SESSION_ERROR_NO_DEVICE)
    {
        self.statusStr=@"未找到设备";
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_NO_RESPONCE)
    {
        self.statusStr=@"设备没有响应";
    }
    else if(self.responceCode==SESSION_ERROR_NAK)
    {
        self.statusStr=@"设备拒绝会话";
    }
    else if(self.responceCode==SESSION_ERROR_SEND_8583_ERROR)
    {
        self.statusStr=@"发送8583包错误";
    }
    else if(self.responceCode==SESSION_ERROR_RECIVE_8583_ERROR)
    {
        self.statusStr=@"接收8583包错误";
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT)
    {
        self.statusStr=@"设备响应超时";
    }
    else if(self.responceCode==SESSION_ERROR_NO_REGISTE_INTERFACE)
    {
        self.statusStr=@"没有注册驱动";
    }
    else if(self.responceCode==SESSION_ERROR_NO_SET_PARAM)
    {
        self.statusStr=@"没有设置参数";
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_BUSY)
    {
        self.statusStr=@"设备繁忙，稍后再试";
    }
    
    [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(recvMiniPosSDKStatus) withObject:nil waitUntilDone:NO];
}


-(void)startTimer
{
    [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(stopTimer) userInfo:NULL repeats:NO];
}

- (void)stopTimer
{
    MiniPosSDKSessionType sessionType = MiniPosSDKGetCurrentSessionType();
    
    if(sessionType==SESSION_POS_UNKNOWN)
    {
        if(MiniPosSDKDeviceState()==0)
        {
            self.statusStr=@"设备已连接";
        }
        else
        {
            self.statusStr=@"设备未连接";
        }
    }
    else
    {
        if(sessionType==SESSION_POS_LOGIN)
        {
            self.statusStr=@"正在签到";
        }
        else if(sessionType==SESSION_POS_LOGOUT)
        {
            self.statusStr=@"正在签退";
        }
        else if(sessionType==SESSION_POS_GET_DEVICE_INFO)
        {
            self.statusStr=@"正在获取设备信息";
        }
        else if(sessionType==SESSION_POS_SALE_TRADE)
        {
            self.statusStr=@"正在消费";
        }
        else if(sessionType==SESSION_POS_VOIDSALE_TRADE)
        {
            self.statusStr=@"正在撤销消费";
        }
        else if(sessionType==SESSION_POS_QUERY)
        {
            self.statusStr=@"正在查余";
        }
        else if(sessionType==SESSION_POS_SETTLE)
        {
            self.statusStr=@"正在结算";
        }
        else if(sessionType==SESSION_POS_DOWNLOAD_KEY)
        {
            self.statusStr=@"正在下载公钥";
        }
        else if(sessionType==SESSION_POS_DOWNLOAD_AID_PARAM)
        {
            self.statusStr=@"正在下载AID参数";
        }
        else if(sessionType==SESSION_POS_DOWNLOAD_PARAM)
        {
            self.statusStr=@"正在下载参数";
        }
    }
    
    [self recvMiniPosSDKStatus];
}


- (void)recvMiniPosSDKStatus
{
    //NSLog(@"self.statusStr = %@",self.statusStr);
}




@end
