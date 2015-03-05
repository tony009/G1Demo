//
//  UpdateViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 14/12/31.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "UpdateViewController.h"
#import "AFNetworking.h"
#import "UIUtils.h"

@interface UpdateViewController ()
{
    NSArray *pickerArray;
    BOOL hasSettedParam;
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

- (IBAction)download:(id)sender {
    //NSURLCacheStorageNotAllowed
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
    CustomAlertView  *cav = [[CustomAlertView alloc]init];
    [cav updateTitle:[NSString stringWithFormat:@"下载%@",file]];
    [self.view addSubview:cav];
    [cav show];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
        //self.progressView set
        float progress = (float)totalBytesRead/totalBytesExpectedToRead;
        
        [cav updateProgress:progress];
        
        
        
    }];
    
    //NSString *filePath = [NSString alloc]in
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        NSLog(@"文件大小:%llu",[[manager attributesOfItemAtPath:str error:nil] fileSize]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            cav.hidden = YES;
            NSLog(@"hidden-------");
            
        });
        
        [operation.outputStream close];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        cav.hidden = YES;
    }];
    
    [operation start];
    
    
    
}

- (IBAction)update:(id)sender {
    
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSString *file = [pickerArray objectAtIndex:row];
    CustomAlertView  *cav = [[CustomAlertView alloc]init];
    [cav updateTitle:[NSString stringWithFormat:@"正在传输%@",file]];
    
    MiniPosSDKDownPro();
    [cav show];
    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
    NSArray *array = [NSArray arrayWithObject:file];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        DownThread((__bridge void*)cav,array);
        
        [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cav dismiss];
        });
        
    });
    
    return;
    
}



- (IBAction)downloadParam:(id)sender {
    
    dispatch_queue_t serial_queue =  dispatch_queue_create("cn.yogia.downloadParam", DISPATCH_QUEUE_SERIAL);

    //MiniPosSDKSetParam("000000000", "\xC9\xCC\xBB\xA7\xBA\xC5", "898100012340004");
    // MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"商户号"], "898100012340005");
    
    dispatch_async(serial_queue, ^{
        hasSettedParam = false;
        MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"商户号"], "898100012340002");
        while (hasSettedParam ==false) {
            
        }
        
    });
    
    dispatch_async(serial_queue, ^{
        hasSettedParam = false;
        MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"终端号"], "10700027");
        while (hasSettedParam ==false) {
            
        }
        
    });
    
    dispatch_async(serial_queue, ^{
        hasSettedParam = false;
        MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"主密钥1"], "3E61C7071A836483628567ADB6F8F2EC");
        while (hasSettedParam ==false) {
            
        }
        
    });
    
    dispatch_async(serial_queue, ^{
        hasSettedParam = false;
        MiniPosSDKSetParam("000000000", "", "");
        while (hasSettedParam ==false) {
            
        }
        
    });
    
    //MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"终端号"], "107000028");
    //MiniPosSDKSetParam("000000000", [UIUtils UTF8_To_GB2312:@"主密钥1"], "3E61C7071A836483628567ADB6F8F2EC");
}

#pragma mark -
#pragma mark - /*******/
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"下载参数成功"]]) {
        
//        [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            // DownThread();
//            
//            [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
//        });
        
         NSLog(@"------------");
         hasSettedParam = true;
    }
    
    
   
    
    self.statusStr = @"";
}
@end
