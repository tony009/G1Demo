//
//  GatheringViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/6/27.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
@interface GatheringViewController :BaseViewController

@property (strong, nonatomic) IBOutlet UIView *calculatorView;

@property (strong, nonatomic) IBOutlet UILabel *totalNum; //合计金额

@property (strong, nonatomic) IBOutlet UILabel *num; //单次金额
@end
