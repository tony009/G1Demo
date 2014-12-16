//
//  HomeViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "HomeViewController.h"
#import "ImgTButton.h"
#import "SwipingCardViewController.h"

@interface HomeViewController ()
{
    NSTimer *timer;
    NSString *sendValue;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSubViews];
    
  
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)_initSubViews
{
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    //    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    //    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    NSArray *titArray = @[@"消费交易",@"撤销消费",@"查询余额",@"账户签退",@"资金结算",@"参数更新",@"设备信息",@"更多"];
    NSArray *imgArray = @[@"btn_gathring.png",@"btn_cancel.png",@"btn_inquire.png",@"btn_sign_out.png",@"btn_settlement.png",@"btn_data_revision.png",@"btn_equipment.png",@"btn_more.png"];
    
    for (int i = 0; i < titArray.count; i++) {
        ImgTButton *button = (ImgTButton *)[self.controlView viewWithTag:i+10];
        button.imageName = [imgArray objectAtIndex:i];
        button.titext = [titArray objectAtIndex:i];
    }
    
    
//    UIImageView *leftImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
//    leftImgview.backgroundColor = [UIColor clearColor];
//    leftImgview.image = [UIImage imageNamed:@"icon_logo.png"];
//    
//    UIBarButtonItem *legtItem = [[UIBarButtonItem alloc] initWithCustomView:leftImgview];
//    self.navigationItem.leftBarButtonItem = legtItem;
    
    
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UIViewController *send=segue.destinationViewController;
    if ([send respondsToSelector:@selector(setType:)]) {
        [send setValue:sendValue forKey:@"type"];
    }
    
    
}




- (IBAction)customAction:(ImgTButton *)sender {
}

- (IBAction)reCustomAction:(ImgTButton *)sender {
}

- (IBAction)checkAccountAction:(id)sender {
    sendValue = @"查询余额";
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKQuery()>=0)
    {
        NSLog(@"正在查询余额...");
    }
    
}

- (IBAction)sginOutAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKPosLogout()>=0)
    {
        [self showHUD:@"正在签退..."];
    }
}

- (IBAction)payoffAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKSettleTradeCMD(NULL)>=0)
    {
        [self showHUD:@"正在结算..."];
    }
}

- (IBAction)updataKeyAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKDownloadParamCMD()>=0)
    {
        [self showHUD:@"正在下载参数..."];
    }
    
}

- (IBAction)getDviceMsgAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKGetDeviceInfoCMD()>=0)
    {
        [self showHUD:@"正在获取设备信息"];
    }
}

- (IBAction)moreAction:(ImgTButton *)sender {
}


#pragma mark - 
#pragma mark - 复写接受方法
- (void)recvMiniPosSDKStatus
{
    
    [super recvMiniPosSDKStatus];
    [self hideHUD];
    
    [self showTipView:self.statusStr];
    
    
    if ([self.statusStr isEqualToString:@"签退成功"]){
        [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:nil afterDelay:1.0];
    }
    
    if ([self.statusStr isEqualToString:@"设备未连接"]) {
        [self bleConnectAction];
    }
    
    
}


- (void)bleConnectAction {
    
    DeviceDriverInterface *t;
    t=GetBLEDeviceInterface();
    MiniPosSDKRegisterDeviceInterface(t);
    
}



@end
