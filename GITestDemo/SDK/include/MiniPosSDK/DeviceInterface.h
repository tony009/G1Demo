//
//  DeviceInterface.h
//
//  Created by Tara. on 14-8-13.
//  Copyright (c) 2014年 yogia. All rights reserved.
//

#ifndef DeviceInterface_h
#define DeviceInterface_h

#ifdef __cplusplus
extern "C"{
#endif
    
//#define MY_DEBUG
    
#ifdef MY_DEBUG
    
#ifdef ANDROID
#include <android/log.h>
#define DEBUGPrintf(fmt, ...)  __android_log_print(ANDROID_LOG_INFO, "JNIMsg", "%s(%04d):" fmt "\n",__FILE__,__LINE__,##__VA_ARGS__);
#else
#define DEBUGPrintf(fmt, ...)  printf("%s(%04d):" fmt "\n",__FILE__,__LINE__,##__VA_ARGS__);
#endif
    
#define MyNSLog NSLog
    
#else
    
#define DEBUGPrintf(fmt, ...)
#define MyNSLog(fmt, ...)
    
#endif

#define DEVICE_ERROR_NO_REGISTE_INTERFACE   1
#define DEVICE_ERROR_PLUG_IN                2
#define DEVICE_ERROR_PLUG_OUT               3
#define DEVICE_ERROR_SEND_ERROR             4
#define DEVICE_ERROR_RECIVE_ERROR           5
#define DEVICE_ERROR_NO_DEVICE              6
#define DEVICE_ERROR_SEND_FINISH            7
#define DEVICE_ERROR_DEVICE_RECIVED_REQUEST 8
#define DEVICE_ERROR_RESPONCE_TIMEOUT       9
    
/**********************************************
 * 函数指针名：DeviceReadDataFunc
 * 功能：把收到的数据告诉上层
 * 参数：data 为需要发送的数据地址， datalen 为需要发送的数据长度
 * 返回值：0 表示处理接收数据成功， -1 表示处理接收数据失败
 **********************************************/

typedef int (*DeviceReadDataFunc)(unsigned char *data, int datalen);

/**********************************************
 * 函数指针名：DeviceErrorFunc
 * 功能：把出现的错误，如设备断开，发送数据失败等异常通知上传协议
 * 参数：error 为错误码 DEVICE_ERROR_PLUG_OUT 等
 * 返回值：0 表示处理错误成功， -1 表示处理错误失败
 **********************************************/

typedef int (*DeviceErrorFunc)(int error);


typedef struct _DeviceDriverInterface
{
    /**********************************************
     * 函数指针名：DeviceDriverInit
     * 功能：驱动初始化
     * 参数：无
     * 返回值：0 表示初始化成功， -1 表示初始化失败
     **********************************************/
    
    int (*DeviceDriverInit)();
    
    /**********************************************
     * 函数指针名：DeviceDriverDestroy
     * 功能：关闭驱动
     * 参数：无
     * 返回值：0 表示销毁成功， -1 表示销毁失败
     **********************************************/
    
    int (*DeviceDriverDestroy)();
    
    /**********************************************
     * 函数指针名：DeviceOpen
     * 功能：打开设备，准备读写数据
     * 参数：无
     * 返回值：0 表示打开设备成功， -1 表示打开失败失败
     **********************************************/
    
    int (*DeviceOpen)();
    
    /**********************************************
     * 函数指针名：DeviceClose
     * 功能：关闭设备，不再读写数据
     * 参数：无
     * 返回值：0 表示关闭设备成功， -1 表示关闭设备失败
     **********************************************/
    
    int (*DeviceClose)();
    
    /**********************************************
     * 函数指针名：DeviceState
     * 功能：返回设备连接状态
     * 参数：无
     * 返回值：0 表示设备已连接， -1 表示设备未连接
     **********************************************/
    
    int (*DeviceState)();
    
    /**********************************************
     * 函数指针名：WritePosData
     * 功能：向pos机发送数据
     * 参数：data 为需要发送的数据地址， datalen 为需要发送的数据长度
     * 返回值：0 表示发送成功， -1 表示发送失败
     **********************************************/
    
    int (*WritePosData)(unsigned char *data, int datalen);
    
    /**********************************************
     * 函数指针名：RegisterReadPosDataFunc
     * 功能：注册读取pos数据回调函数
     * 参数：func 为数据接收回调函数
     * 返回值：0 表示注册成功， -1 表示注册失败
     **********************************************/
    int (*RegisterReadPosDataFunc)(DeviceReadDataFunc func);
    /**********************************************
     * 函数指针名：WriteServerData
     * 功能：向服务器发送数据
     * 参数：data 为需要发送的数据地址， datalen 为需要发送的数据长度
     * 返回值：0 表示发送成功， -1 表示发送失败
     **********************************************/
    int (*WriteServerData)(unsigned char *data, int datalen);
    
    /**********************************************
     * 函数指针名：RegisterReadServerDataFunc
     * 功能：注册读取服务数据回调函数
     * 参数：func 为数据接收回调函数
     * 返回值：0 表示注册成功， -1 表示注册失败
     **********************************************/
    int (*RegisterReadServerDataFunc)(DeviceReadDataFunc func);
    

    /**********************************************
     * 函数指针名：RegisterErrorFunc
     * 功能：注册设备异常出错处理函数
     * 参数：func 为设备出错后的回调函数
     * 返回值：0 表示注册成功， -1 表示注册失败
     **********************************************/
    int (*RegisterErrorFunc)(DeviceErrorFunc func);
    
    
    /**********************************************
     * 函数指针名：GetMsTime
     * 功能：获取微秒级数据
     * 参数：func 为数据接收回调函数
     * 返回值：0 表示注册成功， -1 表示注册失败
     **********************************************/
    unsigned long (*GetMsTime)();
    
    //    int (*WriteData)(unsigned char *data, int datalen);
    //
    //    /**********************************************
    //     * 函数指针名：RegisterReadDataFunc
    //     * 功能：注册数据接受回调函数
    //     * 参数：func 为数据接收回调函数
    //     * 返回值：0 表示注册成功， -1 表示注册失败
    //     **********************************************/
    //
    //    int (*RegisterReadDataFunc)(DeviceReadDataFunc func);
    
    
} DeviceDriverInterface;
    
#ifdef __cplusplus
}
#endif

#endif
