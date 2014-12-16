//
//  UndoCusViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface UndoCusViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITextField *countText;
@property (strong, nonatomic) IBOutlet UITextField *noNumbertext;


- (IBAction)backoutAction:(id)sender;

@end
