//
//  CustomAlertView.h
//  GITestDemo
//
//  Created by 吴狄 on 15/1/5.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface CustomAlertView : UIWindow

@property (strong,nonatomic) UIView *myView;
@property (strong,nonatomic) UILabel *percentage;
@property (strong,nonatomic) UIProgressView *progressView;
@property (strong,nonatomic) UILabel *title;

-(void)show;
-(void)updateProgress:(float)progress;
-(void)updateTitle:(NSString *)title;
-(void)dismiss;
@end


@protocol CustomAlertViewDelegate <NSObject>

-(void)CustomAlertViewDismiss:(CustomAlertView *)alertView;

@end