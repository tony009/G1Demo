//
//  PrintNoteViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "PrintNoteViewController.h"
#import "UIUtils.h"
#import "Anasis8583Pack.h"
#import "PPSSignatureView.h"
#import "FTPManager.h"


@interface PrintNoteViewController ()
{
    NSString *_typeStr;
    NSString *_dateStr;
    NSString *_countStr;
    
    
    NSString *_shangHuHao; //商户号
    NSString *_zhongDuanHao; //终端号
    NSString *_jiaoYiShiJian; //交易时间
    NSString *_jiaoYiCanKaoHao; //交易参考号
    
    
    NSString *_qingSuanRiQi; //清算日期
    
    NSString *_jiaoYiTeZhengMa; //交易特征码

    FMServer* server;
    FTPManager* man;
    
}



@end

@implementation PrintNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [self _initSubViews];

    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self startAnimation];
    
}

- (void)_initSubViews
{
    self.title = self.type;
    
    self.bgScrollView.layer.cornerRadius  = 5.0;
    self.bgScrollView.layer.masksToBounds = YES;
    
    if ([self.type isEqualToString:@"消费交易"]) {
        self.topLabel1.text = @"消费：";
        self.topLastLabel.text = @"元";
        _typeStr = @"消费";
        self.countLabel.text = [NSString stringWithFormat:@"%.2f",self.count];
        self.tipLabel.text = @"消费成功，票据正在打印中";
        NSLog(@"消费成功，票据正在打印中");
    } else if ([self.type isEqualToString:@"撤销消费"]){
        self.topLabel1.text = @"撤销：";
        _typeStr = @"撤销";
        self.topLastLabel.text = @"元";
        self.countLabel.text = [NSString stringWithFormat:@"%.2f",self.count];
        self.tipLabel.text = @"撤销成功，票据正在打印中";
    }
    self.countLabel.width = [UIUtils getWithWithString:self.countLabel.text font:27];
    self.topLastLabel.left = self.countLabel.right;
    
    
    
    //终端号
    NSData *terCodeData = [NSData dataWithBytes:(const void *)gTerminalCode length:sizeof( char)*8];
    NSString *terCodeString = [[NSString alloc] initWithData:terCodeData encoding:NSUTF8StringEncoding];
    
    _zhongDuanHao = terCodeString;
    
    //商户号
    NSData *mcCodeData = [NSData dataWithBytes:(const void *)gMerchantCode length:sizeof( char)*15];
    NSString *mcCodeString = [[NSString alloc] initWithData:mcCodeData encoding:NSUTF8StringEncoding];
    
    _shangHuHao = mcCodeString;

    //参考号
    //gRetrieval[12]
    NSData *reCodeData = [NSData dataWithBytes:(const void *)gRetrieval length:sizeof( char)*12];
    NSString *reCodeString = [[NSString alloc] initWithData:reCodeData encoding:NSUTF8StringEncoding];
    
    _jiaoYiCanKaoHao = reCodeString;
    
    //交易金额
    //gTransacAmount[6]
    int transacAmount = BCDToInt(gTransacAmount, 6);
    _countStr = [NSString stringWithFormat:@"%d.%.2d",transacAmount/100,transacAmount%100];
//    NSData *tranCodeData = [NSData dataWithBytes:(const void *)gTransacAmount length:sizeof( char)*6];
//    NSString *tranCodeString = [[NSString alloc] initWithData:mcCodeData encoding:NSUTF8StringEncoding];
    
    self.countLabel.text = _countStr;
    //卡号
    char str[30];
    memset(str, 0x00, sizeof(str));
    
    for (int j = 0; j <= 20; j++) {
        NSLog(@"****** %.2x",gPriAccount[j]);
    }
    
    HexToStr((void *)gPriAccount, (void *)str, 20);
    for(int i = 0; i < 20; i++)
    {
        if(isdigit(str[i]) == 0)
        {
            str[i] = 0x00;
            break;
        }
        
        NSLog(@"act ---- %c  %d",str[i],i);
        
    }
    str[gPriAccountLen] = 0;
    memset(&str[6], '*', strlen(str) - 10);
    NSString *s = @"";
    for (int t=1;t<=strlen(str);t++)
    {
        s=[NSString stringWithFormat:@"%@%c",s,str[t-1]];
    }
    
    
    
    //凭证号  gSysTraceAudit[3]
    int sysTraceAudit = BCDToInt(gSysTraceAudit, 3);
    NSString *audCodeString = [NSString stringWithFormat:@"%.6d",sysTraceAudit];
    
    //时间 gLocalTime[3]
    int time = BCDToInt(gLocalTime, 3);
    int date = BCDToInt(gLocalDate, 2);
    
    
    NSDate *d = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy"];
     
    NSString *year = [dateFormatter stringFromDate:d];
    NSLog(@"date:%d",date);
    _dateStr = [NSString stringWithFormat:@"%04d/%02d/%02d %02d:%02d:%02d",[year intValue],date/100,date%100,time/10000,(time%10000)/100,time%100];
    
    _jiaoYiShiJian = [NSString stringWithFormat:@"%04d%02d%02d",[year intValue],date/100,date%100];
    
    
    _qingSuanRiQi = [NSString stringWithFormat:@"%02d%02d",date/100,date%100];
    
    NSString *temp = [_qingSuanRiQi stringByAppendingString:_jiaoYiCanKaoHao];
    
    NSLog(@"temp:%@",temp);
    
    char *c1 = [[temp substringToIndex:8] cStringUsingEncoding:NSASCIIStringEncoding];
    char *c2 = [[temp substringFromIndex:8]cStringUsingEncoding:NSASCIIStringEncoding];
    
//    char *c1 = "12231234";
//    char *c2 = "56781234";
    char c3[9];
    
    int i1,i2,i3;
    for (int i=0; i<8; i++) {
        i1 = c1[i] -'0';
        i2 = c2[i] -'0';
        i3 = i1 ^ i2;
        printf("c3[%d]=%x\n",i,i3);
        sprintf(&c3[i],"%x",i3);
    }
    c3[8] = '\0';
    NSLog(@"c3:%s",c3);

    _jiaoYiTeZhengMa = [NSString stringWithCString:c3 encoding:NSASCIIStringEncoding];
    
    NSLog(@"_jiaoYiTeZhengMa:%@",_jiaoYiTeZhengMa);
    
    
    self.ShuiYin.text = _jiaoYiTeZhengMa;
    //[NSDate]
    
//    NSData *timeCodeData = [NSData dataWithBytes:(const void *)gLocalTime length:sizeof( char)*3];
//    NSString *timeCodeString = [[NSString alloc] initWithData:timeCodeData encoding:NSUTF8StringEncoding];
//    
//    //日期 gLocalDate[2]
//    NSData *dateCodeData = [NSData dataWithBytes:(const void *)gLocalDate length:sizeof( char)*2];
//    NSString *dateCodeString = [[NSString alloc] initWithData:dateCodeData encoding:NSUTF8StringEncoding];
    
    
    //批次号
    int gUserArea = BCDToInt(gUserArea60+1, 3);
    NSString *gUserAreaString = [NSString stringWithFormat:@"%.6d",gUserArea];
    
    
    if([self.type isEqualToString:@"消费交易"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:audCodeString forKey:KLastPingZhengHao];
        [[NSUserDefaults standardUserDefaults] setObject:_countStr forKey:KLastJiaoYiJinE];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    

    
    NSLog(@"终端号：%@  商户号：%@ 卡号：%@",terCodeString,mcCodeString,s);

    for (int i = 10; i <= 20; i++) {
        UILabel *label = (UILabel *)[self.printView viewWithTag:i];
        
//        switch (i) {
//            case 10:
//                label.text = [NSString stringWithFormat:@"商户名称：%@",[[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName]];
//                break;
//            case 11:
//                label.text = [NSString stringWithFormat:@"商户编号：%@",mcCodeString];
//                break;
//            case 12:
//                label.text = [NSString stringWithFormat:@"终端编号：%@",terCodeString];
//                break;
//            case 13:
//                label.text = [NSString stringWithFormat:@"操作员号：%@",@"01"];
//                break;
//            case 14:
//                label.text = [NSString stringWithFormat:@"付款卡号：%@",s];
//                break;
//            case 15:
//                label.text = [NSString stringWithFormat:@"交易类型：%@",_typeStr];
//                break;
//            case 16:
//                label.text = [NSString stringWithFormat:@"批次号：%@",gUserAreaString];
//                break;
//            case 17:
//                label.text = [NSString stringWithFormat:@"凭证号：%@",audCodeString];
//                
//                break;
//            case 18:
//                label.text = [NSString stringWithFormat:@"交易时间：%@",_dateStr];
//                
//                break;
//            case 19:
//                label.text = [NSString stringWithFormat:@"交易参考号：%@",reCodeString];
//                break;
//            case 20:
//                label.text = [NSString stringWithFormat:@"交易金额：%@",_countStr];
//                
//                break;
//                
//            default:
//                break;
//        }
        
        switch (i) {
            case 10:
                label.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName]];
                break;
            case 11:
                label.text = [NSString stringWithFormat:@"%@",mcCodeString];
                break;
            case 12:
                label.text = [NSString stringWithFormat:@"%@",terCodeString];
                break;
            case 13:
                label.text = [NSString stringWithFormat:@"%@",@"01"];
                break;
            case 14:
                label.text = [NSString stringWithFormat:@"%@",s];
                break;
            case 15:
                label.text = [NSString stringWithFormat:@"%@",_typeStr];
                break;
            case 16:
                label.text = [NSString stringWithFormat:@"%@",gUserAreaString];
                break;
            case 17:
                label.text = [NSString stringWithFormat:@"%@",audCodeString];
                
                break;
            case 18:
                label.text = [NSString stringWithFormat:@"%@",_dateStr];
                
                break;
            case 19:
                label.text = [NSString stringWithFormat:@"%@",reCodeString];
                break;
            case 20:
                label.text = [NSString stringWithFormat:@"%@",_countStr];
                break;
                
            default:
                break;
        }
        
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backAction:(UIButton *)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)startAnimation
{
    
    self.printView.bottom = 0;
    self.printView.hidden = NO;
  
    [self startMove];
}


- (void)startMove
{
    
    [UIView animateWithDuration:3.0 animations:^{
        self.printView.top = 0;
    } completion:^(BOOL finished) {
        NSLog(@"self.bgScrollView:%@",self.bgScrollView);
        //self.bgScrollView
        self.bgScrollView.contentSize = CGSizeMake(320, 565);
    }];
    
}

- (IBAction)signatureAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSLog(@"before:%@",sender);
    if (sender.selected) {
        
        [sender setTitle:@"确认" forState:UIControlStateNormal];
        self.ppsSignView.hidden = NO;
        self.uploadButton.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
        NSLog(@"after:%@",sender);
        
    } else {
        self.ppsSignView.hidden = YES;
        [self.view bringSubviewToFront:self.signImgView];
        [sender setTitle:@"重签" forState:UIControlStateNormal];
        self.signImgView.image = self.signView.signatureImage;
        self.uploadButton.hidden = NO;
        self.navigationController.navigationBarHidden = NO;
    }
    
    
}

- (NSString *)getTimeNow{
    NSString *date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY.MM.dd.hh.mm.ss.SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    
    return date;
}


- (IBAction)uploadImage:(id)sender {
    
    
//    server = [FMServer serverWithDestination:@"122.112.12.23/mpos" username:@"mpos" password:@"tenmpos123"];
//    
//    server.port = 2221;
    
    man = [[FTPManager alloc] init];

    
    NSString *str = [[NSString alloc]initWithFormat:@"tmp/%@.jpg",[self getTimeNow]];
    
    NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:str];
    
    UIImage *image = [UIUtils imageFromView:self.printView];
    
    NSData *data = UIImageJPEGRepresentation(image,0.4);
    
    [data writeToFile:jpgPath atomically:YES];
    
    
//    NSString *_shangHuHao; //商户号
//    NSString *_zhongDuanHao; //终端号
//    NSString *_jiaoYiShiJian; //交易时间
//    NSString *_jiaoYiCanKaoHao; //交易参考号
    
    
    NSLog(@"/mpos/%@/%@/%@/%@/图片.jpg",_shangHuHao,_zhongDuanHao,_jiaoYiShiJian,_jiaoYiCanKaoHao);
    
    NSString *strs[4] ={
        _shangHuHao,
        _zhongDuanHao,
        _jiaoYiShiJian,
        _jiaoYiCanKaoHao
    };
    
    self.serialQueue = dispatch_queue_create("com.wudi", DISPATCH_QUEUE_SERIAL);
    
  //  NSString *destionation =@"122.112.12.23/mpos";
    NSString *destionation =@"123.56.106.39/mpos";
    NSString *username = @"mpos";
    NSString *password = @"tenmpos123";
    int  port = 2221;
    
    for (int i=0; i< 4; i++) {
        NSString *s = strs[i];
        NSLog(@"destionation:%@",destionation);
        dispatch_async(self.serialQueue, ^{
            server = [FMServer serverWithDestination:destionation username:username password:password];
            server.port =port;
            [man createNewFolder:s atServer:server];
        });
        
       destionation = [destionation stringByAppendingPathComponent:s];
    }
    
    
    [self showHUD:@"正在上传"];
    
    //destionation = [NSString stringWithFormat:@"122.112.12.23/mpos/%@/%@/%@/%@/",_shangHuHao,_zhongDuanHao,_jiaoYiShiJian,_jiaoYiCanKaoHao];
    
    BOOL __block success = false;


   NSLog(@"destionation:%@",destionation);
    
    dispatch_async(self.serialQueue, ^{
        
        server = [FMServer serverWithDestination:destionation username:username password:password];
        server.port =port;
        
        
    
        //[man createNewFolder:mcCodeString atServer:server];
        
        success = [man uploadFile:[NSURL URLWithString:jpgPath] toServer:server];
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHUD];
                [self showTipView:@"上传成功"];
                 self.uploadButton.hidden = true;
                self.signatureBt.hidden = true;
                //[self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController popToViewController animated:<#(BOOL)#>]
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                [self performSelector:@selector(backToHome) withObject:nil afterDelay:5.0];
                
            });
        }else {
            [self hideHUD];
            [self showTipView:@"上传失败"];
        }
        
    });
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (success == false) {
            [self hideHUD];
            [self showTipView:@"上传超时"];
        }
    });
    
 
}


- (void)backToHome{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (IBAction)resignAction:(id)sender {
    [self.signView erase];
}

@end
