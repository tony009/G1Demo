//
//  VerifyCodeViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/11.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "GetPhoneVerificationCodeViewController.h"
#import "AFNetworking.h"
@implementation VerifyCodeViewController
{
 
    NSTimer *_timer;
    int seconds;
}

-(void)viewDidLoad{

    [super viewDidLoad];
    
    GetPhoneVerificationCodeViewController *gpvcc = self.navigationController.viewControllers[0];
    
    self.phoneNo.text = gpvcc.phoneNo.text;
    
    [self.verificationCode becomeFirstResponder];
    

    [self startCountDown];
    
}

- (void)startCountDown{
    seconds  = 60;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    [_timer fire];
}

//重新获取手机验证码
- (IBAction)getVerCode:(UIButton *)sender {
    
    [self.view endEditing:YES];

    [self showHUD:@"正在获取"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/queryAuthCode.action?phone=%@",kServerIP,kServerPort,self.phoneNo.text];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"json:%@",responseObject);
        
        int code = [responseObject[@"resultMap"][@"code"] intValue];
        
        [self hideHUD];
        
        
        if (code == 0) {
            
            [self startCountDown];
            
        }else{
            
            [self showTipView:responseObject[@"resultMap"][@"msg"]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self hideHUD];
        NSLog(@"failure");
        [self showTipView:@"获取失败"];
        
    }];

}

//提交服务器验证
- (IBAction)submit:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.verificationCode.text isEqualToString:@""]) {
        [self showTipView:@"请输入您收到的短信验证码"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/checkAuthCode.action",kServerIP,kServerPort];
    NSLog(@"url:%@",url);
    NSDictionary *parameters = @{@"phone":self.phoneNo.text,@"authCode":self.verificationCode.text};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [self showHUD:@"正在提交验证"];
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
                int code = [responseObject[@"resultMap"][@"code"] intValue];
        
        
                [self hideHUD];
        
        
                    if(code == 0){
        
                        [[NSUserDefaults standardUserDefaults] setObject:self.phoneNo.text forKey:kSignUpPhoneNo];
                        [[NSUserDefaults standardUserDefaults] synchronize];
        
                        [self performSegueWithIdentifier:@"VerifyToSignup" sender:self];
                        
                    }else{
                        
                        [self showTipView:responseObject[@"resultMap"][@"msg"]];
                         
                    }
              
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUD];
        NSLog(@"failure");
        [self showTipView:@"验证失败"];
    }];
    
    
}

-(void)showTime{
    
    if(seconds == 0){
        [_timer invalidate];
        self.getVerCodeLabel.text = @"重新获取";
        self.getVerCodeBtn.enabled = YES;
        self.getVerCodeLabel.enabled = YES;
    }else{
        
        [self.getVerCodeBtn setEnabled:NO];
        [self.getVerCodeLabel setEnabled:NO];
        self.getVerCodeLabel.text = [[NSString alloc]initWithFormat:@"(%d秒)重新获取",--seconds];
        
    }

    

}

@end
