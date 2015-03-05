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
#import "CustomAlertView.h"
#import "AFNetworking.h"
@interface HomeViewController ()
{
    NSTimer *timer;
    NSString *sendValue;
    BOOL isFirstGetVersionInfo;
    BOOL isGetDeviceMsgAction;
    
    NSString *web_kernel;
    NSString *web_task;
    NSString *pos_kernel;
    NSString *pos_task;
    NSMutableArray *updateFiles;
    CustomAlertView *cav;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSubViews];
    
    isFirstGetVersionInfo = true;
    

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
    
    NSArray *titArray = @[@"消费交易",@"撤销消费",@"查询余额",@"账户签退",@"资金结算",@"设备信息",@"固件更新"];
    NSArray *imgArray = @[@"btn_gathring.png",@"btn_cancel.png",@"btn_inquire.png",@"btn_sign_out.png",@"btn_settlement.png",@"btn_equipment.png",@"btn_update.png"];
    
    for (int i = 0; i < titArray.count; i++) {
        ImgTButton *button = (ImgTButton *)[self.controlView viewWithTag:i+10];
        button.imageName = [imgArray objectAtIndex:i];
        button.titext = [titArray objectAtIndex:i];
    }
    
    //int width = self.view.frame.size.width;
    //int height = self.scrollView.frame.size.height;
    //int height = 140;
    
    //int height = self.scrollView.bounds.size.height;
    
   // NSLog(@"%d:%d",width,height);
    

    
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
    
    if (isFirstGetVersionInfo) {
        MiniPosSDKGetDeviceInfoCMD();
        //isFirstGetVersionInfo = false;
    }
    
    
    
    
    int width = self.view.frame.size.width;
    //int height = self.scrollView.frame.size.height;
    //int height = 140;
    
    int height = self.scrollView.bounds.size.height;
    
    NSLog(@"scrollView %d:%d",width,height);
    
    self.scrollView.contentSize = CGSizeMake(width*5, height);
    
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(width, 0, width, height)];
    UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(width *2, 0, width, height)];
    UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(width *3, 0, width, height)];
    UIImageView *imageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(width *4, 0, width, height)];

    
    [imageView1 setImage:[UIImage imageNamed:@"home_banner_1"]];
    [imageView2 setImage:[UIImage imageNamed:@"home_banner_2"]];
    [imageView3 setImage:[UIImage imageNamed:@"home_banner_3"]];
    [imageView4 setImage:[UIImage imageNamed:@"home_banner_4"]];
    [imageView5 setImage:[UIImage imageNamed:@"home_banner_5"]];
    
    [self.scrollView addSubview:imageView1];
    [self.scrollView addSubview:imageView2];
    [self.scrollView addSubview:imageView3];
    [self.scrollView addSubview:imageView4];
    [self.scrollView addSubview:imageView5];
    
    
    
    self.scrollView.delegate = self;
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
        isGetDeviceMsgAction = true;
        //[self performSelector:@selector(showResultWithString:) withObject:@"获取设备信息超时" afterDelay:10];
    }
}

-(void) showResultWithString:(NSString *)str{
    [self hideHUD];
    [self showTipView:str];
}

- (IBAction)updateAction:(ImgTButton *)sender {
    
    
     [self downloadWebVersionFile];

//    updateFiles = [[NSMutableArray alloc]init];
//    
//    [updateFiles addObject:@"kernel"];
//    [updateFiles addObject:@"task"];
//
//    [self downloadFromWebAndTransmitToPos];
}

//从服务器下载版本文件
- (void)downloadWebVersionFile{
    
    if(isFirstGetVersionInfo==false){
        [self showHUD:@"正在从服务器获取版本信息"];
    }
    
    // 1
    NSString *baseURLString = @"http://120.24.213.123/app/version.json";
    NSURL *url = [NSURL URLWithString:baseURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *str = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/version.json"];
    
    operation.inputStream = [NSInputStream inputStreamWithURL:url];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:str append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideHUD];
    
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:str] options:kNilOptions error:NULL];
        
        NSLog(@"%@",dictionary);
        
        NSDictionary *g1 = dictionary[@"G1"];
        
        web_kernel = g1[@"kernel"];
        web_task = g1[@"task"];
        
        NSString *message = [NSString stringWithFormat:@"web_kernel:%@\nweb_task:%@",web_kernel,web_task];
        
        NSLog(@"message:%@",message);
        
        
        //成功就获取本地版本号
        [self getPosVersionInfo];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        [self hideHUD];
        [self showTipView:@"获取失败,请检查网络"];
        
    }];
    
    // 5
    [operation start];
    
    
}


//从POS机获取版本信息
- (void)getPosVersionInfo{
    
    //MiniPosSDKGetDeviceInfoCMD();
    
    if(pos_kernel && pos_task){
        [self compareVersionInfo];
    }
}

//比较版本信息
- (void)compareVersionInfo{
    
    updateFiles = [[NSMutableArray alloc]init];
    
    
    if ([pos_kernel compare:web_kernel options:NSNumericSearch] == NSOrderedAscending) {
        [updateFiles addObject:@"kernel"];
    }
    
    if ([pos_task compare:web_task options:NSNumericSearch] == NSOrderedAscending)
    {
        [updateFiles addObject:@"task"];
    }
    

    if([updateFiles count]>0){
        
        NSString *info = [NSString stringWithFormat:@"有%i个文件需要更新，预计耗时%i分钟",[updateFiles count],[updateFiles count]*5];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定更新", nil];
        
        [alert show];
        
    }else if(isFirstGetVersionInfo==false){
        
        NSString *info = [NSString stringWithFormat:@"您的软件是最新版本"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    
    isFirstGetVersionInfo = false;
    
    
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex ==1) {
        [self downloadFromWebAndTransmitToPos ];
    }
    
}

//
- (void)downloadFromWebAndTransmitToPos{
    
    
    
    if ([updateFiles count]>0) {
        
        cav = [[CustomAlertView alloc]init];
        
        [self.view addSubview:cav];
        [cav show];
        
        [self download:updateFiles[0] CompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"download %@ success",updateFiles[0]);
            if ([updateFiles count] >1) {
                [self download:updateFiles[1] CompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    MiniPosSDKDownPro();
                    
                    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        DownThread((__bridge void*)cav,updateFiles);
                        
                        [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
                        

                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [cav dismiss];
                        });
                        
                    });
                    

                    
                }];
            }else{
                
                MiniPosSDKDownPro();
                
                [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    DownThread((__bridge void*)cav,updateFiles);
                    
                    [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [cav dismiss];
                    });
                    
                });
                
                
            }
            
        }];
    }else{
        
        //[self showTipView:@"您的软件是最新版本"];
    }
    
}


- (void)download:(NSString *)fileName CompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success{
    
    if (fileName ==nil) {
        return;
    }
    
        NSString *baseURLString = [NSString stringWithFormat:@"http://120.24.213.123/app/%@",fileName];
        NSURL *baseURL = [NSURL URLWithString:baseURLString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:baseURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        NSString *str = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
        NSLog(@"%@",baseURLString);
        NSLog(@"%@",str);
        
        operation.inputStream = [NSInputStream inputStreamWithURL:baseURL];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:str append:NO];
        
        
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"%@ is download：%f",fileName, (float)totalBytesRead/totalBytesExpectedToRead);
            //self.progressView set
            float progress = (float)totalBytesRead/totalBytesExpectedToRead;
            
            
            [cav updateProgress:progress];
            [cav updateTitle:[NSString stringWithFormat:@"正在下载%@",fileName]];
             
            
             }];
            
            //NSString *filePath = [NSString alloc]in
            
            [operation setCompletionBlockWithSuccess:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failure");
            }];
            
            [operation start];
    
    
            NSLog(@"download,%@",fileName);
    
  
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
    
    if ([self.statusStr isEqualToString:@"获取设备信息成功"] ) {
        
        
        if (isGetDeviceMsgAction) {
            
            [self hideHUD];
            
            NSString *info = [NSString stringWithFormat:@"机身号:%s\n内核版本：%s\n应用版本：%s\nApp版本：%@",MiniPosSDKGetDeviceID(),MiniPosSDKGetCoreVersion(),MiniPosSDKGetAppVersion(),@"iOS20150210003"];
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
            
            isGetDeviceMsgAction = false;
        }else{
            
            pos_kernel = [NSString stringWithCString:MiniPosSDKGetCoreVersion() encoding:NSASCIIStringEncoding];
            pos_task = [NSString stringWithCString:MiniPosSDKGetAppVersion() encoding:NSASCIIStringEncoding];
            
            NSString *message = [NSString stringWithFormat:@"pos_kernel:%@\npos_task:%@",pos_kernel,pos_task];
            
        
            NSLog(@"message:%@",message);
            
            [self downloadWebVersionFile];

        }

        
    }
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"开始下载"]]) {
        
        
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
    
    if ([self.statusStr isEqualToString:@"获取设备信息响应超时"] && isGetDeviceMsgAction) {
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
