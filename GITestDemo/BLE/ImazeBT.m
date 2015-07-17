//
//  ImazeBT.m
//  Imaze
//
//  Created by Jean Claude Mateo on 05/01/13.
//
//

#import "ImazeBT.h"
#import "Common.h"
#import "BLEDriver.h"
#import "Anasis8583Pack.h"

@implementation ImazeBT {
    
    CBService *calibrationService;
    CBCharacteristic *characteristic1;
    CBCharacteristic *characteristic2;
    CBCharacteristic *characteristic3;
    CBCharacteristic *characteristic4;
    
}

@synthesize peripheral;
@synthesize manager;
@synthesize heartRate;
@synthesize pulseTimer;
@synthesize powerID;
@synthesize dataset;
@synthesize manufacturer;
@synthesize connected;
@synthesize delegate;
@synthesize selector;
@synthesize autoConnect;
@synthesize lastData;




- (id)initWithDelegate:(id)_delegate
          withSelector:(SEL)_selector
{
    
    self = [super init];
    
    if (self) {
        self.delegate = _delegate;
        self.selector = _selector;
        
        self.dataset = [[NSMutableDictionary alloc] init];
        
        self.heartRate = 0;
        autoConnect = TRUE;
        
        self.lastData = 0;
        
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        manager.delegate = self;
        
        
    }
	
    return self;
    
    
}






#pragma mark - BT Data received
- (NSData*)hexToBytes:(NSString *)hexString {
    
    NSMutableData *data = [NSMutableData data];
    
    int idx;
    
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *hexStr = [hexString substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    
    return data;
}


- (int)getValueForOctet:(NSString *)octet
             startIndex:(int)startIndex
                 lenght:(int)lenght
               powValue:(int)powValue {
    
    int returnInt;
    
    if ((startIndex + lenght - 1) < [octet length]) {
        
        NSString *bit = [octet substringWithRange:NSMakeRange(startIndex, lenght)];
        
        unsigned iBit;
        NSScanner *scan = [NSScanner scannerWithString:bit];
        
        if ([scan scanHexInt:&iBit]) {
            returnInt = (iBit * (pow(16,powValue)));
        } else {
            returnInt = 0;
        }
        
    } else {
        returnInt = 0;
    }
    
    
    return returnInt;
    
    
}


#pragma mark - Start/Stop Scan methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL)isLECapableHardware
{
    NSString * state = nil;
    
    BOOL flag = false;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            self.isConnected = NO;
            //通知设备已断开
            deviceErrorFunc(3);
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"Bluetooth is currently powered On.";
            flag = true;
            break;
        case CBCentralManagerStateUnknown:
            state = @"Bluetooth state is Unknown.";
        default:
           break;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    
    return flag;
}

/*
 Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
 */
- (void)startScan
{

    NSLog(@"startScan");
    [searchDevices removeAllObjects];
    if ([self isLECapableHardware]) {
        
        [manager scanForPeripheralsWithServices:nil options:nil];
        //[manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
        
    }
    
}

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void)stopScan
{
    [manager stopScan];
}

#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{

    //Let's see if we are interested in this device   using CBAdvertisementDataServiceUUIDsKey
   // NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    NSLog(@"Peripheral = %@",aPeripheral.name);
//    NSLog(@"SERVICEUUIDS = %@",serviceUUIDs);
//    NSLog(@"advertisementData = %@",advertisementData);
    
    
    [self addDiscoveredPeripheral:aPeripheral];
    
    //获取上次连接的设备名
    NSString *lastConnectDevice = [[NSUserDefaults standardUserDefaults] objectForKey:kLastConnectedDevice];
    if (_isNeedAutoConnect) {
        if (lastConnectDevice) {
            
            if ([aPeripheral.name isEqualToString:lastConnectDevice]) {
                [self connect:aPeripheral];
            }
        }
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:kDidDiscoverDevice object:nil];

}

-(void)disconnectPeripheral:(CBPeripheral*)per
{
    NSLog(@"蓝牙设备已主动断开");
    
    if (peripheral && per == nil) {
        // 主动断开
        [manager cancelPeripheralConnection:peripheral];
    }
    
    if (per) {
        [manager cancelPeripheralConnection:per];
    }
    
}
/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", (unsigned long)[peripherals count], peripherals);
    
    //[self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        
        peripheral = [peripherals objectAtIndex:0];
        
        [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [aPeripheral setDelegate:self];
    
    NSArray *serviceUUIDs  = @[[CBUUID UUIDWithString:KUUIDService],[CBUUID UUIDWithString:KUUIDService1]];
    
    [aPeripheral discoverServices:serviceUUIDs];
    peripheral = aPeripheral;
    
    [[NSUserDefaults standardUserDefaults] setObject:aPeripheral.name forKey:kLastConnectedDevice];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.connected = @"Connected";
    NSLog(@"didConnectPeripheral");
    [self stopScan];
   
    

}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
	self.connected = @"Not connected";
    self.manufacturer = @"";
    self.heartRate = 0;
    
    self.isConnected = NO;
    //通知设备已断开
    deviceErrorFunc(3);
    
    
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }

    
    NSLog(@"Device did disConnect");
    
//    [self startScan];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        
        peripheral = nil;
    }
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID : %@", aService.UUID);
        
        //Power Calibration Service
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:KUUIDService]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
            calibrationService = aService;
        }else if([aService.UUID isEqual:[CBUUID UUIDWithString:KUUIDService1]]){
            
            [aPeripheral discoverCharacteristics:nil forService:aService];
            calibrationService = aService;
        }
        
        
        
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    NSLog(@"Service : %@", [service.UUID description]);
    
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:KUUIDService]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NSLog(@"Calibration Characteristic : %@", aChar.UUID);
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"49535343-6DAA-4D02-ABF6-19569ACA69FE"]]) {
                characteristic1 = aChar;
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"49535343-ACA3-481C-91EC-D85E28A60318"]]) {
                characteristic2 = aChar;
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kUUIDRead]]) {
                characteristic3 = aChar;
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kUUIDWrite]]) {
                characteristic4 = aChar;
                
            }
        }
        
        
        if (characteristic4) {
            self.isConnected = YES;
            //通知设备已经连上
            deviceErrorFunc(2);
        }
   
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:KUUIDService1]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NSLog(@"Calibration Characteristic : %@", aChar.UUID);
            
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kUUIDRead1]]) {
                characteristic3 = aChar;
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kUUIDWrite1]]) {
                characteristic4 = aChar;
                
            }
        }
        
        
        if (characteristic4) {
            self.isConnected = YES;
            //通知设备已经连上
            [NSThread sleepForTimeInterval:2];
            deviceErrorFunc(2);
        }
        
    }
    
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    //NSLog(@"didUpdateValueForCharacteristic : %@", characteristic.UUID);


    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kUUIDRead]] || [characteristic.UUID isEqual:[CBUUID UUIDWithString:kUUIDRead1]])
    {
        if( (characteristic.value)  || !error )
        {
            
            const char *data = [characteristic.value bytes];
            
            NSUInteger length = characteristic.value.length;
            
            DeviceReadPosData(data,length);
        }
    }
    
    
}



- (void)peripheral:(CBPeripheral *)_peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
       // NSLog(@"Failed to write value for characteristic %@, reason: %@", characteristic, error);
    }
    else
    {
       // NSLog(@"Did write value for characterstic %@, new value: %@", characteristic, [characteristic value]);
        //deviceErrorFunc(7);
    }
}


#pragma mark - 测试
- (void)connect:(CBPeripheral *)aper
{
    
    //需要连接的设备为 目前已经连接的设备 直接返回
    if (self.isConnected && peripheral == aper){
        NSLog(@"重新连接");
        return;
    }
    
    //已经连接，先断开连接
    if (self.isConnected && peripheral != nil) {
             [self disconnectPeripheral:peripheral];
    }

    
    //aper
    
//    if (aper.UUID) {
//        NSLog(@"Retrieve....");
//        [manager retrievePeripherals:[NSArray arrayWithObject:(id)aper.UUID]];
//    } else {
        NSLog(@"connecting ....%@",aper.name);
        [manager connectPeripheral:aper options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        peripheral = aper;
        //[manager retrieveConnectedPeripherals];
//    }
    
}


- (void)writeValue:(NSData *)data
{
    //if ([data length]<20) return;
    if (data!= nil) {
        
        if (_type == 1) { //消费
            ClearRecvFlag();
        }
        
        
        [peripheral writeValue:data forCharacteristic:characteristic4 type:CBCharacteristicWriteWithoutResponse];
        deviceErrorFunc(7);
    }
}


-(void)addDiscoveredPeripheral:(CBPeripheral *)aPeripheral{
    
    if (searchDevices == nil) {
        searchDevices = [[NSMutableArray alloc] init];
    }
    CBPeripheral *myPeripheral = nil;
    
    
    for (uint8_t i =0; i < [searchDevices count]; i++) {
        myPeripheral = [searchDevices objectAtIndex:i];
        
        if (myPeripheral == aPeripheral) {
            return;
        }
    }
    
    //找不到就加入
    [searchDevices addObject:aPeripheral];
    
    
    
}


@end
