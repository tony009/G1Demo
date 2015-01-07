//
//  UpdateViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 14/12/31.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "UpdateViewController.h"
#import "AFNetworking.h"

@interface UpdateViewController ()

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    
    NSString *baseURLString = @"http://120.24.213.123/app/IosMiniposSDK.rar";
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    NSString *str = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/IosMiniposSDK.rar"];
    
    NSLog(@"%@",str);
    
    operation.inputStream = [NSInputStream inputStreamWithURL:baseURL];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:str append:NO];
    CustomAlertView  *cav = [[CustomAlertView alloc]init];
    
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
    
    [operation start];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cav.hidden = YES;
        //[cav dismiss];
        NSLog(@"hidden-------");
        //[cav removeFromSuperview];
});
    
}

- (IBAction)update:(id)sender {
    
//    if (MiniPosSDKDownPro() ==0) {
//
//    } ;
    
//    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        DownThread();
//        
//        [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
//    });

    
//    CustomAlertView *cav = [[CustomAlertView alloc]init];
//    
//    [self.view addSubview:cav];
//
//    
//    [cav show];
    
    NSString *baseURLString = @"http://www.raywenderlich.com/demos/weather_sample/weather.php?format=json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
//    [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success json1");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"qqq");
//    }];
//    
//    [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success json2");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"qqq");
//    }];
//    
//    [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success json3");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"qqq");
//    }];
//    
//    [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success json4");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"qqq");
//    }];
    
    
    

}


#pragma mark -
#pragma mark - /*******/
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"开始下载"]]) {
        
        [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           // DownThread();
            
            [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO ] ;
        });
        
        
    }
    
    
    self.statusStr = @"";
}
@end
