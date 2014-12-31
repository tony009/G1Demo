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
    
    NSArray *titArray = @[@"消费交易",@"撤销消费",@"查询余额",@"账户签退",@"资金结算",@"设备信息",@"更多"];
    NSArray *imgArray = @[@"btn_gathring.png",@"btn_cancel.png",@"btn_inquire.png",@"btn_sign_out.png",@"btn_settlement.png",@"btn_equipment.png",@"btn_more.png"];
    
    for (int i = 0; i < titArray.count; i++) {
        ImgTButton *button = (ImgTButton *)[self.controlView viewWithTag:i+10];
        button.imageName = [imgArray objectAtIndex:i];
        button.titext = [titArray objectAtIndex:i];
    }
    
    int width = self.view.frame.size.width;
    int height = self.scrollView.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(width*6, height);
    
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(width, 0, width, height)];
    UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(width *2, 0, width, height)];
    UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(width *3, 0, width, height)];
    UIImageView *imageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(width *4, 0, width, height)];
    UIImageView *imageView6 = [[UIImageView alloc]initWithFrame:CGRectMake(width *5, 0, width, height)];

    [imageView1 setImage:[UIImage imageNamed:@"home_banner_1"]];
    [imageView2 setImage:[UIImage imageNamed:@"home_banner_2"]];
    [imageView3 setImage:[UIImage imageNamed:@"home_banner_3"]];
    [imageView4 setImage:[UIImage imageNamed:@"home_banner_4"]];
    [imageView5 setImage:[UIImage imageNamed:@"home_banner_5"]];
    [imageView6 setImage:[UIImage imageNamed:@"home_banner_6"]];
    [self.scrollView addSubview:imageView1];
    [self.scrollView addSubview:imageView2];
    [self.scrollView addSubview:imageView3];
    [self.scrollView addSubview:imageView4];
    [self.scrollView addSubview:imageView5];
    [self.scrollView addSubview:imageView6];
    
    
    self.scrollView.delegate = self;
    
//    UIImageView *leftImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
//    leftImgview.backgroundColor = [UIColor clearColor];
//    leftImgview.image = [UIImage imageNamed:@"icon_logo.png"];
//    
//    UIBarButtonItem *legtItem = [[UIBarButtonItem alloc] initWithCustomView:leftImgview];
//    self.navigationItem.leftBarButtonItem = legtItem;
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MiniPosSDKInit();
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
    
    CGPoint offset = aScrollView.contentOffset;
    self.pageControl.currentPage = offset.x / 320.0f;
    //NSLog(@"scrollViewDidScroll:%d",self.pageControl.currentPage);

}

- (IBAction)changePage:(id)sender {
    NSLog(@"changePage");
    [UIView animateWithDuration:0.3f animations:^{
        int whichPage = self.pageControl.currentPage;
        self.scrollView.contentOffset = CGPointMake(320.0f * whichPage, 0.0f);
    }];
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




- (IBAction)customAction:(ImgTButton *)sender {
 
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
        
        [self performSegueWithIdentifier:@"xiaofei" sender:self];
        
    }else{
        [self showTipView:@"设备繁忙，稍后再试"];
    }
    
    
}

- (IBAction)reCustomAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
        
        [self performSegueWithIdentifier:@"chexiao" sender:self];
    }else {
        [self showTipView:@"设备繁忙，稍后再试"];
    }
    
    
}

- (IBAction)checkAccountAction:(id)sender {
    sendValue = @"查询余额";
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
        
        [self performSegueWithIdentifier:@"chaxun" sender:self];
        
    }
    
    if(MiniPosSDKQuery()>=0)
    {
        NSLog(@"正在查询余额...");
    }
    
}

- (IBAction)sginOutAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    
    if(MiniPosSDKPosLogout()>=0)
    {
        [self showHUD:@"正在签退..."];
    }
}

- (IBAction)payoffAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    
    if(MiniPosSDKSettleTradeCMD(NULL)>=0)
    {
        [self showHUD:@"正在结算..."];
    }
}

- (IBAction)updataKeyAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    if(MiniPosSDKDownloadParamCMD()>=0)
    {
        [self showHUD:@"正在下载参数..."];
    }
    
}

- (IBAction)getDeviceMsgAction:(ImgTButton *)sender {
    
    if(MiniPosSDKDeviceState()<0){
        [self showTipView:@"设备未连接"];
        return;
    }
    
    if(MiniPosSDKGetDeviceInfoCMD()>=0)
    {
        [self showHUD:@"正在获取设备信息"];
        //[self performSelector:@selector(showResultWithString:) withObject:@"获取设备信息超时" afterDelay:10];
    }
}

-(void) showResultWithString:(NSString *)str{
    [self hideHUD];
    [self showTipView:str];
}

- (IBAction)moreAction:(ImgTButton *)sender {
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        DownThread();
//    });
    
    
}




#pragma mark - 
#pragma mark - 复写接受方法
- (void)recvMiniPosSDKStatus
{
    
    [super recvMiniPosSDKStatus];
    

    
    
    if ([self.statusStr isEqualToString:@"签退成功"]){
        
        [self hideHUD];
        
        [self showTipView:self.statusStr];
        
        [self performSelector:@selector(backToLogin) withObject:nil afterDelay:1.0];
        

    }
    
    if ([self.statusStr isEqualToString:@"获取设备信息成功"]) {
        
        [self hideHUD];
        NSString *info = [NSString stringWithFormat:@"机身号:%s\n内核版本：%s\n应用版本：%s",MiniPosSDKGetDeviceID(),MiniPosSDKGetCoreVersion(),MiniPosSDKGetAppVersion()];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if ([self.statusStr isEqualToString:@"结算成功"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }

    
    if ([self.statusStr isEqualToString:@"设备未连接"]) {
        [self bleConnectAction];
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
    
    if ([self.statusStr isEqualToString:@"获取设备信息响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    self.statusStr=@"";
    
    
}


-(void)backToLogin{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)bleConnectAction {
    
    DeviceDriverInterface *t;
    t=GetBLEDeviceInterface();
    MiniPosSDKRegisterDeviceInterface(t);
    
}



@end
