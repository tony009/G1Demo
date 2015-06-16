//
//  ConsumeViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
@class KCalculator;
@interface ConsumeViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextField *numberText;

@property (strong, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) IBOutlet UITextField *proText;

@property (strong, nonatomic) IBOutlet UIView *kView;
@property (strong, nonatomic)  KCalculator *kcalculatorView;

- (IBAction)startAction:(UIButton *)sender;


@end
