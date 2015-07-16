//
//  DemoTestViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/7/16.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "DemoTestViewController.h"
#import "MiniPosSDK.h"
#import "BLEDriver.h"
#import "DeviceInterface.h"
@interface DemoTestViewController (){
    NSTimer *timer;
}

@end

@implementation DemoTestViewController

static void MiniPosSDKResponce(void *userData,
                               MiniPosSDKSessionType sessionType,
                               MiniPosSDKSessionError responceCode,
                               const char *deviceResponceCode,
                               const char *displayInfo)
{
    printf("MiniPosSDKResponce sessionType: %d responceCode: %d\n",sessionType,responceCode);
    
    if(responceCode==SESSION_ERROR_NO_REGISTE_INTERFACE)
    {
        printf("没有注册设备与手机之间的通讯驱动\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_NO_SET_PARAM)
    {
        printf("没有设置参数\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_NO_DEVICE)
    {
        printf("没有检测到设备\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_PLUG_IN)
    {
        printf("设备已经插入\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_PLUG_OUT)
    {
        printf("设备已经拔出\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_NO_RESPONCE)
    {
        printf("设备对请求没有响应\n");
        return;
    }
    
    if(sessionType==SESSION_POS_LOGIN)
    {
        if(responceCode==SESSION_ERROR_ACK)
        {
            printf("签到成功\n");
        }
        else if(responceCode==SESSION_ERROR_NAK)
        {
            printf("签到失败 %s %s\n",deviceResponceCode?deviceResponceCode:" ",displayInfo?displayInfo:" ");
        }
    }
    else if(sessionType==SESSION_POS_SALE_TRADE)
    {
        if(responceCode==SESSION_ERROR_ACK)
        {
            printf("消费成功\n");
        }
        else if(responceCode==SESSION_ERROR_NAK)
        {
            printf("消费失败 %s %s\n",deviceResponceCode?deviceResponceCode:" ",displayInfo?displayInfo:" ");
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //第一步，初始化SDK
    MiniPosSDKInit();
    
    //第二步，注册与设备通讯驱动
    MiniPosSDKRegisterDeviceInterface(GetBLEDeviceInterface());
//
//    //第三步，注册SDK回调函数
//    MiniPosSDKAddDelegate((__bridge void*)self, MiniPosSDKResponce);
//    
//    //第四步，调用交易请求函数
//     MiniPosSDKPosLogin();
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signin:(id)sender {
    
    
    if (MiniPosSDKDeviceState() == 0) {
        MiniPosSDKPosLogin();
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
