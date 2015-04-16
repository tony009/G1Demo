//
//  ImazeBT.h
//  Imaze
//
//  Created by Jean Claude Mateo on 05/01/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ImazeBT : NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    
    NSMutableArray *heartRateMonitors;
    NSMutableDictionary *dataset;
    
    NSString *manufacturer;
    
    uint16_t heartRate;
    
    BOOL autoConnect;
    
    NSTimeInterval lastData;
    
    id delegate;
    SEL selector;
    
    
    
    int dataLength;
    int curLength;
    char allData[800];
    
    
}

@property (strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBPeripheral *peripheral;

@property (nonatomic) uint16_t heartRate;
@property (strong, nonatomic) NSTimer *pulseTimer;
@property (nonatomic) NSString *powerID;
@property (strong, nonatomic) NSMutableDictionary *dataset;
@property (strong, nonatomic) NSString *manufacturer;




@property (strong, nonatomic) NSString *connected;
@property (nonatomic, assign) BOOL isConnected;  //设备是否连接
@property (nonatomic, strong) CBPeripheral *waitAper;
@property (nonatomic, assign) int bleState;

@property (nonatomic) BOOL autoConnect;

@property (nonatomic) NSTimeInterval lastData; 
@property (strong, nonatomic) id delegate;
@property (nonatomic) SEL selector;
- (id)initWithDelegate:(id)_delegate
          withSelector:(SEL)_selector;
- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;


/*
 *测试
 */

- (void)connect:(CBPeripheral *)peripheral;
- (void)writeValue:(NSData *)data;
-(void)disconnectPeripheral:(CBPeripheral*)per;
@end
