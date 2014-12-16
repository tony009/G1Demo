//
//  AudioDriver.h
//  AudioDriver
//
//  Created by Tara. on 14-8-13.
//  Copyright (c) 2014年 yogia. All rights reserved.
//

#include "DeviceInterface.h"

#ifdef __cplusplus
extern "C"{
#endif

extern int g_printData;

DeviceDriverInterface * GetAudioDeviceInterface();
DeviceDriverInterface * GetHFPDeviceInterface();
    
#ifdef __cplusplus
}
#endif

