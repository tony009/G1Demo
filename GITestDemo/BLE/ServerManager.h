//
//  ServerManager.h
//  GITestDemo
//
//  Created by 吴狄 on 14/12/17.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
@interface ServerManager : NSObject<AsyncSocketDelegate>
+ (instancetype)sharedManager;
- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port;
- (NSInteger)SocketClose;
-(void)writeData:(NSData *)data;
@property (strong,nonatomic) AsyncSocket *sock;

@end
