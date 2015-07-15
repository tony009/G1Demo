//
//  UpdateViewController.m
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "UpdateViewController.h"
#import "AFNetworking.h"
#import "UIUtils.h"
#import "ConnectDeviceViewController.h"

@interface UpdateViewController ()
{
    NSArray *pickerArray;
    BOOL hasSettedParam;
    CustomAlertView *_cav;
}
@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pickerArray = [NSArray arrayWithObjects:@"kernel",@"task",@"boot",@"btparam", nil];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
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

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [pickerArray count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)check:(id)sender {
    
    // 1
    NSString *baseURLString = @"http://120.24.213.123/app/version.json";
    //NSString *baseURLString = @"http://www.raywenderlich.com/demos/weather_sample/weather.php?format=json";
    NSURL *url = [NSURL URLWithString:baseURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *str = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/version.json"];
    
    operation.inputStream = [NSInputStream inputStreamWithURL:url];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:str append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:str] options:kNilOptions error:NULL];
        
        NSLog(@"%@",dictionary);
        
        NSDictionary *g1 = dictionary[@"G1"];
        
        NSString *kernel = g1[@"kernel"];
        NSString *task = g1[@"task"];
        
        NSString *message = [NSString stringWithFormat:@"kernel:%@\ntask:%@",kernel,task];
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        
        UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        progressView.frame = CGRectMake(30, 80, 225, 30);
        progressView.progress = 0.5;
        
        [alertView addSubview:progressView];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        button.frame = CGRectMake(30, 80, 225, 30);
        
        [alertView show];
        [alertView addSubview:progressView];
        [alertView addSubview:button];
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            alertView.title = @"版本111";
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
    }];
    
    // 5
    [operation start];
    
}

- (void)showConnectionAlert{
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"设备未连接" message:@"点击跳转设备连接界面" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    alertView.tag = 44;
    [alertView show];
    
}

- (IBAction)download:(id)sender {
    
    //NSURLCacheStorageNotAllowed
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }
    
    
    
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSString *file = [pickerArray objectAtIndex:row];
    
    NSString *baseURLString = [NSString stringWithFormat:@"http://120.24.213.123/app/%@",file];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:baseURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    NSString *str = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",file]];
    
    NSFileManager *manager  = [NSFileManager defaultManager];
    
    //    if ([manager fileExistsAtPath:str]) {
    //        [manager removeItemAtPath:str error:nil];
    //        NSLog(@"文件已经删除");
    //        return;
    //    }
    
    
    
    NSLog(@"%@",str);
    
    operation.inputStream = [NSInputStream inputStreamWithURL:baseURL];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:str append:NO];
    _cav = [[CustomAlertView alloc]init];
    [_cav updateTitle:[NSString stringWithFormat:@"下载%@",file]];
    
    [_cav show];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
        //self.progressView set
        float progress = (float)totalBytesRead/totalBytesExpectedToRead;
        
        [_cav updateProgress:progress];
        
        
        
    }];
    
    //NSString *filePath = [NSString alloc]in
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        NSLog(@"文件大小:%llu",[[manager attributesOfItemAtPath:str error:nil] fileSize]);
        [operation.outputStream close];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_cav dismiss];
//            NSLog(@"hidden-------");
           
            [self update:nil];
            [_cav updateProgress:0];
            
        });
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
       [_cav dismiss];
    }];
    
    [operation start];
    
    
    
}

- (IBAction)update:(id)sender {
    

    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSString *file = [pickerArray objectAtIndex:row];
    
    [_cav updateTitle:[NSString stringWithFormat:@"正在传输%@",file]];
    
    MiniPosSDKDownPro();
    [_cav show];
    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
    NSArray *array = [NSArray arrayWithObject:file];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        DownThread((__bridge void*)_cav,array);
        
        [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_cav dismiss];
        });
        
    });
    
    return;
    
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 44) {
        if (buttonIndex == 0) {
            ConnectDeviceViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CD"];
            [self.navigationController pushViewController:cdvc animated:YES];
        }
    }
}


#pragma mark -
#pragma mark - /*******/
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"上传参数成功"]]) {
        
         NSLog(@"------------");
         hasSettedParam = true;
    }
    
    
   
    
    self.statusStr = @"";
}
@end
