#include "DeviceInterface.h"
#import "MiniPosSDK.h"
#define PROTOCOL_STANDARD_CCID	0x01
#define PROTOCOL_EXTERND_CCID	0x02
#define PROTOCOL_UNKNOWN		0xFF





typedef void (*SDKResponceFunc)(void *userData,
	MiniPosSDKSessionType sessionType,
	MiniPosSDKSessionError responceCode,
	const char *deviceResponceCode,
	const char *displayInfo);
typedef unsigned long (*GetMsFun)(void);
typedef int (*DeviceReadDataFunc)(unsigned char *data, int datalen);
typedef int (*DeviceErrorFunc)(int error);


#define GET_ERR_CODE(err) (*(unsigned short*)err) 
#define GET_ERR_DESC(err) (unsigned char*)((unsigned char*)err + 2)

#define ERR_NO				"\x00\x00操作成功"
#define ERR_TIMEOUT			"\x00\x01超时"
#define ERR_IN_PROGRESS		"\x00\x02正在进行"
#define ERR_PACKET_FORMAT	"\x00\x03数据包格式错误"
#define ERR_VERIFY_PACK		"\x00\x04校验错误"
#define ERR_OTHER			"\x00\x05其他未统计错误"
#define ERR_PACKET_LEN		"\x00\x06数据包长度错误"
#define ERR_EXCEED_RETRY	"\x00\x07超过重传次数"
#define ERR_REPLAY_DATA		"\x00\x08应答数据错误，格式正确"
#define ERR_RELAY_DECLINE	"\x00\x09应答拒绝"
#define ERR_SEND			"\x00\x0A发送失败"

#define MAX_PACKET_LEN 2048
#define BUF_SIZE 500
#define MAX_RETRY 3
#define MAX_POS_TIMEOUT 2000		//从POS机返回指令超时
#define MAX_SERVER_TIMEOUT 60000	//从后台返回数据超时
#define GET_PACKET_CNT(buf) buf[5]
#define GET_PACKET_TYPE(buf) buf[6]
#define GET_PACKET_ATTRIBUTE(buf) buf[9]
#define GET_PACKET_LEN(buf) ((((unsigned short)buf[3]) << 8) + (unsigned short)buf[4])
#define GET_DATA_LEN(buf) (((((unsigned short)buf[7]) << 8) + (unsigned short)buf[8]) - 1)
#define GET_DATA_INDEX(buf) ((unsigned char*)&buf[10])
int ReadServerData(unsigned char *data, int datalen);
unsigned short AnasisPacket(unsigned char*buf, unsigned char element, unsigned char isrestart);
void my_memcpy(unsigned char* src, unsigned char* dest, int len, unsigned char direction);
#define MAX_PACKET_LEN 2048
#define BUF_SIZE 500
#define MAX_RETRY 3
#define MAX_POS_TIMEOUT 2000		//从POS机返回指令超时
#define MAX_SERVER_TIMEOUT 60000	//从后台返回数据超时
void Crc16CCITT(const unsigned char *pbyDataIn, unsigned long dwDataLen, unsigned char *abyCrcOut);

int ReadPosData(unsigned char *data, int datalen);
struct _DeviceDriverInterface *gInterface = NULL;

static unsigned char gSDKMerchantCode[16];
static unsigned char gSDKTerminalCode[9];
static unsigned char gSDKOperator[3];
static void* gUserData = NULL;

static SDKResponceFunc gResponseFun = NULL;
static unsigned char gInputParam[100];

#define PACK_STEP_IDLE 0x01
#define PACK_STEP_SHAKE 0x02
#define PACK_STEP_POS_STRUCT 0x03
#define PACK_STEP_SEND_SERVER 0x04
#define PACK_STEP_RETURN_POS 0x05
#define PACK_STEP_RETURN_REPLY 0x06

static unsigned char gSDKBuf[800];
static unsigned char gRecvBuf[800];
static unsigned short gRecvLen = 0;
static unsigned char gSDKCnt = 0x00;
static unsigned char gDealPackStep = PACK_STEP_IDLE;
static MiniPosSDKSessionType gSessionPos = SESSION_POS_UNKNOWN;
static unsigned long gSaveTime = 0;
static unsigned long gTimeOut = 0;
static unsigned char gWaitConfirm = 0;

int DealGetDeviceInfo();
int DealLoadAID();
int DealLoadKey();
int MiniPosSDKTestConnect(void);
int DealVoidSaleTrade();

int MiniPosSDKInit()
{
	gSessionPos = SESSION_POS_UNKNOWN;
	gWaitConfirm = 0;

	if(gInterface)
	{
		gSaveTime = gInterface->GetMsTime();
	}

	gRecvLen = 0;
	gSessionPos = SESSION_POS_UNKNOWN;

	return 0;
}

int MiniPosSDKCancelCMD()
{
	gSessionPos = SESSION_POS_UNKNOWN;

	return 0;
}

int MiniPosSDKRunThread()
{
	switch(gDealPackStep)
	{
	case PACK_STEP_IDLE:
		break;
	case PACK_STEP_POS_STRUCT:
		break;
	case PACK_STEP_RETURN_POS:
		break;
	case PACK_STEP_SEND_SERVER:
		break;
	case PACK_STEP_SHAKE:
		break;
	}

	if(gInterface
		&& gInterface->GetMsTime() > gSaveTime + gTimeOut 
		&& gSaveTime
		&& gTimeOut
		&& gSessionPos != SESSION_POS_UNKNOWN)
	{
		gResponseFun(gUserData,
			gSessionPos,
			SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT,
			NULL,
			NULL);
		gSessionPos = SESSION_POS_UNKNOWN;
	}

	return 0;
}
/************************************************************
 设置公共参数：商户号，终端号，操作员号
 参数1（商户号）	AN15 	商户代码
 参数2（终端号）	AN8 	终端号
 参数3（操作员号）	AN15	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSetPublicParam(const char *merchantCode, const char *terminalCode, const char *operatorCode)
{
	memset((char*)gSDKMerchantCode, 0x00, sizeof(gSDKMerchantCode));
	memset((char*)gSDKTerminalCode, 0x00, sizeof(gSDKTerminalCode));
	memset((char*)gSDKOperator, 0x00, sizeof(gSDKOperator));
	strncpy((char*)gSDKMerchantCode, merchantCode, 15);
	strncpy((char*)gSDKTerminalCode, terminalCode, 8);
	strncpy((char*)gSDKOperator, operatorCode, 2);

	return 0;
}

int MiniPosSDKAddDelegate(void *userData, SDKResponceFunc SDKResponce)
{
    gUserData = userData;
	gResponseFun = SDKResponce;


	return 0;
}




int ErrorFunc(int error)
{
    
    
    MiniPosSDKSessionError sessionerror =-1;
    
    switch(error)
    {
        case DEVICE_ERROR_NO_REGISTE_INTERFACE:
            sessionerror = SESSION_ERROR_NO_REGISTE_INTERFACE;
            break;
        case DEVICE_ERROR_PLUG_IN:
            sessionerror = SESSION_ERROR_DEVICE_PLUG_IN;
            MiniPosSDKTestConnect();
            break;
        case DEVICE_ERROR_PLUG_OUT:
            sessionerror = SESSION_ERROR_DEVICE_PLUG_OUT;
            break;
        case DEVICE_ERROR_SEND_ERROR:
            sessionerror = SESSION_ERROR_DEVICE_SEND;
            break;
        case DEVICE_ERROR_RECIVE_ERROR:
            sessionerror = SESSION_ERROR_NO_REGISTE_INTERFACE;
            break;
        case DEVICE_ERROR_NO_DEVICE:
            sessionerror = SESSION_ERROR_NO_DEVICE;
            break;
        case DEVICE_ERROR_SEND_FINISH:
            //sessionerror = SESSION_ERROR_ACK;
            break;
            /*case DEVICE_ERROR_DEVICE_RECIVED_REQUEST:
             sessionerror = SESSION_ERROR_NO_REGISTE_INTERFACE;
             break;*/
        case DEVICE_ERROR_RESPONCE_TIMEOUT:
            sessionerror = SESSION_ERROR_DEVICE_RESPONCE_TIMEOUT;
            break;
        default:
            break;
    }
    gResponseFun(gUserData,
                 gSessionPos,
                 (MiniPosSDKSessionError)sessionerror,
                 NULL,
                 NULL);
    return 0;
}

/************************************************************
 注册驱动接口
 参数1 驱动接口
 *************************************************************/
int MiniPosSDKRegisterDeviceInterface(DeviceDriverInterface *driverInterface)
{
	gInterface = driverInterface;
	gInterface->RegisterReadPosDataFunc(ReadPosData);
	gInterface->RegisterReadServerDataFunc(ReadServerData);
	gSaveTime = gInterface->GetMsTime();
    gInterface->RegisterErrorFunc(ErrorFunc);
    gInterface->DeviceDriverInit();
    gInterface->DeviceOpen();
    
	return 0;
}

int SDKSendToPos(unsigned char* buf, int* len)
{
	if(gWaitConfirm)
	{
		//等待确认的时候不允许发送数据
		return -1;
	}
	my_memcpy((unsigned char*)buf, (unsigned char*)&buf[7], *len, 0);
	memcpy((char*)&buf[0], "\x04\x04\x04", 3);
	buf[3] = ((*len + 2) >> 8);
	buf[4] = ((*len + 2) & 0x000000FF);
	buf[5] = gSDKCnt;
	buf[6] = 0x00;
	buf[*len + 7] = 0x03;
	Crc16CCITT((unsigned char*)&buf[3], *len + 5, 
		(unsigned char*)&buf[*len + 8]);

	gSDKCnt++;
	gWaitConfirm = 1;
	gRecvLen = 0;

	gSaveTime = gInterface->GetMsTime();
	return gInterface->WritePosData((unsigned char*)buf, *len + 10);
}

int MiniPosSDKTestConnect(void)
{
	int len;
	unsigned char confirmcnt;
	unsigned long tm;

	if(gInterface == NULL)
	{
		gResponseFun(gUserData,
			gSessionPos,
			SESSION_ERROR_NO_REGISTE_INTERFACE,
			NULL,
			NULL);

		return -1;
	}

	memcpy(gSDKBuf, "\x00\x03\x01\x39\x39", 5);
	len = 5;

	gSaveTime = gInterface->GetMsTime();
	if(SDKSendToPos(gSDKBuf, &len) < 0)
	{
		gResponseFun(gUserData,
			gSessionPos,
			SESSION_ERROR_DEVICE_SEND,
			NULL,
			NULL);

		return -1;
	}

	return 0;
}


int SDKDownParam(const char* syscode, const char* paramname, const char* paramvalue)
{
	int len;
	unsigned char confirmcnt;
	unsigned char replycnt;
	unsigned long tm;
	
	if(gSessionPos != SESSION_POS_UNKNOWN)
	{
		return -1;
	}
	gSessionPos = SESSION_POS_DOWNLOAD_PARAM;
	if(MiniPosSDKTestConnect() < 0)
	{
		gSessionPos = SESSION_POS_UNKNOWN;
		return -1;
	}
	
	for(replycnt = 0; replycnt < MAX_RETRY; replycnt++)
	{
		for(confirmcnt = 0; confirmcnt < MAX_RETRY; confirmcnt++)
		{
			//组装报文
			memcpy(gSDKBuf, "\x00\x04\x03\x35\x35", 5);
			len = 5;
			memset((char*)&gSDKBuf[len], 0x00, 8);
			strncpy((char*)&gSDKBuf[len], (char*)syscode, 8);
			len += 8;
			gSDKBuf[len] = 0x00;
			len++;
			if(paramname)
			{
				strncpy((char*)&gSDKBuf[len], (char*)paramname, 32);
				len += strlen((char*)&gSDKBuf[len]);
				gSDKBuf[len] = 0x00;
				len++;
			}
			if(paramvalue)
			{
				strncpy((char*)&gSDKBuf[len], (char*)paramvalue, 32);
				len += strlen((char*)&gSDKBuf[len]);
				gSDKBuf[len] = 0x00;
				len++;
			}
			gSDKBuf[0] = (len - 2) >> 8;
			gSDKBuf[1] = len - 2;

			if(SDKSendToPos(gSDKBuf, &len) < 0)
			{
				continue;
			}

			tm = gInterface->GetMsTime();
			while(gWaitConfirm)
			{
				if(tm + MAX_POS_TIMEOUT < gInterface->GetMsTime())
				{
					break;
				}
			}
			if(gWaitConfirm)
			{
				continue;
			}
			else
			{
				//指令应答成功
				break;
			}
		}
		if(confirmcnt >= MAX_RETRY)
		{
			//gSessionPos = SESSION_POS_UNKNOWN;
			continue;
		}
		tm = gInterface->GetMsTime();
		while(1)
		{
			if(gRecvLen > 3)
			{
				//if(/*GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x04 &&*/ *GET_DATA_INDEX(gRecvBuf) == 0x06)
				{
					gSessionPos = SESSION_POS_UNKNOWN;
					return 0;
				}
			}
			if(tm + MAX_POS_TIMEOUT < gInterface->GetMsTime())
			{
				break;
			}
		}
	}

	gSessionPos = SESSION_POS_UNKNOWN;

	if(replycnt >= MAX_RETRY)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

int MiniPosSDKUploadParam(const char* syscode, const char* paramname, const char* paramvalue)
{
	int len;
	unsigned char confirmcnt;
	unsigned char replycnt;
	unsigned long tm;

	if(gSessionPos != SESSION_POS_UNKNOWN)
	{
		return -1;
	}
	gSessionPos = SESSION_POS_DOWNLOAD_PARAM;
	if(MiniPosSDKTestConnect() < 0)
	{
		gSessionPos = SESSION_POS_UNKNOWN;
		return -1;
	}

	for(replycnt = 0; replycnt < MAX_RETRY; replycnt++)
	{
		for(confirmcnt = 0; confirmcnt < MAX_RETRY; confirmcnt++)
		{
			//组装报文
			memcpy(gSDKBuf, "\x00\x04\x03\x35\x37", 5);
			len = 5;
			memset((char*)&gSDKBuf[len], 0x00, 8);
			strncpy((char*)&gSDKBuf[len], (char*)syscode, 8);
			len += 8;
			gSDKBuf[len] = 0x00;
			len++;
			if(paramname)
			{
				strncpy((char*)&gSDKBuf[len], (char*)paramname, 32);
				len += strlen((char*)&gSDKBuf[len]);
				gSDKBuf[len] = 0x00;
				len++;
			}/*
			if(paramvalue)
			{
				strncpy((char*)&gSDKBuf[len], (char*)paramvalue, 32);
				len += strlen((char*)&gSDKBuf[len]);
				gSDKBuf[len] = 0x00;
				len++;
			}*/
			gSDKBuf[0] = (len - 2) >> 8;
			gSDKBuf[1] = len - 2;

			if(SDKSendToPos(gSDKBuf, &len) < 0)
			{
				continue;
			}

			tm = gInterface->GetMsTime();
			while(gWaitConfirm)
			{
				if(tm + MAX_POS_TIMEOUT < gInterface->GetMsTime())
				{
					break;
				}
			}
			if(gWaitConfirm)
			{
				continue;
			}
			else
			{
				//指令应答成功
				break;
			}
		}
		if(confirmcnt >= MAX_RETRY)
		{
			//gSessionPos = SESSION_POS_UNKNOWN;
			continue;
		}
		tm = gInterface->GetMsTime();
		while(1)
		{
			if(gRecvLen > 3)
			{
				if(GET_PACKET_ATTRIBUTE(gRecvBuf) != 0x04)
				{
					//return GET_ERR_CODE(ERR_REPLAY_DATA);
					break;
				}

				strncpy((char*)paramvalue, (char*)GET_DATA_INDEX(gRecvBuf), GET_DATA_LEN(gRecvBuf));
				gSessionPos = SESSION_POS_UNKNOWN;
				return 0;
			}
			if(tm + MAX_POS_TIMEOUT < gInterface->GetMsTime())
			{
				break;
			}
		}
	}

	gSessionPos = SESSION_POS_UNKNOWN;

	if(replycnt >= MAX_RETRY)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

int DealLogIn()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x1D;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "51", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = len - 2;
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
}

int DealLogOut()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x1D;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "57", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = len - 2;
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
}



int DealSettleTrade()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x1D;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "52", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = len - 2;
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
}



int DealSaleTrade()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x3B;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "01", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        memset((unsigned char*)&gSDKBuf[len], 0x30, 12);
        if(strlen((char*)gInputParam) > 12)
        {
            //金额超过12字节就截掉大于12字节部分
            my_memcpy(gInputParam + (strlen((char*)gInputParam) - 12), gInputParam, 12, 1);
            gInputParam[12] = 0x00;
        }
        strcpy((char*)&gSDKBuf[len + 12 - strlen((char*)gInputParam)], (char*)gInputParam);
        //HexToStr(gInputParam, (unsigned char*)&gSDKBuf[len], 12);
        len += 12;
        gSDKBuf[len] = 0x1C;
        len++;
        /*
         strcpy((char*)&gBuf[len], (char*)"01");
         len += 2;
         len += 13;
         gBuf[len] = 0x1C;
         len++;
         gBuf[len] = 0x1C;
         len++;
         */
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = (len - 2);
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = 30000;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
}

int DealVoidSaleTrade()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x3B;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "02", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        memset((unsigned char*)&gSDKBuf[len], 0x30, 12);
        if(strlen((char*)gInputParam) > 12)
        {
            //金额超过12字节就截掉大于12字节部分
            my_memcpy(gInputParam + (strlen((char*)gInputParam) - 12), gInputParam, 12, 1);
            gInputParam[12] = 0x00;
        }
        strcpy((char*)&gSDKBuf[len + 12 - strlen((char*)gInputParam)], (char*)gInputParam);
        //HexToStr(gInputParam, (unsigned char*)&gSDKBuf[len], 12);
        len += 12;
        gSDKBuf[len] = 0x1C;
        len++;
        
        memcpy((unsigned char*)&gSDKBuf[len], (char*)&gInputParam[13], 6);
        len += 6;
        gSDKBuf[len] = 0x1C;
        len++;
        /*
         strcpy((char*)&gBuf[len], (char*)"01");
         len += 2;
         len += 13;
         gBuf[len] = 0x1C;
         len++;
         gBuf[len] = 0x1C;
         len++;
         */
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = (len - 2);
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = 30000;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
    
}

int DealQueryTrade()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02 && *GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x3B;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "04", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = (len - 2);
        
        gDealPackStep = PACK_STEP_SEND_SERVER;
        gTimeOut = 30000;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02 && *GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02 && *GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gDealPackStep = PACK_STEP_RETURN_REPLY;
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_REPLY)
    {
        if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02 && *GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02 && *GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        gSessionPos = SESSION_POS_UNKNOWN;
    }
    return 0;
}


void DealSendPack()
{
    int len;
    
    switch(gSessionPos)
    {
        case SESSION_POS_LOGIN:
            if(DealLogIn() >= 0)
            {
                return;
            }
            else
            {
                break;
            }
            
        case SESSION_POS_SALE_TRADE:
            DealSaleTrade();
            return;
            
        case SESSION_POS_VOIDSALE_TRADE:
            DealVoidSaleTrade();
            return;
            
        case SESSION_POS_QUERY:
            DealQueryTrade();
            return;
            
        case SESSION_POS_LOGOUT:
            DealLogOut();
            return;
            
        case SESSION_POS_SETTLE:
            DealSettleTrade();
            return;
            
        case SESSION_POS_GET_DEVICE_INFO:
            DealGetDeviceInfo();
            return;
            
        case SESSION_POS_DOWNLOAD_KEY:
            if(DealLoadKey() >= 0)
            {
                return;
            }
            else
            {
                break;
            }
            
        case SESSION_POS_DOWNLOAD_AID_PARAM:
            if(DealLoadAID() >= 0)
            {
                return;
            }
            else
            {
                break;
            }
            
        default:
            break;
    }
    
    if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x05)
    {
        gSessionPos = SESSION_POS_UNKNOWN;
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len + 2);
        /*gResponseFun(gUserData,
         gSessionPos,
         SESSION_ERROR_ACK,
         NULL,
         NULL);*/
    }
    else if(GET_PACKET_ATTRIBUTE(gRecvBuf) == 0x02)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
        }
    }
    
    gSessionPos = SESSION_POS_UNKNOWN;
}

void DealRecvPack(unsigned char *data)
{
	unsigned char buf[50];
	
	if(GET_PACKET_TYPE(data) == 0x00)
	{
		//传输包需要应答
		gSDKCnt = GET_PACKET_CNT(data);
		gRecvLen = GET_PACKET_LEN(data);
		memcpy((char*)buf, "\x04\x04\x04\x00\x03\x2C\x01\x00\x03\xF0\x99", 11);
		GET_PACKET_CNT(buf) = gSDKCnt;
		Crc16CCITT((unsigned char*)&buf[3], 1 + 5, 
			(unsigned char*)&buf[1 + 8]);
		gInterface->WritePosData((unsigned char*)buf, 1 + 10);
		if(PACK_STEP_SHAKE == gDealPackStep && memcmp(GET_DATA_INDEX(data), "\x06", 1) == 0)
		{
			gResponseFun(gUserData,
				gSessionPos,
				SESSION_ERROR_SHAKE_PACK,
				NULL,
				NULL);
			gDealPackStep = PACK_STEP_POS_STRUCT;
		}
		DealSendPack();
	}
	else if(gWaitConfirm)
	{
		if(GET_PACKET_CNT(data) == (unsigned char)(gSDKCnt - 1))
		{
			gWaitConfirm = 0;
		}
	}

	return;
}

int ReadServerData(unsigned char *data, int datalen)
{
	unsigned short re = 0;
	int len = 0;

	memcpy((char*)gSDKBuf, data, datalen);
	re = ((unsigned short)gSDKBuf[0] << 8) + gSDKBuf[1];
	re++;
	my_memcpy((unsigned char*)&gSDKBuf[0], (unsigned char*)&gSDKBuf[1], re + 2, 0);
	gSDKBuf[0] = re >> 8;
	gSDKBuf[1] = re;
	gSDKBuf[2] = 0x06;
	len = re + 2;
	gDealPackStep = PACK_STEP_RETURN_POS;
	SDKSendToPos(gSDKBuf, &len);

	return 0;
}

int ReadPosData(unsigned char *data, int datalen)
{
    
    NSString *str = @"";
    for (int t=1;t<=datalen;t++)
    {
        //                NSLog(@"%x",data[t-1]);
        str = [NSString stringWithFormat:@"%@,%.2x",str,data[t-1]];
    }
    
    NSLog(@"ReadPosData = %@  ----l = %d",str,datalen);
    
    //NSLog(@"ReadPosData--%@",data);
    
	static unsigned long timeout = 0;
	unsigned short re;

	if(gInterface->GetMsTime() > timeout + 800)
	{
		//接收超时
		AnasisPacket((unsigned char*)gRecvBuf, 0, 1);//复位
	}
	timeout = gInterface->GetMsTime();

	while(datalen > 0)
	{
		re = AnasisPacket((unsigned char*)gRecvBuf, *data, 0);
		if(re == GET_ERR_CODE(ERR_NO))
		{
			//收到一个完整的报文，解析并处理
			DealRecvPack((unsigned char*)gRecvBuf);
			//复位
			AnasisPacket((unsigned char*)gRecvBuf, 0, 1);
		}
		else if(re == GET_ERR_CODE(ERR_IN_PROGRESS))
		{
			//正在进行
		}
		else
		{
			//其他错误，复位
			AnasisPacket((unsigned char*)gRecvBuf, 0, 1);
		}

		data++;
		datalen--;
	}

	return 0;
}


int DealLoadKey()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x1D;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "53", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = len - 2;
        
        gDealPackStep = SESSION_POS_UNKNOWN;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    
    return -1;
}

int DealLoadAID()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_SEND_SERVER)
    {
        len = GET_DATA_LEN(gRecvBuf);
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2) = len >> 8;
        *(unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 1) = len;
        
        len += 2;
        if(gInterface->WriteServerData((unsigned char*)(GET_DATA_INDEX(gRecvBuf) - 2), len) < 0)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_SEND_8583_ERROR,
                         NULL,
                         NULL);
            gDealPackStep = PACK_STEP_RETURN_POS;
        }
        return 0;
    }
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        len = 0;
        gSDKBuf[len] = 0x00;
        len++;
        gSDKBuf[len] = 0x1D;
        len++;
        gSDKBuf[len] = 0x03;
        len += 1;
        memcpy((char*)&gSDKBuf[len], "54", 2);
        len += 2;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKMerchantCode, 15);
        len += 15;
        gSDKBuf[len] = 0x1C;
        len++;
        memcpy((char*)&gSDKBuf[len], gSDKTerminalCode, 8);
        len += 8;
        gSDKBuf[len] = 0x1C;
        len++;
        
        gSDKBuf[0] = (len - 2) >> 8;
        gSDKBuf[1] = len - 2;
        
        gDealPackStep = SESSION_POS_UNKNOWN;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    
    return -1;
}

int DealGetDeviceInfo()
{
    int len;
    
    if(gDealPackStep == PACK_STEP_POS_STRUCT)
    {
        memcpy(gSDKBuf, "\x00\x04\x03\x39\x38\x1C", 6);
        len = 6;
        
        gDealPackStep = PACK_STEP_RETURN_POS;
        gTimeOut = MAX_POS_TIMEOUT;
        SDKSendToPos(gSDKBuf, &len);
        return 0;
    }
    if(gDealPackStep == PACK_STEP_RETURN_POS)
    {
        if(*GET_DATA_INDEX(gRecvBuf) == 0x06)
        {
            len = GET_DATA_LEN(gRecvBuf);
            memset(gInputParam, 0x00, sizeof(gInputParam));
            memcpy(gInputParam, GET_DATA_INDEX(gRecvBuf) + 2, len -2);
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_ACK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        else if(*GET_DATA_INDEX(gRecvBuf) == 0x15)
        {
            gResponseFun(gUserData,
                         gSessionPos,
                         SESSION_ERROR_NAK,
                         NULL,
                         NULL);
            gSessionPos = SESSION_POS_UNKNOWN;
            return 0;
        }
        
        gSessionPos = SESSION_POS_UNKNOWN;
        return -1;
    }
    
    return 0;
}

char* MiniPosSDKGetDeviceID()
{
    int i;
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i] == 0x1C)
        {
            gInputParam[i] = 0x00;
        }
    }
    if(gInputParam[sizeof(gInputParam) - 1])
    {
        return "";
    }
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            return (char*)&gInputParam[i];
        }
    }
    
    return "";
}

int MiniPosSDKPosLogin()
{
	if(gSessionPos != SESSION_POS_UNKNOWN)
	{
		gResponseFun(gUserData,
			gSessionPos,
			SESSION_ERROR_DEVICE_BUSY,
			NULL,
			NULL);
		return -1;
	}
    NSLog(@"MiniPosSDKPosLogin---gSessionPos---%d",gSessionPos);
	gSessionPos = SESSION_POS_LOGIN;
	gTimeOut = MAX_POS_TIMEOUT;
	MiniPosSDKTestConnect();
	gDealPackStep = PACK_STEP_SHAKE;
	return 0;
}

unsigned short AnasisPacket(unsigned char*buf, unsigned char element, unsigned char isrestart)
{
	static unsigned char step = 0;
	static unsigned short tmpcnt = 0;
	static unsigned short packindex = 0;

	if(isrestart)
	{
		step = 0;
		tmpcnt = packindex;
		packindex = 0xFFFFFFFF;
		return tmpcnt;
	}

	if(packindex > MAX_PACKET_LEN + 8)
	{
		packindex = 0;
		tmpcnt = 0;
	}

	switch(step)
	{
	case 0:
		if(tmpcnt >= 3)
		{
			step = 0;
			tmpcnt = 0;
			packindex = 0;
			return GET_ERR_CODE(ERR_OTHER);
		}
		else if(*((unsigned char*)("\x04\x04\x04") + tmpcnt) != element)
		{
			step = 0;
			tmpcnt = 0;
			packindex = 0;
			return GET_ERR_CODE(ERR_PACKET_FORMAT);
		}
		else
		{
			buf[packindex] = element;
			packindex++;
			tmpcnt++;
		}

		if(tmpcnt >= 3)
		{
			step = 1;
		}
		break;

	case 1:
		buf[packindex] = element;
		packindex++;
		if(packindex >= 5)
		{
			if(((unsigned short)(buf[3]) << 8) + buf[4] > MAX_PACKET_LEN)
			{
				step = 0;
				tmpcnt = 0;
				packindex = 0;
				return GET_ERR_CODE(ERR_PACKET_LEN);
			}
			step = 2;
			break;
		}
		break;

	case 2:
		buf[packindex] = element;
		packindex++;
		if(packindex >= 5 && ((unsigned short)(buf[3]) << 8) + buf[4] <= packindex - 5)
		{
			step = 3;
		}
		break;

	case 3:
		if(element != 0x03)
		{
			step = 0;
			tmpcnt = 0;
			packindex = 0;
			return GET_ERR_CODE(ERR_PACKET_FORMAT);
		}
		buf[packindex] = element;
		packindex++;
		tmpcnt = 0;
		step = 4;
		break;

	case 4:
		buf[packindex] = element;
		tmpcnt++;
		packindex++;
		if(tmpcnt >= 2)
		{
			//计算校验
			Crc16CCITT((unsigned char*)&buf[3], packindex - 3 - 2, (unsigned char*)&tmpcnt);
			if(tmpcnt != *(unsigned short*)&buf[packindex - 2])
			{
				return GET_ERR_CODE(ERR_VERIFY_PACK);
			}
			else
			{
				return GET_ERR_CODE(ERR_NO);
			}
			step = 0;
			tmpcnt = 0;
			packindex = 0;
		}
		break;

	default:
		step = 0;
		tmpcnt = 0;
		packindex = 0;
		break;
	}

	return GET_ERR_CODE(ERR_IN_PROGRESS);
}

void my_memcpy(unsigned char* src, unsigned char* dest, int len, unsigned char direction)
{
	int i;

	if(direction)
	{
		//正向
		for(i = 0; i < len; i++)
		{
			dest[i] = src[i];
		}
	}
	else
	{
		//反向
		for(i = len - 1; i >= 0; i--)
		{
			dest[i] = src[i];
		}
	}
}

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



/*******************************************************************
 函数名称: void BcdToAsc(u8 *Dest,u8 *Src,u32 Len)
 函数功能: 将压缩BCD码转换为ascii码
 入口参数: 1.ascii码地址; 2.压缩BCD数组地址; 3.Bcd码字节个数
 返 回 值: 无
 相关调用:
 备    注: Dest地址为Len的两倍
 修改信息:
 ********************************************************************/
void BcdToAsc(char *Dest,char *Src,int Len){
    
}

/*******************************************************************
 函数名称: void AscToBcd(u8 *Dest,u8 *Src,u32 Len)
 函数功能: 将ascii码转换为压缩BCD码
 入口参数: 1.压缩bcd数组地址; 2.ascii码地址; 3.ascii字节个数
 返 回 值: 无
 相关调用:
 备    注: 末尾不够补0x00,非ascii码填0x00
 修改信息:
 ********************************************************************/
void AscToBcd(char *Dest,const char *Src,int Len);


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
int MiniPosSDKRemoveDelegate(void *userData){
    return 0;
}


/************************************************************
 设置POS中心IP地址或域名、端口号、网络连接是否使用SSL
 参数1（POS中心IP地址或域名）	AN
 参数2（端口号）            int
 参数3（是否使用SSL）       int  0：不使用 1：使用
 *************************************************************/
int MiniPosSDKSetPostCenterParam(const char *host, int port, int isUseSSL){
    return 0;
}

/************************************************************
 设置与POS中心之间的数据收发处理函数
 参数1 处理要发送数据的函数，该函数用于改变发往POS中心的数据格式，如将8583包Base64编码后嵌入到xml中
 参数2 处理接收到数据的函数，该函数用于将POS中心返回的数据转换为8583包的格式，如从xml中取出8583包数据
 参数3 解析数据包的长度和真实数据的起始位置函数，该函数用于将HTTP等头中取出真实数据的长度和真实数据的起始位置
 
 默认发往POS中心的报文格式为“两字节的数据长度”+“8583报文”，POS中心返回的数据格式也为同样格式
 
 *************************************************************/
int MiniPosSDKSetNetworkDataProcessFunction(NetworkProcessSendDataFunc processSendData,
                                            NetworkProcessReciveDataFunc processReciveData,
                                            NetworkProcessHeadDataFunc processHeadData);

/************************************************************
 获取设备状态
 返回值： -1表示设备未连接，0表示设备已连接
 *************************************************************/
int MiniPosSDKDeviceState(){
    return gInterface->DeviceState();
}

/************************************************************
 签到指令
 *************************************************************/
int MiniPosSDKPosLogin();

/************************************************************
 签退指令
 *************************************************************/
int MiniPosSDKPosLogout()
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_LOGOUT;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    return 0;
}

/************************************************************
 获取设备信息指令
 *************************************************************/
int MiniPosSDKGetDeviceInfoCMD()
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_GET_DEVICE_INFO;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    
    return 0;
}

/************************************************************
 消费
 参数1（金额参数）	N12 	以分为单位，前补’0’
 参数2（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSaleTradeCMD(const char *amount, const char *cashierSerialCode)
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    memset(gInputParam, 0x00, sizeof(gInputParam));
    strncpy((char*)gInputParam, amount, 12);
    gSessionPos = SESSION_POS_SALE_TRADE;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    return 0;
}

/************************************************************
 消费撤销
 参数1（原交易金额）	N12 	以分为单位，前补’0’， 当不为全’0’时，POS 与原交易金额比对，否则忽略此参数
 参数2 (原交易凭证号)	N6	若为“空”，则POS 提示操作员输入
 参数3（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKVoidSaleTradeCMD(const char *amount, const char *serialCode, const char *cashierSerialCode)
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    memset((char*)gInputParam, 0x00, sizeof(gInputParam));
    strncpy((char*)gInputParam, amount, 12);
    strncpy((char*)&gInputParam[13], serialCode, 6);
    gSessionPos = SESSION_POS_VOIDSALE_TRADE;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    
    return 0;
}

/************************************************************
 查询余额
 *************************************************************/
int MiniPosSDKQuery()
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_QUERY;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    return 0;
}

/************************************************************
 结算
 参数1（收银流水号）	AN20	（可选，如有，记入交易流水文件对应信息）
 *************************************************************/
int MiniPosSDKSettleTradeCMD(const char *cashierSerialCode)
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_SETTLE;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    
    return 0;
}

/************************************************************
 公钥下载
 *************************************************************/
int MiniPosSDKDownloadKeyCMD()
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_DOWNLOAD_KEY;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    
    return 0;
}

/************************************************************
 AID参数下载指令
 *************************************************************/
int MiniPosSDKDownloadAIDParamCMD()
{
    if(gSessionPos != SESSION_POS_UNKNOWN)
    {
        gResponseFun(gUserData,
                     gSessionPos,
                     SESSION_ERROR_DEVICE_BUSY,
                     NULL,
                     NULL);
        return -1;
    }
    gSessionPos = SESSION_POS_DOWNLOAD_AID_PARAM;
    gTimeOut = MAX_POS_TIMEOUT;
    MiniPosSDKTestConnect();
    gDealPackStep = PACK_STEP_SHAKE;
    
    return 0;
}

/************************************************************
 参数下载
 *************************************************************/
int MiniPosSDKDownloadParamCMD(){
    return 0;
}



/************************************************************
 获取加密后卡密
 *************************************************************/
char * MiniPosSDKGetEncryptPin(){
    return NULL;
}

/************************************************************
 获取磁道2数据
 需要先调用读取磁道信息指令MiniPosSDKReadCardCMD成功后，才会返回磁道信息
 *************************************************************/
char * MiniPosSDKGetTrack2(){
    return NULL;
}

/************************************************************
 获取磁道3数据
 需要先调用读取磁道信息指令MiniPosSDKReadCardCMD成功后，才会返回磁道信息
 *************************************************************/
char * MiniPosSDKGetTrack3(){
    return NULL;
}

/************************************************************
 获取磁道1数据
 需要先调用读取磁道信息指令MiniPosSDKReadCardCMD成功后，才会返回磁道信息
 *************************************************************/
char * MiniPosSDKGetTrack1(){
    return NULL;
}

/************************************************************
 获取设备Core版本号
 需要先调用获取设备信息指令MiniPosSDKGetDeviceInfoCMD成功后，才会返回设备Core版本号
 *************************************************************/
char * MiniPosSDKGetCoreVersion()
{
    int i;
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i] == 0x1C)
        {
            gInputParam[i] = 0x00;
        }
    }
    if(gInputParam[sizeof(gInputParam) - 1])
    {
        return "";
    }
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            i += strlen((char*)&gInputParam[i]);
            break;
        }
    }
    
    for(; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            return (char*)&gInputParam[i];
        }
    }
    
    return "";
}

/************************************************************
 获取设备应用版本号
 需要先调用获取设备信息指令MiniPosSDKGetDeviceInfoCMD成功后，才会返回设备应用版本号
 *************************************************************/
char * MiniPosSDKGetAppVersion()
{
    int i;
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i] == 0x1C)
        {
            gInputParam[i] = 0x00;
        }
    }
    
    if(gInputParam[sizeof(gInputParam) - 1])
    {
        return "";
    }
    
    for(i = 0; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            i += strlen((char*)&gInputParam[i]);
            break;
        }
    }
    
    for(; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            i += strlen((char*)&gInputParam[i]);
            break;
        }
    }
    
    for(; i < sizeof(gInputParam); i++)
    {
        if(gInputParam[i])
        {
            return (char*)&gInputParam[i];
        }
    }
    
    return "";
}

/************************************************************
 获取当前正在进行的会话类型
 *************************************************************/
MiniPosSDKSessionType MiniPosSDKGetCurrentSessionType(){
    NSLog(@"gSessionPos:%d",gSessionPos);
    return gSessionPos;
}

/************************************************************
 通过流水号打印
 需要先输入流水号，若不输入则流水号为0，打印指定的流水号交易，流水号为0时打印上一笔或最后一笔交易
 lianghuiyuan
 *************************************************************/
int MiniPosSDKPosPrint(const char *SerialCode);

/************************************************************
 获取设备序列号指令
 lianghuiyuan
 *************************************************************/
int MiniPosSDKGetDeviceIDCMD();


/************************************************************
 读磁道信息
 参数1（金额参数）	N12 	以分为单位，前补’0’
 *************************************************************/
int MiniPosSDKReadCardCMD(const char *amount);

/************************************************************
 输密并且读磁道信息
 参数1（金额参数）	N12 	以分为单位，前补’0’
 参数2（密码长度参数）	N1 	需要输入密码的位数， 值为0,4-6
 *************************************************************/
int MiniPosSDKReadPinCardCMD(const char *amount, int pinlenth);

/************************************************************
 读IC卡信息
 参数1（发送给IC卡的数据信息）	LLLVAR512 	要发给ic卡的数据信息
 *************************************************************/
int MiniPosSDKReadICInfoCMD(const char *icInfo, int icInfolen);

/************************************************************
 更新工作密钥
 参数1（TPK密文长度）	AN2 	    TPK密文长度为8或16
 参数2（TPK密文）	    LLVAR16 	TPK密文为8字节或16字节
 参数1(暂无)（TAK密文长度）	AN2 	    TPK密文长度为8或16
 参数2(暂无)（TAK密文）	    LLVAR16 	TPK密文为8字节或16字节
 *************************************************************/
int MiniPosSDKUpdateKeyCMD(const char *tpk, int tpklen, const char *tak, int taklen);