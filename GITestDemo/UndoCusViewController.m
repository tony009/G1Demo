//
//  UndoCusViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "UndoCusViewController.h"
#import "PrintNoteViewController.h"
#import "UIUtils.h"

@interface UndoCusViewController ()

@end

@implementation UndoCusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSubViews];
    
    NSLog(@"UndoCusViewController----viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_initSubViews
{
    self.countText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.countText.layer.borderWidth = 0.4;
    
    self.noNumbertext.layer.borderWidth = 0.4;
    self.noNumbertext.layer.borderColor = [UIColor lightGrayColor].CGColor;

    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    label1.text = @"撤销金额：";
    label1.font = [UIFont systemFontOfSize:17];
    label1.textColor = [UIColor darkGrayColor];
    label1.textAlignment = NSTextAlignmentRight;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    label2.text = @"凭证号：";
    label2.font = [UIFont systemFontOfSize:17];
    label2.textColor = [UIColor darkGrayColor];
    label2.textAlignment = NSTextAlignmentRight;
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
    label3.text = @"元";
    label3.font = [UIFont systemFontOfSize:17];
    label3.textColor = [UIColor darkGrayColor];
    label3.textAlignment = NSTextAlignmentRight;
    

    
    self.countText.leftView = label1;
    self.countText.rightView = label3;
    self.countText.rightViewMode = UITextFieldViewModeAlways;
    self.noNumbertext.leftView = label2;
    self.countText.leftViewMode = UITextFieldViewModeAlways;
    self.noNumbertext.leftViewMode = UITextFieldViewModeAlways;
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSString *pingZhengHao = [[NSUserDefaults standardUserDefaults] objectForKey:KLastPingZhengHao];
    NSString *jiaoYiJinE =  [[NSUserDefaults standardUserDefaults]objectForKey:KLastJiaoYiJinE];
    
    if (!pingZhengHao || [pingZhengHao isEqualToString:@""]) {
        [self showTipView:@"没有可以撤销的交易"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    
    self.countText.text = jiaoYiJinE;
    self.noNumbertext.text = pingZhengHao;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *send = segue.destinationViewController;
    if ([send respondsToSelector:@selector(setType:)]){
        [send setValue:@"撤销消费" forKey:@"type"];
    }
    
    if ([send respondsToSelector:@selector(setCount:)]) {
        [send setValue:[NSNumber numberWithFloat:[self.countText.text floatValue]] forKey:@"count"];
    }
    
}


- (IBAction)backoutAction:(id)sender {
    
    if(self.countText.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的金额" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(![self isCorrectSerialNumber:self.noNumbertext.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的凭证号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    int amount = self.countText.text.floatValue * 100;
    int serial = self.noNumbertext.text.intValue;
    char buf[20],serialbuf[20];
    
    sprintf(buf,"%012d",amount);
    
    amount = self.noNumbertext.text.intValue;
    sprintf(serialbuf,"%06d",serial);
    
    NSLog(@"amount: %s serial: %s",buf,serialbuf);
    
    
    _type = 2;
    MiniPosSDKVoidSaleTradeCMD(buf, serialbuf, NULL);
    
    [self showHUD:@"正在撤销..."];
}

- (BOOL)isCorrectSerialNumber:(NSString*)numer
{
    const char *str = numer.UTF8String;
    NSUInteger len = numer.length;
    
    if(len<=0)
        return FALSE;
    
    for(int i=0;i<len;i++)
    {
        if(str[i]<'0'||str[i]>'9')
        {
            return FALSE;
        }
    }
    
    return TRUE;
}


-(void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    NSLog(@"UndoCusViewController------recvMiniPosSDKStatus");
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"撤销消费成功"]]) {
        [self hideHUD];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KLastPingZhengHao];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KLastJiaoYiJinE];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
       [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KLastJiaoYiJinE];
       [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KLastPingZhengHao];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [self performSegueWithIdentifier:@"undoPushToPrint" sender:self];
    }
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"撤销消费失败"]]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
        [self performSelector:@selector(backAction:) withObject:nil afterDelay:1.0];
    }
    
    
    if ([self.statusStr isEqualToString:@"撤销响应超时"]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    self.statusStr = @"";
}


@end
