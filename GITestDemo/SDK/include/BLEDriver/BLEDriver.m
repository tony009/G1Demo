//
//  BLEDriver.m
//  BLEDriver
//
//  Created by jimskyship on 14/11/20.
//  Copyright (c) 2014年 femtoapp. All rights reserved.
//

#import "BLEDriver.h"
#import "BleManager.h"
#import "Anasis8583Pack.h"

#define bleManager [BleManager sharedManager]


#pragma mark -
#pragma mark - Thread Actions

/*
 *蓝牙扫描
 */
//void *thread_BleScanAction(void *arg)
//{
//    
//    while (!bleScaned && !bleScanTimeout) {
//        NSLog(@"ble scaning!");
//    }
//    
//    return 0;
//    
//}





#pragma mark - 
#pragma mark - ****DeviceDriverInterface****

DeviceDriverInterface * GetBLEDeviceInterface()
{

    NSLog(@"GetBLEDeviceInterface start...");
    getbleinterface.DeviceOpen=&DeviceOpen;
    getbleinterface.DeviceClose=&DeviceClose;
    getbleinterface.DeviceDriverDestroy=&DeviceDriverDestroy;
    getbleinterface.DeviceState=&DeviceState;
    getbleinterface.DeviceDriverInit=&DeviceDriverInit;
    getbleinterface.DeviceDriverDestroy=&DeviceDriverDestroy;
    getbleinterface.RegisterReadDataFunc=&RegisterReadDataFunc;
    getbleinterface.RegisterErrorFunc=&RegisterErrorFunc;
    getbleinterface.WriteData=&WriteData;
    
    return &getbleinterface;
}

int WriteData(unsigned char *data, int datalen)
{
    NSLog(@"writedata....");
 
    NSLog(@"----------------------");
    NSString *s;
    s=@"";
    for (int t=1;t<=datalen;t++)
    {
        s=[NSString stringWithFormat:@"%@%.2x,",s,data[t-1]];
    }
    NSLog(@"%@",s);

    if (bleManager.imBT.connected) {

        if (_type == 1 || _type == 2) {
            ClearRecvFlag();
            
            for (int i = 0; i <= datalen; i++) {
                if (BreakupRecvPack(data[i]) == 0) {
                    NSLog(@"scc");
                } else {
//                    NSLog(@"fail");
                }
            }
            
            
            
        }
        
        
        
        
        NSData *sendData = [NSData dataWithBytes:(const void *)data length:sizeof( char)*datalen];
        [bleManager.imBT writeValue:sendData];
        return 0;
    }
   
    
    return -1;
}

int RegisterReadDataFunc(DeviceReadDataFunc func)
{
    //蓝牙读取到数据时候，会执行func回调函数，这里保存了该函数指针。
    NSLog(@"readdatafunction registered.");
    datavaluechanged=func;
    //蓝牙读取到数据后，根据该函数指针执行回调通知上层SDK，回调格式：datavaluechanged(unsigned char *data, int datalen);
    return 0;
}


int DeviceDriverInit()
{
    NSLog(@"DeviceDriverInit");
    [bleManager startBleManager];
    
    return 0;
}

int DeviceOpen()
{
    NSLog(@"deviceopen");
    
    if (bleManager.imBT.isCollected) {
        NSLog(@"open = 0");
        return 0;
    }

    return -1;
}

int DeviceClose()
{
    NSLog(@"deviceclose");
    
    [bleManager.imBT disconnectPeripheral:nil];
    
    return 0;
}
int DeviceDriverDestroy()
{
    NSLog(@"devicedriverdestory");
    return 0;
}
int DeviceState()
{

    
    
    if (bleManager.imBT.isCollected) {
            NSLog(@"devicestate:0");
        return 0;
    }
            NSLog(@"devicestate:-1");
    return -1;
}

int RegisterErrorFunc(DeviceErrorFunc func)
{
    deviceErrorFunc = func;
    return 0;
}




