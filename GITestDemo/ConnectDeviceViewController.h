//
//  ConnectDeviceViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"

@interface ConnectDeviceViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UILabel *bleStatusLabel;

@property (strong, nonatomic) IBOutlet UILabel *audioStatusLabel;


@property (strong, nonatomic) IBOutlet UILabel *bluetoothName;
@property (strong, nonatomic) IBOutlet UILabel *SN;
@property (strong, nonatomic) IBOutlet UILabel *time;




@property (nonatomic, strong) UITableView *deviceTable;
@property (nonatomic, strong) UIView *deviceView;

- (IBAction)bleConnectAction:(UIButton *)sender;

@end
