//
//  BleManager.h
//  GITest
//
//  Created by Femto03 on 14/11/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImazeBT.h"
#import <CoreBluetooth/CoreBluetooth.h>
@class BleManager;

@protocol BleManagerDelegate <NSObject>

- (void)didConnectDevice:(NSString *)deviceName;
- (void)didDisconnectDevice:(NSString *)deviceName;

@end

@interface BleManager : NSObject

@property (nonatomic, strong) ImazeBT *imBT;
@property (nonatomic, assign) id <BleManagerDelegate> delegate;


+ (BleManager *)sharedManager;
- (void)startBleManager;
- (void)startScan;







@end
