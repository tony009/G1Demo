//
//  UpdateViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 14/12/31.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"

@interface UpdateViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)check:(id)sender;

- (IBAction)download:(id)sender;

- (IBAction)update:(id)sender;
@end
