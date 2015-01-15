//
//  ServerManager.m
//  GITestDemo
//
//  Created by 吴狄 on 14/12/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "ServerManager.h"
#import "BLEDriver.h"

@implementation ServerManager

+ (instancetype)sharedManager
{
    
    static ServerManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
        
        sharedObject.sock = [[AsyncSocket alloc]init];
        
    });
    
    return sharedObject;
    
}

//发送数据
-(void)writeData:(NSData *)data
{
    
    [_sock writeData:data withTimeout:-1 tag:0];
    
}

//打开
- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    if (![_sock isConnected])
    {
        [_sock connectToHost:addr onPort:port withTimeout:-1 error:nil];
        
        NSLog(@"connect to Host:%@ Port:%d",addr,port);
    }
    return 0;
}


//关闭
- (NSInteger)SocketClose
{
    if ([_sock isConnected])
    {
        [_sock disconnect];
    }
    return 0;
}


#pragma mark Delegate

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"willDisconnectWithError:%@",err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketDidDisconnect");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    NSLog(@"didConnectToHost");
    
    //这是异步返回的连接成功，
    
    //[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    
    
    NSLog(@"didReadData:%@",data);
    
    const char * readData = [data bytes];
    DeviceReadServerData(readData,[data length]);
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(msg)
    {
        //处理受到的数据
        NSLog(@"-收到的数据:%@",msg);
    }
    
    [self SocketClose];

}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag:%ld",tag);
    [sock readDataWithTimeout:-1 tag:0];
}

@end
