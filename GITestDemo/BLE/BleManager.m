//
//  BleManager.m
//  GITest
//
//  Created by Femto03 on 14/11/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BleManager.h"

static BleManager *sharedObject;

@implementation BleManager


+ (BleManager *)sharedManager
{
    
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
        
    }
    
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






@end
