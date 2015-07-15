//
//  SwipingCardViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"

@interface SwipingCardViewController : BaseViewController

@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) float count;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *label;


@end
