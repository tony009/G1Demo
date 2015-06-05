//
//  RNewPasswordViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/5.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "RNewPasswordViewController.h"
#import "AFNetworking.h"
#import "UIUtils.h"
@interface RNewPasswordViewController ()

@end

@implementation RNewPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.st addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
}

-(void)switchAction: (UISwitch *) st{
    self.password.secureTextEntry = !st.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submit:(id)sender {
//    AFHTTPRequestOperation *
    
    
    if (![UIUtils isCorrectPassword:self.password.text]) {
        [self showTipView:@"请输入正确的密码"];
        return;
    }
    
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/MposApp/updatePwd.action",kServerIP,kServerPort];
    NSLog(@"url:%@",url);
    NSDictionary *parameters = @{@"phone":self.phoneNo,@"passwd":self.password.text};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [self showHUD:@"正在提交验证"];
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        int code = [responseObject[@"resultMap"][@"code"] intValue];
        
        NSLog(@"responseObject:%@",responseObject);
        [self hideHUD];

        
        if (code == 0) {
        
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [self showTipView:responseObject[@"resultMap"][@"msg"]];
        }
        
        
  
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUD];
        NSLog(@"failure");
        [self showTipView:@"验证失败"];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
