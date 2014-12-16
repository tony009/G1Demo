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

@interface PrintNoteViewController ()
{
    NSString *_typeStr;
    NSString *_dateStr;
    NSString *_countStr;
}
@end

@implementation PrintNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self _initSubViews];

    
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
    
    
    //商户号
    NSData *mcCodeData = [NSData dataWithBytes:(const void *)gMerchantCode length:sizeof( char)*15];
    NSString *mcCodeString = [[NSString alloc] initWithData:mcCodeData encoding:NSUTF8StringEncoding];

    //参考号
    //gRetrieval[12]
    NSData *reCodeData = [NSData dataWithBytes:(const void *)gRetrieval length:sizeof( char)*12];
    NSString *reCodeString = [[NSString alloc] initWithData:reCodeData encoding:NSUTF8StringEncoding];
    
    //交易金额
    //gTransacAmount[6]
    int transacAmount = BCDToInt(gTransacAmount, 6);
    _countStr = [NSString stringWithFormat:@"%d.%.2d",transacAmount/100,transacAmount%100];
//    NSData *tranCodeData = [NSData dataWithBytes:(const void *)gTransacAmount length:sizeof( char)*6];
//    NSString *tranCodeString = [[NSString alloc] initWithData:mcCodeData encoding:NSUTF8StringEncoding];
    
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
    _dateStr = [NSString stringWithFormat:@"%02d/%02d %02d:%02d:%02d",date/100,date%100,time/10000,(time%10000)/100,time%100];
    
    
    NSData *timeCodeData = [NSData dataWithBytes:(const void *)gLocalTime length:sizeof( char)*3];
    NSString *timeCodeString = [[NSString alloc] initWithData:timeCodeData encoding:NSUTF8StringEncoding];
    
    //日期 gLocalDate[2]
    NSData *dateCodeData = [NSData dataWithBytes:(const void *)gLocalDate length:sizeof( char)*2];
    NSString *dateCodeString = [[NSString alloc] initWithData:dateCodeData encoding:NSUTF8StringEncoding];
    
    
    //批次号
    int gUserArea = BCDToInt(gUserArea60+1, 3);
    NSString *gUserAreaString = [NSString stringWithFormat:@"%.6d",gUserArea];
    
    
    NSLog(@"终端号：%@  商户号：%@ 卡号：%@",terCodeString,mcCodeString,s);

    for (int i = 10; i <= 20; i++) {
        UILabel *label = (UILabel *)[self.printView viewWithTag:i];
        
        switch (i) {
            case 10:
                label.text = [NSString stringWithFormat:@"商户名称：%@",[[NSUserDefaults standardUserDefaults] objectForKey:kShangHuName]];
                break;
            case 11:
                label.text = [NSString stringWithFormat:@"商户编号：%@",mcCodeString];
                break;
            case 12:
                label.text = [NSString stringWithFormat:@"终端编号：%@",terCodeString];
                break;
            case 13:
                label.text = [NSString stringWithFormat:@"操作员号：%@",@"01"];
                break;
            case 14:
                label.text = [NSString stringWithFormat:@"付款卡号：%@",s];
                break;
            case 15:
                label.text = [NSString stringWithFormat:@"交易类型：%@",_typeStr];
                break;
            case 16:
                label.text = [NSString stringWithFormat:@"批次号：%@",gUserAreaString];
                break;
            case 17:
                label.text = [NSString stringWithFormat:@"凭证号：%@",audCodeString];
                break;
            case 18:
                label.text = [NSString stringWithFormat:@"交易时间：%@",_dateStr];
                break;
            case 19:
                label.text = [NSString stringWithFormat:@"交易参考号：%@",reCodeString];
                break;
            case 20:
                label.text = [NSString stringWithFormat:@"交易金额：%@",_countStr];
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
       
    }];
}

- (IBAction)signatureAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [sender setTitle:@"确认" forState:UIControlStateNormal];
        
        self.ppsSignView.hidden = NO;
    } else {
        self.ppsSignView.hidden = YES;
        
        [sender setTitle:@"重签" forState:UIControlStateNormal];
        self.signImgView.image = self.signView.signatureImage;
        
    }
    
    
}

- (IBAction)resignAction:(id)sender {
    [self.signView erase];
}
@end
