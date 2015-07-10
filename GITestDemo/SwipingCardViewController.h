//
//  SwipingCardViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface SwipingCardViewController : BaseViewController

@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) float count;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *label;


@end
