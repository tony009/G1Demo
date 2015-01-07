//
//  CustomAlertView.m
//  GITestDemo
//
//  Created by 吴狄 on 15/1/5.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype) init{
    
    if (self = [super init]) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor clearColor];
        
        
        self.windowLevel = UIWindowLevelAlert;
        
        
        _myView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 150)];
        _myView.center = CGPointMake(self.center.x, self.center.y - 64);
        _myView.backgroundColor = [UIColor whiteColor];
        
        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 30)];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.center = CGPointMake(_myView.frame.size.width/2,_myView.frame.size.height/2-50);
        _title.text =@"Processing";
        
        
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0,0 , 200, 30)];
        _progressView.center = CGPointMake(_myView.frame.size.width/2,_myView.frame.size.height/2+20);
        
//
//        
////        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////        [okButton setTitle:@"ok" forState:UIControlStateNormal];
////        
////        okButton.frame = CGRectMake(90, 130, 80, 40);
//        
//        
//        [_myView  addSubview:okButton];
        
        _percentage = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        _percentage.textAlignment  = NSTextAlignmentCenter;
        _percentage.center = CGPointMake(_myView.frame.size.width/2, _myView.frame.size.height/2);
        _percentage.text =@"0%";
        
        
        [_myView addSubview:_percentage];
        
        [_myView addSubview:_progressView];
        
        [_myView addSubview:_title];
        
        [self addSubview:_myView];
        
        
    }
    
    
    return self;
}

-(void)show{
    [self makeKeyAndVisible];
}

-(void)dismiss{
    self.hidden = YES;
}

-(void)updateProgress:(float)progress{
    self.progressView.progress = progress;
    self.percentage.text = [NSString stringWithFormat:@"%.2f%%",progress*100];
}

-(void)updateTitle:(NSString *)title{
    self.title.text = title;
}



@end
