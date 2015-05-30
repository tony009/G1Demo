//
//  BaseNavViewController.m
//  MovePower
//
//  Created by Femto03 on 14-6-5.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseNavViewController.h"

@interface BaseNavViewController ()

@end

@implementation BaseNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        self.navigationBar.translucent = NO;
//        self.navigationBar.barTintColor = rgb(74, 177, 163, 1);
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    } else {
//        self.navigationBar.tintColor = rgb(74, 177, 163, 1);
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
//    }
//    
//    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                [UIColor whiteColor], UITextAttributeTextColor,
//                                                [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1], UITextAttributeTextShadowColor,
//                                                [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
//                                                [UIFont boldSystemFontOfSize:18], UITextAttributeFont,
//                                                nil]];
    
    
//    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0, 0, 50, 50);
//    [backButton setImage:[UIImage imageNamed:@"箭头.png"] forState:UIControlStateNormal];
//    backButton.backgroundColor = [UIColor clearColor];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
