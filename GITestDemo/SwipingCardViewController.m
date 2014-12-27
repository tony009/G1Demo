//
//  SwipingCardViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "SwipingCardViewController.h"
#import "PrintNoteViewController.h"


@interface SwipingCardViewController ()<UIAlertViewDelegate>
{
    NSString *sendValue;
}
@end

@implementation SwipingCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type;
    
//    sendValue = @"消费交易";
//    [self performSelector:@selector(pushToPrint) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recvMiniPosSDKStatus
{
    if (!self.isViewLoaded) {
        return;
    }
    
    [super recvMiniPosSDKStatus];
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"消费成功"]]) {
        sendValue = @"消费交易";
        [self pushToPrint];
    }
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"查询余额成功"]]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查询余额成功！" message:@"余额信息请在设备终端查阅。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        
//        [self pushToCheck];
    }
    
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"查询余额失败"]]) {
        [self showTipView:self.statusStr];
        [self performSelector:@selector(popAction) withObject:nil afterDelay:2.0];
    }                                                                                                                                                                                                                                                                                                                                                     
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"消费失败"]]) {
        [self showTipView:self.statusStr];
        [self performSelector:@selector(popAction) withObject:nil afterDelay:2.0];
    }
    
    
    if ([self.statusStr isEqualToString:@"设备响应超时"]) {
        [self showTipView:self.statusStr];
        [self performSelector:@selector(popAction) withObject:nil afterDelay:2.0];
    }
    
    if ([self.statusStr isEqualToString:@"查询余额响应超时"]) {
        [self showTipView:self.statusStr];
        [self performSelector:@selector(popAction) withObject:nil afterDelay:2.0];
    }
    
    self.statusStr = @"";
}


- (void)pushToPrint
{
    [self performSegueWithIdentifier:@"swipPushToPrint" sender:self];
}

- (void)pushToCheck
{
    [self performSegueWithIdentifier:@"swipPushToCheck" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    UIViewController *send = segue.destinationViewController;
    if ([send respondsToSelector:@selector(setType:)]) {
        if (sendValue) {
            [send setValue:sendValue forKey:@"type"];
            
        }
    }
    
    if ([send respondsToSelector:@selector(setCount:)]) {
        [send setValue:[NSNumber numberWithFloat:self.count] forKey:@"count"];
    }
    
}

- (void)popAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark - UIAlertView delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self popAction];
}

@end
