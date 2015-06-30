//
//  ConnectDeviceViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/12/1.
//  Copyright (c) 2014年 Kyson. All rights reserved.
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
