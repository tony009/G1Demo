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
#import "LPPopup.h"
@implementation GetPhoneVerificationCodeViewController{
    
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    

    [self.phoneNo becomeFirstResponder];
}


- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//获取手机验证码
- (IBAction)getPhoneVerificationCode:(id)sender {
    
    [self.view endEditing:YES];
   
    NSString *phoneNo = self.phoneNo.text;
    
    if (![self checkPhoneNo:phoneNo]) {
        NSLog(@"The phoneNo is invalid");
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入正确的手机号" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        
        
        [alertView show];
        
        return;
        
    }
    
    
    [self showHUD:@"正在获取"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/queryAuthCode.action?phone=%@",kServerIP,kServerPort,phoneNo];
    NSLog(@"url:%@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"json:%@",responseObject);
        
        int code = [responseObject[@"resultMap"][@"code"] intValue];
        
        [self hideHUD];
    
        //返回就跳转到下个界面
        if (code == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"GetPinToVerify" sender:self];
            });
            
        }else{
            
            [self showTipView:responseObject[@"resultMap"][@"msg"]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self hideHUD];
        NSLog(@"failure");
        [self showTipView:@"获取失败"];

    }];
    
//    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://122.112.12.25:8081/MposApp/queryAuthCode.action?phone=%@",phoneNo]];
//    NSLog(@"url:%@",url);
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        
//        
//        NSLog(@"json:%@",json);
//        
//        int code = [json[@"resultMap"][@"code"] intValue];
//        
//   
//        [self hideHUD];
//        
//   
//        
//        
//        
//        //返回就跳转到下个界面
//        if (code == 0) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self performSegueWithIdentifier:@"GetPinToVerify" sender:self];
//            });
//            
//        }else{
//            
//            [self showTipView:json[@"resultMap"][@"msg"]];
//     
//        }
//        
//
//    }] resume];
    

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
