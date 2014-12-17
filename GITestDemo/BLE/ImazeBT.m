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


void Crc16CCITT(const unsigned char *pbyDataIn, unsigned long dwDataLen, unsigned char *abyCrcOut);



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
    [self isLECapableHardware];
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{

    //Let's see if we are interested in this device   using CBAdvertisementDataServiceUUIDsKey
    NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    NSLog(@"SERVICEUUIDS = %@",serviceUUIDs);
    NSLog(@"advertisementData = %@",advertisementData);
    
    
    if (searchDevices == nil) {
        searchDevices = [[NSMutableArray alloc] init];
    }
    
    [searchDevices addObject:aPeripheral];
    
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
    [aPeripheral discoverServices:nil];
    peripheral = aPeripheral;
    
    [[NSUserDefaults standardUserDefaults] setObject:aPeripheral.name forKey:kLastConnectedDevice];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.connected = @"Connected";
    NSLog(@"Device did connected!");
    [self stopScan];
   
    

}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
	self.connected = @"Not connected";
    self.isCollected = NO;
    self.manufacturer = @"";
    self.heartRate = 0;
    
    
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
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]])
        {
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
    
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]])
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
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"449535343-1E4D-4BD9-BA61-23C647249616"]]) {
//                characteristic3 = aChar;
//            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"49535343-8841-43F4-A8D4-ECBE34729BB3"]]) {
                characteristic4 = aChar;
                
            }
        }
        
        
        if (characteristic4) {
            self.isCollected = YES;
            deviceErrorFunc(2);
        }
   
    }
    
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSLog(@"didUpdateValueForCharacteristic : %@", characteristic.UUID);
    //identifier  services  RSSI  UUID  state
    /* Updated value for heart rate measurement received */
    
//    datavaluechanged
    

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"49535343-1E4D-4BD9-BA61-23C647249616"]])
    {
        if( (characteristic.value)  || !error )
        {
            const char *data = [characteristic.value bytes];
            
            if (data[0] == 0x04 && data[1] == 0x04 && data[2] == 0x04) {
                dataLength = data[3]*256+data[4];
                curLength = 0;
            }
            
            NSUInteger length = characteristic.value.length;
            
            
            
            NSString *str = @"";
            for (int t=1;t<=length;t++)
            {
//                NSLog(@"%x",data[t-1]);
                str = [NSString stringWithFormat:@"%@,%.2x",str,data[t-1]];
            }
            NSLog(@"-recv - Str = %@  ----l = %d",str,length);
            
//            datavaluechanged(data,length);
//            return;
 
            memcpy(&allData[curLength], data, length);
            curLength += length;
            
            
            if (dataLength+8 <= curLength) {
                
                //校验
//                char str[2];
//                Crc16CCITT(&allData[3], dataLength+3, str);
//                
//                if(memcmp(&allData[dataLength+6], str, 2) == 0) {
//                 datavaluechanged(allData,dataLength+8);
//                }
                
                datavaluechanged(allData,dataLength+8);

                
                dataLength = 0;
            }
            
            
            
//            NSString *str = @"";
//            for (int t=1;t<=length;t++)
//            {
////                NSLog(@"%x",data[t-1]);
//                str = [NSString stringWithFormat:@"%@,%x",str,data[t-1]];
//            }
//            NSLog(@"-recv - Str = %@  ----l = %d",str,length);
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


#pragma mark - 
#pragma mark - 测试
- (void)connect:(CBPeripheral *)aper
{
    if (peripheral != nil) {
        [self disconnectPeripheral:peripheral];
    }
    
    
    if (aper.UUID) {
        [manager retrievePeripherals:[NSArray arrayWithObject:(id)aper.UUID]];
    } else {
        NSLog(@"connecting ....%@",aper.name);
        [manager connectPeripheral:aper options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        peripheral = aper;
        [manager retrieveConnectedPeripherals];
    }
    
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




#pragma mark - 
#pragma mark - 数据校验

const int crc16tab[] =
{
    0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
    0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
    0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
    0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
    0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
    0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
    0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
    0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
    0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
    0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
    0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
    0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
    0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
    0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
    0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
    0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
    0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
    0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
    0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
    0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
    0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
    0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
    0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
    0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
    0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
    0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
    0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
    0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
    0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
    0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
    0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
    0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
};

unsigned char flipAByte(unsigned char dat)
{
    unsigned char i;
    unsigned char v;
    
    v = 0;
    
    for(i = 0; i < 8; ++i)
    {
        v += ((dat >> (7 - i)) & 0x01) << i;
    }
    
    return v;
}

void Crc16CCITT(const unsigned char *pbyDataIn, unsigned long dwDataLen, unsigned char *abyCrcOut)
{
    unsigned short wCrc = 0;
    unsigned char result[2];
    unsigned char byTemp;
    unsigned short mg_awhalfCrc16CCITT[16];
    unsigned long i;
    int val;
    
    val = 0;
    for(i = 0;i < dwDataLen;i++)
    {
        val = (val >> 8) ^ crc16tab[(val ^ flipAByte(pbyDataIn[i])) & 0xFF];
        
    }
    result[0] = (unsigned char) (val >> 8);
    result[1] = (unsigned char) val;
    
    for(i = 0; i<2;i++)
    {
        result[i] = flipAByte(result[i]);
    }
    wCrc = (unsigned short) (result[1] << 8) + result[0];
    
    abyCrcOut[0] = wCrc>>8;
    abyCrcOut[1] = (unsigned char)wCrc;
}


@end
