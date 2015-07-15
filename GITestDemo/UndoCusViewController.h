//
//  UndoCusViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"

@interface UndoCusViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITextField *countText;
@property (strong, nonatomic) IBOutlet UITextField *noNumbertext;


- (IBAction)backoutAction:(id)sender;

@end
