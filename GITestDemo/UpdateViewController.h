//
//  UpdateViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomAlertView.h"
@interface UpdateViewController : BaseViewController <UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction)check:(id)sender;

- (IBAction)download:(id)sender;

- (IBAction)update:(id)sender;
@end
