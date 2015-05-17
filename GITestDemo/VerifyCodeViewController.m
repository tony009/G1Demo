//
//  VerifyCodeViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/11.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "GetPhoneVerificationCodeViewController.h"
@implementation VerifyCodeViewController
{
 
    NSTimer *_timer;
    int seconds;
}

-(void)viewDidLoad{

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


- (IBAction)getVerCode:(UIButton *)sender {
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://122.112.12.25:8081/MposApp/queryAuthCode.action?phone=%@",self.phoneNo.text]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    [self showHUD:@"正在获取"];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        
        int code = [json[@"resultMap"][@"code"] intValue];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideHUD];
            
            if (code == 0) {
                
                [self startCountDown];
                
            }
        });
        


        
    }] resume];
}

- (IBAction)submit:(id)sender {
    if ([self.verificationCode.text isEqualToString:@""]) {
        [self showHUD:@"请输入您收到的短信验证码"];
    }
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://122.112.12.25:8081/MposApp/checkAuthCode.action?phone=%@&authCode=%@",self.phoneNo.text,self.verificationCode.text]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    [self showHUD:@"正在提交验证"];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        
        int code = [json[@"resultMap"][@"code"] intValue];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideHUD];
            
            
            
            
            if(code == 0){
                
                [[NSUserDefaults standardUserDefaults] setObject:self.phoneNo.text forKey:kSignUpPhoneNo];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self performSegueWithIdentifier:@"VerifyToSignup" sender:self];
            }
            
        });
        
        
        
        
    }] resume];
    
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
