//
//  GetPhoneVerificationCodeViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/8.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "GetPhoneVerificationCodeViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "VerifyCodeViewController.h"

@implementation GetPhoneVerificationCodeViewController{
    MBProgressHUD *_hub;
}


- (void)viewDidLoad{
    [self.phoneNo becomeFirstResponder];
}

- (void)showHUDWithText:(NSString *)str{
    
    _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hub.labelText = str ;
    
}

-(void)hideHUD{
    if (_hub) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hub hide:YES];
        });
    }
}

- (IBAction)getPhoneVerificationCode:(id)sender {
    
    
    NSString *phoneNo = self.phoneNo.text;
    
    if (![self checkPhoneNo:phoneNo]) {
        NSLog(@"The phoneNo is invalid");
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入正确的手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        
        
        [alertView show];
        
        return;
        
    }
    
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://122.112.12.25:8081/MposApp/queryAuthCode.action?phone=%@",phoneNo]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    [self showHUDWithText:@"正在获取"];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        
        int code = [json[@"resultMap"][@"code"] intValue];
        
   
        [self hideHUD];
        
        //返回                                 就跳转到下个界面
        if (code == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"GetPinToVerify" sender:self];
            });
            
        }
        

    }] resume];
    

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    
    
    if ([segue.identifier isEqualToString:@"GetPinToVerify"]) {
        //VerifyCodeViewController *vcvc = segue.destinationViewController;
    }
}



- (BOOL)checkPhoneNo:(NSString *)str{
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:str];
    
    return isMatch;
}



@end
