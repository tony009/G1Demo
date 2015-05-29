//
//  MerchantInfoViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "MerchantInfoViewController.h"
#import "ConnectDeviceViewController.h"
@interface MerchantInfoViewController ()

@end

@implementation MerchantInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
}

-(void)initViews{
    
    self.area.delegate = self;
    self.address.delegate = self;
    
    WDPickView *pickView = [[WDPickView alloc]initPickViewWithPlistName:@"Address"];
    pickView.delegate = self;
    self.area.inputView = pickView;
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"json-array-of-city" ofType:@"json"];
//    
//    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
//    NSLog(@"data:%@",data);
//    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"json:%@",json);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)next:(UIButton *)sender
{
    
    
    //校验信息
    
    if ([UIUtils isEmptyString:self.area.text]) {
        [self showTipView:@"请输入地区"];
        return;
    }else if ([UIUtils isEmptyString:self.address.text]||[self.address.text length] > 30) {
        [self showTipView:@"请输入正确的经营地址"];
        return;
    }else if([UIUtils isEmptyString:self.sn.text]){
        [self showTipView:@"请获取SN号"];
        return;
    }
       

    //跳转
    [self performSegueWithIdentifier:@"NEXT" sender:nil];
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getSN:(id)sender {
    
    if(MiniPosSDKDeviceState()<0){
        
        
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"设备未连接" message:@"点击跳转设备连接界面" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        
        [alert1 show];
        
        return;
    }
    
    MiniPosSDKGetDeviceInfoCMD();
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        ConnectDeviceViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CD"];
        [self.navigationController pushViewController:cdvc animated:YES];

    }
}
- (void)recvMiniPosSDKStatus{
    [super recvMiniPosSDKStatus];
    
    if ([self.statusStr isEqualToString:@"获取设备信息成功"]) {
        
        
        
        NSString *sn = [NSString stringWithFormat:@"%s",MiniPosSDKGetDeviceID()];
        self.sn.text = sn;
        
        [[NSUserDefaults standardUserDefaults] setObject:sn forKey:kMposG1SN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)toolBarDoneBtnHaveClicked:(WDPickView *)pickView resultString:(NSString *)resultString{
    
    
    self.area.text = [resultString substringToIndex:[resultString length] -5];
    self.areaCode  = [resultString substringFromIndex:[resultString length] -4];
    
    //NSLog(@"self.area.tag:%d",self.area.tag);
    
    //为了解决跳转时，如果焦点停留在所在地区上，奔溃的bug
    [self.area resignFirstResponder];
}



#pragma mark -- UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
