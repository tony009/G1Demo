//
//  GatheringViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface GatheringViewController :BaseViewController

@property (strong, nonatomic) IBOutlet UIView *calculatorView;

@property (strong, nonatomic) IBOutlet UILabel *totalNum; //合计金额

@property (strong, nonatomic) IBOutlet UILabel *num; //单次金额
@end
