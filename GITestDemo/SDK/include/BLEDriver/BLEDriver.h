//
//  BLEDriver.h
//  BLEDriver
//
//  Created by Tara. on 14-8-13.
//  Copyright (c) 2014年 yogia. All rights reserved.
//


#include "DeviceInterface.h"

#ifdef __cplusplus
extern "C"{
#endif
    
    DeviceDriverInterface * GetBLEDeviceInterface();
    
#ifdef __cplusplus
}
#endif

DeviceDriverInterface getbleinterface;
int (*DeviceReadPosData)(unsigned char *data, int datalen);
int (*DeviceReadServerData)(unsigned char *data, int datalen);
int (*deviceErrorFunc)(int error);

int DeviceOpen();
int DeviceDriverInit();
int RegisterReadPosDataFunc(DeviceReadDataFunc func);
int RegisterErrorFunc(DeviceErrorFunc func);
int DeviceClose();
int DeviceDriverDestroy();
int WritePosData(unsigned char *data, int datalen);
int WriteServerData(unsigned char *data, int datalen);
int RegisterReadServerDataFunc(DeviceReadDataFunc func);
int DeviceState();
unsigned long GetMsTime();