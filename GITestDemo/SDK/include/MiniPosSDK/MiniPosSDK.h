//
//  MiniPosSDK.h
//  MiniPosSDK
//
//  Created by Tara. on 14-8-13.
//  Copyright (c) 2014年 yogia. All rights reserved.
//

/*
 
//SDK使用说明

//第一步，初始化SDK
//第二步，注册SDK回调函数
//第三步，注册与设备通讯驱动，支持蓝牙、音频、USB通讯驱动
//第四步，设置POS中心服务器IP地址，端口号
//第五步，调用交易请求函数

static void MiniPosSDKResponce(void *userData,
                               MiniPosSDKSessionType sessionType,
                               MiniPosSDKSessionError responceCode,
                               const char *deviceResponceCode,
                               const char *displayInfo)
{
    printf("MiniPosSDKResponce sessionType: %d responceCode: %d",sessionType,responceCode);
    
    if(responceCode==SESSION_ERROR_NO_REGISTE_INTERFACE)
    {
        printf("没有注册设备与手机之间的通讯驱动\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_NO_SET_PARAM)
    {
        printf("没有设置参数\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_NO_DEVICE)
    {
        printf("没有检测到设备\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_PLUG_IN)
    {
        printf("设备已经插入\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_PLUG_OUT)
    {
        printf("设备已经拔出\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_DEVICE_NO_RESPONCE)
    {
        printf("设备对请求没有响应\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_SEND_8583_ERROR)
    {
        printf("发送8583包出错\n");
        return;
    }
    else if(responceCode==SESSION_ERROR_RECIVE_8583_ERROR)
    {
        printf("接收8583包出错\n");
        return;
    }
    
    if(sessionType==SESSION_POS_LOGIN)
    {
        if(responceCode==SESSION_ERROR_ACK)
        {
            printf("签到成功\n");
        }
        else if(responceCode==SESSION_ERROR_NAK)
        {
            printf("签到失败 %s %s\n",deviceResponceCode?deviceResponceCode:" ",displayInfo?displayInfo:" ");
        }
    }
    else if(sessionType==SESSION_POS_SALE_TRADE)
    {
        if(responceCode==SESSION_ERROR_ACK)
        {
            printf("消费成功\n");
        }
        else if(responceCode==SESSION_ERROR_NAK)
        {
            printf("消费失败 %s %s\n",deviceResponceCode?deviceResponceCode:" ",displayInfo?displayInfo:" ");
        }
    }
}

void testSDK()
{
 
 //第一步，初始化SDK
 MiniPosSDKInit();
 
 //第二步，注册与设备通讯驱动
 MiniPosSDKRegisterDeviceInterface(GetBLEDeviceInterface());
 
 //第三步，注册SDK回调函数
 MiniPosSDKAddDelegate((__bridge void*)self, MiniPosSDKResponce);
 
 //第四步，调用交易请求函数
 MiniPosSDKPosLogin();
}

*/


#ifndef MiniPosSDK_h
#define MiniPosSDK_h

#include "DeviceInterface.h"
#include "FunctionDefine.h"

#ifdef __cplusplus
extern "C"{
#endif

/************************************************************
 MiniPosSDKSessionType 表示会话类型、用户请求类型
 *************************************************************/
   
typedef enum _MiniPosSDKSessionType
{
    SESSION_POS_UNKNOWN,
    SESSION_POS_LOGIN,                      //POS机签到
    SESSION_POS_GET_DEVICE_INFO,            //获取设备信息
    SESSION_POS_SALE_TRADE,                 //消费
    SESSION_POS_VOIDSALE_TRADE,             //撤销消费
    SESSION_POS_QUERY,                      //查磁条卡余额
    SESSION_POS_SETTLE,                     //结算
    SESSION_POS_DOWNLOAD_KEY,               //公钥下载
    SESSION_POS_DOWNLOAD_AID_PARAM,         //AID参数下载
    SESSION_POS_DOWNLOAD_PARAM,             //参数下载
    SESSION_POS_PRINT,                      //打印
    SESSION_POS_GET_DEVICE_ID,              //获取设备序列号
    SESSION_POS_CANCEL_READ_CARD,           //取消刷卡
    SESSION_POS_READ_CARD_INFO,             //读取磁道信息
    SESSION_POS_READ_PIN_CARD_INFO,         //输密并读取磁道信息
    SESSION_POS_READ_IC_INFO,         		//读取IC卡信息
    SESSION_POS_UPDATE_KEY,         		//更新工作密钥
    SESSION_POS_LOGOUT,	         			//签退
    SESSION_POS_CANCEL,						//取消操作
    SESSION_POS_DOWN_PRO,					//下载程序
    SESSION_POS_UPLOAD_PARAM				//上传参数
} MiniPosSDKSessionType;

/************************************************************
 MiniPosSDKSessionError 表示设备返回的应答及设备当前的连接状态
 *************************************************************/
typedef enum _MiniPosSDKSessionError
{
    SESSION_ERROR_ACK,                      //设备成功处理会话请求,并返回成功
    SESSION_ERROR_NAK,                      //设备拒绝会话请求，或处理请求出错
    SESSION_ERROR_NO_REGISTE_INTERFACE,     //没有注册设备与手机之间的通讯驱动
    SESSION_ERROR_NO_DEVICE,                //没有检测到设备
    SESSION_ERROR_DEVICE_PLUG_IN,           //设备已经插入
    SESSION_ERROR_DEVICE_PLUG_OUT,          //设备已经拔出
    SESSION_ERROR_DEVICE_NO_RESPONCE,       //设备对请求没有响应
    SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT,  //设备对请求响应超时
    SESSION_ERROR_SEND_8583_ERROR,          //发往POS中心的8583包没有发送成功，请检查网络和服务器IP和端口是否正确
    SESSION_ERROR_RECIVE_8583_ERROR,        //接收POS中心回的8583包出错，请检查网络是否正常
    SESSION_ERROR_NO_SET_PARAM,             //没有设置公共参数或没有设置POS中心IP端口
    SESSION_ERROR_DEVICE_BUSY,              //设备繁忙，请稍后再试
    SESSION_ERROR_DEVICE_SEND,              //发送失败
    SESSION_ERROR_SHAKE_PACK                //收到握手包
    
} MiniPosSDKSessionError;


/************************************************************
 MiniPosSDK结构体
 *************************************************************/
typedef struct _MiniPosSDK MiniPosSDK;

/************************************************************
 MiniPossSDK的回调接口原型
 参数1 userData是用户自定义的数据指针，原值返回
 参数2 sessionType是请求类型
 参数3 responceCode是请求结果，或设备变更后的状态
 参数4 deviceResponceCode是设备返回的应答码
 参数5 displayInfo是设备返回的应答说明，采用GBK编码
 *************************************************************/
typedef void (*MiniPosSDKResponceFunc)(void *userData,
                                        MiniPosSDKSessionType sessionType,
                                        MiniPosSDKSessionError responceCode,
                                        const char *deviceResponceCode,
                                        const char *displayInfo);


/************************************************************
 初始化MiniPossSDK，返回MiniPosSDK结构体指针
 *************************************************************/
int MiniPosSDKInit();

/************************************************************
 销毁MiniPossSDK
 参数1 MiniPosSDKInit返回的结构体指针
 *************************************************************/
int MiniPosSDKDestroy(MiniPosSDK* sdk);


/************************************************************
 注册MiniPossSDK的回调接口
 参数1 userData是用户自定义的数据指针，SDK在调用回调函数时会原值返回userData指针，可以为NULL
 参数2 miniPosSDKResponce是SDK回调函数，SDK有状态变化时，会调用该回调函数

 可以注册多个回调函数
 
 *************************************************************/
int MiniPosSDKAddDelegate(void *userData, MiniPosSDKResponceFunc miniPosSDKResponce);

/************************************************************
 移除MiniPossSDK的某个回调接口
 参数1 注册回调接口时传入的userData参数
 *************************************************************/
int MiniPosSDKRemoveDelegate(void *userData);

    
/************************************************************
 注册驱动接口
 参数1 驱动接口
 *************************************************************/
int MiniPosSDKRegisterDeviceInterface(DeviceDriverInterface *driverInterface);

/************************************************************
 设置公共参数：商户号，终端号，操作员号
 参数1（商户号）	AN15 	商户代码
 参数2（终端号）	AN8 	终端号
 参数3（操作员号）	AN15	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSetPublicParam(const char *merchantCode, const char *terminalCode, const char *operatorCode);

/************************************************************
 设置POS中心IP地址或域名、端口号、网络连接是否使用SSL
 参数1（POS中心IP地址或域名）	AN
 参数2（端口号）            int
 参数3（是否使用SSL）       int  0：不使用 1：使用
 *************************************************************/
int MiniPosSDKSetPostCenterParam(const char *host, int port, int isUseSSL);
    
/************************************************************
 获取设备状态
 返回值： -1表示设备未连接，0表示设备已连接
 *************************************************************/
int MiniPosSDKDeviceState();

/************************************************************
 签到指令
 *************************************************************/
int MiniPosSDKPosLogin();

/************************************************************
 签退指令
 *************************************************************/
int MiniPosSDKPosLogout();
    
/************************************************************
 获取设备信息指令
 *************************************************************/
int MiniPosSDKGetDeviceInfoCMD();

/************************************************************
 消费
 参数1（金额参数）	N12 	以分为单位，前补’0’
 参数2（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSaleTradeCMD(const char *amount, const char *cashierSerialCode, const char* t);

/************************************************************
 消费撤销
 参数1（原交易金额）	N12 	以分为单位，前补’0’， 当不为全’0’时，POS 与原交易金额比对，否则忽略此参数
 参数2 (原交易凭证号)	N6	若为“空”，则POS 提示操作员输入
 参数3（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKVoidSaleTradeCMD(const char *amount, const char *serialCode, const char *cashierSerialCode);
    
/************************************************************
 查询余额
 *************************************************************/
int MiniPosSDKQuery();
    
/************************************************************
 结算
 参数1（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSettleTradeCMD(const char *cashierSerialCode);

/************************************************************
 公钥下载
 *************************************************************/
int MiniPosSDKDownloadKeyCMD();

/************************************************************
 AID参数下载指令
 *************************************************************/
int MiniPosSDKDownloadAIDParamCMD();

/************************************************************
 参数下载
 *************************************************************/
int MiniPosSDKDownloadParamCMD();
  
/************************************************************
 获取设备ID
 需要先调用获取设备信息指令MiniPosSDKGetDeviceInfoCMD成功后，才会返回设备ID
 *************************************************************/
char * MiniPosSDKGetDeviceID();

/************************************************************
 获取设备Core版本号
 需要先调用获取设备信息指令MiniPosSDKGetDeviceInfoCMD成功后，才会返回设备Core版本号
 *************************************************************/
char * MiniPosSDKGetCoreVersion();

/************************************************************
 获取设备应用版本号
 需要先调用获取设备信息指令MiniPosSDKGetDeviceInfoCMD成功后，才会返回设备应用版本号
 *************************************************************/
char * MiniPosSDKGetAppVersion();

/************************************************************
 获取当前正在进行的会话类型
 *************************************************************/
MiniPosSDKSessionType MiniPosSDKGetCurrentSessionType();


/************************************************************
 取消刷卡指令
 *************************************************************/
int MiniPosSDKCancelCMD();

///************************************************************
//传输固件
//*************************************************************/
//int DownThread(void *cva,NSArray *array);

/************************************************************
超时检测
*************************************************************/
int MiniPosSDKRunThread();
    
/***********************************************************
固件更新指令
*************************************************************/
int MiniPosSDKDownPro();
    
/************************************************************
修改pos端的参数
参数1（系统代码）	"000000000"
参数2（参数名称）
参数3（参数值）
*************************************************************/
int MiniPosSDKSetParam(const char* syscode, const char* paramname, const char* paramvalue);

    
/************************************************************
 从pos端获取参数
 参数1（系统代码）	"88888888"
 参数2（参数名称）
*************************************************************/
int MiniPosSDKGetParams(const char* syscode, const char* paramname);
    
/************************************************************
 解析从pos端获取的参数
 参数1 参数名称
*************************************************************/
char *MiniPosSDKGetParam(char* paramname);
    
    
#ifdef __cplusplus
}
#endif

#endif