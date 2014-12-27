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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(run) userInfo:NULL repeats:YES];
    
    MiniPosSDKAddDelegate((__bridge void*)self, MiniPosSDKResponce);
    
}

-(void)run{
    MiniPosSDKRunThread();
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [timer invalidate];
    
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
    
    
    
    //NSLog(@"MiniPosSDKResponce sessionType: %d responceCode: %d",self.sessionType,self.responceCode);
    
    //[self performSelectorOnMainThread:@selector(deviceStatus) withObject:nil waitUntilDone:NO];
    
    
    [self deviceStatus];
}


- (void) deviceStatus
{
    //NSLog(@"deviceStatus sessionType: %d responceCode: %d",self.sessionType,self.responceCode);
    if ((int)(self.responceCode) < 0 || self.responceCode == SESSION_ERROR_SHAKE_PACK) {
        
        return;
    }
    
    NSLog(@"MiniPosSDKResponce sessionType: %d(%@) responceCode: %d(%@)",self.sessionType,[self getSesstionTypeString:self.sessionType],self.responceCode,[self getResponceCodeString:self.responceCode]);
    
    if(self.responceCode==SESSION_ERROR_ACK)
    {
        if(self.sessionType==SESSION_POS_LOGIN)
        {
            self.statusStr=@"签到成功";
            NSLog(@"deviceStatus ------签到成功");
        }
        else if(self.sessionType==SESSION_POS_LOGOUT)
        {
            self.statusStr=@"签退成功";
            NSLog(@"deviceStatus ------签到成功");
        }
        else if(self.sessionType==SESSION_POS_SALE_TRADE)
        {
            self.statusStr=@"消费成功";
        }
        else if(self.sessionType==SESSION_POS_VOIDSALE_TRADE)
        {
            self.statusStr=@"撤销消费成功";
            NSLog(@"deviceStatus ------撤销消费成功");
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

            
            //[self performSelectorOnMainThread:@selector(recvMiniPosSDKStatus) withObject:nil waitUntilDone:NO];
            
            //[self recvMiniPosSDKStatus];
            
            //return;
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
        
       // self.statusStr = [NSString stringWithFormat:@"%@ [%@ %@]",self.statusStr,self.codeString,self.displayString];
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
        
        //self.statusStr = [NSString stringWithFormat:@"%@ [%@ %@]",self.statusStr,self.codeString,self.displayString];
    }
    else if(self.responceCode==SESSION_ERROR_DEVICE_PLUG_IN)
    {
        NSLog(@"deviceStatus:设备已插入");
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
        if(self.sessionType==SESSION_POS_LOGIN)
        {
            self.statusStr=@"签到响应超时";
        }
        else if(self.sessionType==SESSION_POS_LOGOUT)
        {
            self.statusStr=@"签退响应超时";
        }
        else if(self.sessionType==SESSION_POS_SALE_TRADE)
        {
            self.statusStr=@"消费响应超时";
        }
        else if(self.sessionType==SESSION_POS_VOIDSALE_TRADE)
        {
            self.statusStr=@"撤销响应超时";
        }
        else if(self.sessionType==SESSION_POS_QUERY)
        {
            self.statusStr=@"查询余额响应超时";
        }
        else if(self.sessionType==SESSION_POS_SETTLE)
        {
            self.statusStr=@"结算响应超时";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_KEY)
        {
            self.statusStr=@"下载公钥响应超时";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_AID_PARAM)
        {
            self.statusStr=@"下载AID参数响应超时";
        }
        else if(self.sessionType==SESSION_POS_DOWNLOAD_PARAM)
        {
            self.statusStr=@"下载参数响应超时";
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_INFO)
        {
            self.statusStr=@"获取设备信息响应超时";
        }
        else if(self.sessionType==SESSION_POS_GET_DEVICE_ID)
        {
            self.statusStr=@"获取设备序列号响应超时";
        }
        else if(self.sessionType==SESSION_POS_READ_CARD_INFO)
        {
            self.statusStr=@"获取磁道信息响应超时";
        }
        else if(self.sessionType==SESSION_POS_READ_PIN_CARD_INFO)
        {
            self.statusStr=@"获取磁道密码响应超时";
        }
        else if(self.sessionType==SESSION_POS_READ_IC_INFO)
        {
            self.statusStr=@"读取IC卡响应超时";
        }
        else if(self.sessionType==SESSION_POS_UPDATE_KEY)
        {
            self.statusStr=@"更新密钥响应超时";
        }
        else if(self.sessionType==SESSION_POS_CANCEL_READ_CARD)
        {
            self.statusStr=@"中断刷卡响应超时";
        }
        
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
    
    //[self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
    
    //[self performSelectorOnMainThread:@selector(recvMiniPosSDKStatus) withObject:nil waitUntilDone:NO];

    // [self startTimer];
    [self recvMiniPosSDKStatus];
    //[self stopTimer];
}




-(NSString *)getSesstionTypeString:(MiniPosSDKSessionType)type{
    switch (type) {
        case SESSION_POS_UNKNOWN:
            return @"SESSION_POS_UNKNOWN";
            break;
        case SESSION_POS_LOGIN:
            return @"SESSION_POS_LOGIN";
            break;
        case SESSION_POS_GET_DEVICE_INFO:
            return @"SESSION_POS_GET_DEVICE_INFO";
            break;
        case SESSION_POS_SALE_TRADE:
            return @"SESSION_POS_SALE_TRADE";
            break;
        case SESSION_POS_VOIDSALE_TRADE:
            return @"SESSION_POS_VOIDSALE_TRADE";
            break;
        case SESSION_POS_QUERY:
            return @"SESSION_POS_QUERY";
            break;
        case SESSION_POS_SETTLE:
            return @"SESSION_POS_SETTLE";
            break;
        case SESSION_POS_DOWNLOAD_KEY:
            return @"SESSION_POS_DOWNLOAD_KEY";
            break;
        case SESSION_POS_DOWNLOAD_AID_PARAM:
            return @"SESSION_POS_DOWNLOAD_AID_PARAM";
            break;
        case SESSION_POS_DOWNLOAD_PARAM:
            return @"SESSION_POS_DOWNLOAD_PARAM";
        case SESSION_POS_PRINT:
            return @"SESSION_POS_PRINT";
            break;
        case SESSION_POS_GET_DEVICE_ID:
            return @"SESSION_POS_GET_DEVICE_ID";
            break;
        case SESSION_POS_CANCEL_READ_CARD:
            return @"SESSION_POS_CANCEL_READ_CARD";
            break;
        case SESSION_POS_READ_CARD_INFO:
            return @"SESSION_POS_READ_CARD_INFO";
            break;
        case SESSION_POS_READ_PIN_CARD_INFO:
            return @"SESSION_POS_READ_PIN_CARD_INFO";
            break;
        case SESSION_POS_READ_IC_INFO:
            return @"SESSION_POS_READ_IC_INFO";
            break;
        case SESSION_POS_UPDATE_KEY:
            return @"SESSION_POS_UPDATE_KEY";
            break;
        case SESSION_POS_LOGOUT:
            return @"SESSION_POS_LOGOUT";
            break;
        default:
            return @"";
            break;
    }
}

-(NSString *)getResponceCodeString:(int)type{
    switch (type) {
        case SESSION_ERROR_ACK:
            return @"SESSION_ERROR_ACK";
            break;
        case SESSION_ERROR_NAK:
            return @"SESSION_ERROR_NAK";
            break;
        case SESSION_ERROR_NO_REGISTE_INTERFACE:
            return @"SESSION_ERROR_NO_REGISTE_INTERFACE";
            break;
        case SESSION_ERROR_NO_DEVICE:
            return @"SESSION_ERROR_NO_DEVICE";
            break;
        case SESSION_ERROR_DEVICE_PLUG_IN:
            return @"SESSION_ERROR_DEVICE_PLUG_IN";
            break;
        case SESSION_ERROR_DEVICE_PLUG_OUT:
            return @"SESSION_ERROR_DEVICE_PLUG_OUT";
            break;
        case SESSION_ERROR_DEVICE_NO_RESPONCE:
            return @"SESSION_ERROR_DEVICE_NO_RESPONCE";
            break;
        case SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT:
            return @"SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT";
            break;
        case SESSION_ERROR_SEND_8583_ERROR:
            return @"SESSION_ERROR_SEND_8583_ERROR";
            break;
        case SESSION_ERROR_RECIVE_8583_ERROR:
            return @"SESSION_ERROR_RECIVE_8583_ERROR";
            break;
        case SESSION_ERROR_NO_SET_PARAM:
            return @"SESSION_ERROR_NO_SET_PARAM";
            break;
        case SESSION_ERROR_DEVICE_BUSY:
            return @"SESSION_ERROR_DEVICE_BUSY";
            break;
        case SESSION_ERROR_DEVICE_SEND:
            return @"SESSION_ERROR_DEVICE_SEND";
            break;
        case SESSION_ERROR_SHAKE_PACK:
            return @"SESSION_ERROR_SHAKE_PACK";
            break;
        default:
            return @"";
            break;
    }
}

-(void)startTimer
{
    [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(stopTimer) userInfo:NULL repeats:NO];
}

- (void)stopTimer
{
    MiniPosSDKSessionType sessionType = self.sessionType;
    

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
    
    
    [self recvMiniPosSDKStatus];
}


- (void)recvMiniPosSDKStatus
{
    //NSLog(@"self.statusStr = %@",self.statusStr);
    //self.statusStr=@"设备繁忙，稍后再试";
    if ([self.statusStr isEqualToString:@"设备繁忙，稍后再试"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
}




@end
