//
//  BleManager.m
//  GITest
//
//  Created by Femto03 on 14/11/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BleManager.h"



@implementation BleManager

static BleManager *sharedObject = nil;

+ (BleManager *)sharedManager
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
        NSLog(@"shareObject--%@",sharedObject);

    });
    return sharedObject;
    
}


- (void)startBleManager
{
    sharedObject.imBT = [[ImazeBT alloc] initWithDelegate:sharedObject withSelector:nil];
    double delayInSecondsI = 1;
    dispatch_time_t popTimeI = dispatch_time(DISPATCH_TIME_NOW, delayInSecondsI * NSEC_PER_SEC);
    dispatch_after(popTimeI, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
    [sharedObject.imBT performSelector:@selector(startScan) withObject:nil];
        
    });

}


- (void)startScan{
    [sharedObject.imBT startScan];
}




@end
