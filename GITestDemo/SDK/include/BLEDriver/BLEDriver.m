//
//  BLEDriver.m
//  BLEDriver
//
//  Created by jimskyship on 14/11/20.
//  Copyright (c) 2014年 femtoapp. All rights reserved.
//

#import "BLEDriver.h"
#import "BleManager.h"
#import "ServerManager.h"
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

int DeviceErrorFunc123(int error){
    
    return 0;
}

DeviceDriverInterface * GetBLEDeviceInterface()
{

    NSLog(@"GetBLEDeviceInterface start...");
    getbleinterface.DeviceOpen=&DeviceOpen;
    getbleinterface.DeviceClose=&DeviceClose;
    getbleinterface.DeviceDriverDestroy=&DeviceDriverDestroy;
    getbleinterface.DeviceState=&DeviceState;
    getbleinterface.DeviceDriverInit=&DeviceDriverInit;
    getbleinterface.DeviceDriverDestroy=&DeviceDriverDestroy;
    getbleinterface.RegisterReadPosDataFunc=&RegisterReadPosDataFunc;
    getbleinterface.RegisterErrorFunc=&RegisterErrorFunc;
    getbleinterface.WritePosData=&WritePosData;
    getbleinterface.WriteServerData =&WriteServerData;
    getbleinterface.RegisterReadServerDataFunc =&RegisterReadServerDataFunc;
    getbleinterface.GetMsTime = &GetMsTime;
    
    //deviceErrorFunc = &DeviceErrorFunc123;
    
    return &getbleinterface;
}



unsigned long GetMsTime(){
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;

    return time;
}
int WriteServerData(unsigned char *data, int datalen){
    
    
    
    ServerManager *server = [ServerManager sharedManager];
    
    server.sock.delegate = server;
    
    if (![server.sock isConnected]) {
        
        [server SocketOpen:@"122.112.12.24" port:5679];
    }else{
        NSLog(@"已经连接上服务器");
    }
    
    
    NSData *sendData = [NSData dataWithBytes:(const void *)data length:sizeof(char)*datalen];
    
    NSLog(@"WriteServerData:%@",sendData);
    
    [server writeData:sendData];
    
    return 0;
}
int RegisterReadServerDataFunc(DeviceReadDataFunc func){
    DeviceReadServerData = func;
    return 0;
}

int WritePosData(unsigned char *data, int datalen)
{
    NSLog(@"WritePosData....");
    
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
                    //NSLog(@"fail");
                }
            }
            
        }

        NSData *sendData = [NSData dataWithBytes:(const void *)data length:sizeof( char)*datalen];
        [bleManager.imBT writeValue:sendData];
        return 0;
    }
   
    
    return -1;
}

int RegisterReadPosDataFunc(DeviceReadDataFunc func)
{
    //蓝牙读取到数据时候，会执行func回调函数，这里保存了该函数指针。
    NSLog(@"readdatafunction registered.");
    DeviceReadPosData=func;
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
    NSLog(@"DeviceOpen");
    
    if (bleManager.imBT.isCollected) {
        NSLog(@"open = 0");
        return 0;
    }

    return -1;
}

int DeviceClose()
{
    NSLog(@"DeviceClose");
    
    [bleManager.imBT disconnectPeripheral:nil];
    
    return 0;
}

int DeviceDriverDestroy()
{
    NSLog(@"DeviceDriverDestory");
    return 0;
}

int DeviceState()
{

    if (bleManager.imBT.isCollected) {
        
        NSLog(@"DeviceState:设备已经连接");
        
        return 0;
    }else{
        
        NSLog(@"DeviceState:设置已断开");
        
    }
    
    return -1;
}

int RegisterErrorFunc(DeviceErrorFunc func)
{
    deviceErrorFunc = func;
    return 0;
}




