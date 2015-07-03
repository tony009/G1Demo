//
//  RootViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface RootViewController : UIViewController


@property (nonatomic, strong) MBProgressHUD  *hud;

//显示加载
- (void)showHUD:(NSString *)title;


//隐藏加载
- (void)hideHUD;


-(void)showTipView:(NSString *)tip;

-(void)showProgressWithStatus:(NSString *)status;
-(void)hideProgressAfterDelaysInSeconds:(float)seconds;
-(void)hideProgressAfterDelaysInSeconds:(float)seconds withCompletion:(void (^)())completion;

@end
