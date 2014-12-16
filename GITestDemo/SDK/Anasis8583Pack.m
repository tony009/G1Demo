//#include "stdafx.h"
#include "Anasis8583Pack.h"

//char gSaveBuf[1000];
//FILE *gFile = NULL;

u8 gRecvBuf[500];
u8 gRecvStep = 0;
u8 gTPDU[5];
u8 gAppType[1];
u8 gTerminalStatusReq[1];
u8 gBmp[8];
u8 gMsgType[2];
u8 gPriAccount[20]; //卡号
u16 gPriAccountLen;
u8 gTransacCode[3];
u8 gTransacAmount[6];   //交易金额
u8 gSysTraceAudit[3];      //凭证号
u8 gLocalTime[3];  //时间
u8 gLocalDate[2]; //日期
u8 gValidity[2];
u8 gSettleDate[2];
u8 gSerEntryMode[2];
u8 gCardSequence[2];
u8 gSerCondition[1];
u8 gPinCapMode[1];
u8 *gAcqIdenCode = gRecvBuf;
u16 gAcqIdenCodeLen;
u8 *gTrack2 = gRecvBuf;
u16 gTrack2Len;
u8 *gTrack3 = gRecvBuf;
u16 gTrack3Len;
u8 gRetrieval[12];   //参考号
u8 gAuthIdentiRespon[6];
u8 gResponCode[2];
u8 gTerminalCode[8]; //终端号
u8 gMerchantCode[15]; //商户号
u8 *gAdditionRespon = gRecvBuf;
u16 gAdditionResponLen;
u8 *gAdditionPrivate = gRecvBuf;
u16 gAdditionPrivateLen;
u8 gCurrencyCode[3];
u8 gPinData[8];
u8 gSecurityInfo[8];
u8 *gBalanceAmount = gRecvBuf;
u16 gBalanceAmountLen;
u8 *gICData = gRecvBuf;
u16 gICDataLen;
u8 *gPBOCData = gRecvBuf;
u16 gPBOCDataLen;
u8 *gOtherTermParam = gRecvBuf;
u16 gOtherTermParamLen;
u8 *gUserArea59 = gRecvBuf;
u16 gUserArea59Len;
u8 gUserArea60[20];  //批次号
u16 gUserArea60Len;
u8 *gOrgMsg = gRecvBuf;
u16 gOrgMsgLen;
u8 *gUserArea62 = gRecvBuf;
u16 gUserArea62Len;
u8 *gUserArea63 = gRecvBuf;
u16 gUserArea63Len;
u8 gMac[8];

//CString gShowEdit;

void my_printf(char *fmt,...)
{
	//printf(fmt);

	int length = 0;
	va_list ap;
	char string[1024];
	char *pt;
	va_start(ap,fmt);
	vsprintf((char *)string,(const char *)fmt,ap);
	pt = &string[0];
	while(*pt!='\0') 
	{
		length++;
		pt++;
	}
	//printf((char*)string);
	//fwrite(string, 1, length, gFile);
	va_end(ap);
	//gShowEdit += CString(string);
}


void PrintFormat(char*buf, int len)
{
	int i = 0;

	for(i = 0; i < len; i++)
	{
		my_printf("%.2X ", (unsigned char)buf[i]);
	}
	my_printf("\r\n");
}

void ClearBitmap(void)
{
	memset(gBmp, 0x00, sizeof(gBmp));
}

void SetBitmap(u8 area)
{
	if(area < 1 || area > 64)
	{
		return;
	}

	area--;
	gBmp[area / 8] |=  (0x80 >> ( area % 8));
}

void ResetBitmap(u8 area)
{
	if(area < 1 || area > 64)
	{
		return;
	}

	area--;
	gBmp[area / 8] &=  (~(0x80 >> ( area % 8)));
}

void IntToBCD(int dataIn, u8 *dataOut, u8 outDataLen)
{
	s8 Len = (s8)outDataLen;

	memset(dataOut, 0x00, outDataLen);

	Len--;
	for(; Len >= 0 && dataIn; Len--)
	{
		dataOut[Len] = (u8)(dataIn % 10);
		dataIn = dataIn / 10;
		dataOut[Len] &= 0x0F;
		dataOut[Len] |= ((u8)(dataIn % 10) << 4);
		dataIn = dataIn / 10;
	}
}

u8 GetNextBmpArea(u8 index)
{
	while(index < 64)
	{
		if((gBmp[index / 8] << ( index % 8)) & 0x80)
		{
			return index + 1;
		}
		index++;
	}

	return 0;
}

void ClearRecvFlag(void)
{
	gRecvStep = 0xFF;
	//gShowEdit = "";
}

int BCDToInt(u8 *dataIn, u8 InDataLen)
{
	int outlen;
	u8 i;

	outlen = 0;
	for(i = 0; i < InDataLen; i++)
	{
		outlen = outlen * 10 + ((dataIn[i] >> 4) & 0x0F);
		outlen = outlen * 10 + (dataIn[i] & 0x0F);
	}

	return outlen;
}

int HexToStr(unsigned char*hex, unsigned char*str, int hexlen)
{
    int i;
    unsigned char tmp;
    
    for(i = 0; i < hexlen; i++)
    {
        tmp = (i % 2 == 0)? (hex[i / 2] >> 4) : hex[i / 2];
        tmp = tmp & 0x0F;
        str[i] = tmp > 0x09 ? (tmp - 0x0A + 'A') : (tmp + '0');
    }
    str[i] = 0x00;
    
    return hexlen;
}

int BreakupRecvPack(u8 recvchar)
{
	static int recvindex = 0;
	static s8 recvlenmark = 0;
	static char lenbuf[10];//≥§∂»ª∫¥Ê

	if(gRecvStep == 0xFF)
	{
		recvindex = 0;
		recvlenmark = 0;
		gRecvStep = 0;
	}
	switch(gRecvStep)
	{
	case 0:
		if(recvindex == 0 && recvchar != 0x60)
		{
			recvindex = 0;
			gRecvStep = 0;
			return -1;
		}
		gTPDU[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gTPDU))
		{
			recvindex = 0;
			gRecvStep++;
			my_printf("TPDU:");
			PrintFormat((char*)gTPDU, sizeof(gTPDU));
		}
		break;
	case 1:
		gAppType[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gAppType))
		{
			recvindex = 0;
			my_printf("±®ŒƒÕ∑:");
			my_printf("%.2X ", gAppType[0]);
			gRecvStep++;
		}
		break;
	case 2:
		if(recvchar != 0x22)
		{
			//
		}
		recvindex = 0;
		gRecvStep++;
		my_printf("%.2X ", recvchar);
		break;
	case 3:
		gTerminalStatusReq[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gTerminalStatusReq))
		{
			recvindex = 0;
			my_printf("%.2X ", gTerminalStatusReq[0]);
			gRecvStep++;
		}
		break;
	case 4:
		recvindex++;
		my_printf("%.2X ", recvchar);
		if(recvindex >= 3)
		{
			recvindex = 0;
			gRecvStep++;
			my_printf("\r\n");
		}
		break;
	case 5:
		gMsgType[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gMsgType))
		{
			my_printf("œ˚œ¢¿‡–Õ:");
			PrintFormat((char*)gMsgType, recvindex);
			recvindex = 0;
			gRecvStep++;
		}
		break;
	case 6:
		gBmp[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gBmp))
		{
			recvindex = 0;
			gRecvStep++;
			gRecvStep = GetNextBmpArea(0) + 7;
			recvlenmark = 0;
			my_printf("ŒªÕº:");
			PrintFormat((char*)gBmp, sizeof(gBmp));
			return 1;
		}
		break;
	default:
		break;
	}

	if(gRecvStep <= 6)
	{
		return 1;
	}

	switch(gRecvStep - 7)
	{
	case 1:
		// ¿©’π”Ú£¨128∏ˆ”Ú£¨≤ª÷ß≥÷
		recvindex = 0;
		gRecvStep = 0;
		return -1;
		break;
	case 2:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 1)
			{
				recvindex = 0;
				recvlenmark = 1;
				gPriAccountLen = BCDToInt((u8*)lenbuf, 1);
			}
			break;
		}
		gPriAccount[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gPriAccountLen + 1) / 2)
		{
			my_printf("2”Ú\n÷˜’À∫≈:");
			PrintFormat((char*)gPriAccount, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 3:
		gTransacCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gTransacCode))
		{
			my_printf("3”Ú\nΩª“◊¥¶¿Ì¬Î:");
			PrintFormat((char*)gTransacCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 4:
		gTransacAmount[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gTransacAmount))
		{
			my_printf("4”Ú\nΩª“◊Ω∂Ó:");
			PrintFormat((char*)gTransacAmount, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 11:
		gSysTraceAudit[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gSysTraceAudit))
		{
			my_printf("11”Ú\n÷’∂À¡˜ÀÆ∫≈:");
			PrintFormat((char*)gSysTraceAudit, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 12:
		gLocalTime[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gLocalTime))
		{
			my_printf("12”Ú\n±æµÿ ±º‰:");
			PrintFormat((char*)gLocalTime, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 13:
		gLocalDate[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gLocalDate))
		{
			my_printf("13”Ú\n±æµÿ»’∆⁄:");
			PrintFormat((char*)gLocalDate, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 14:
		gValidity[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gValidity))
		{
			my_printf("14”Ú\nø®”––ß∆⁄:");
			PrintFormat((char*)gValidity, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 15:
		gSettleDate[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gSettleDate))
		{
			my_printf("15”Ú\n«ÂÀ„»’∆⁄:");
			PrintFormat((char*)gSettleDate, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 22:
		gSerEntryMode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gSerEntryMode))
		{
			my_printf("22”Ú\n∑˛ŒÒµ„ ‰»Î∑Ω Ω¬Î:");
			PrintFormat((char*)gSerEntryMode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 23:
		gCardSequence[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gCardSequence))
		{
			my_printf("23”Ú\nø®–Ú¡–∫≈:");
			PrintFormat((char*)gCardSequence, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 25:
		gSerCondition[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gSerCondition))
		{
			my_printf("25”Ú\n∑˛ŒÒµ„Ãıº˛¬Î:");
			PrintFormat((char*)gSerCondition, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 26:
		gPinCapMode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gPinCapMode))
		{
			my_printf("26”Ú\n∑˛ŒÒµ„PINªÒ»°¬Î:");
			PrintFormat((char*)gPinCapMode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 32:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 1)
			{
				recvindex = 0;
				recvlenmark = 1;
				gAcqIdenCodeLen = BCDToInt((u8*)lenbuf, 1);
			}
			break;
		}
		gAcqIdenCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gAcqIdenCodeLen + 1) / 2)
		{
			my_printf("32”Ú\n ‹¿Ì∑Ω ∂¬Î:");
			PrintFormat((char*)gAcqIdenCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 35:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 1)
			{
				recvindex = 0;
				recvlenmark = 1;
				gTrack2Len = BCDToInt((u8*)lenbuf, 1);
			}
			break;
		}
		gTrack2[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gTrack2Len + 1) / 2)
		{
			my_printf("35”Ú\n∂˛¥≈µ¿ ˝æ›:");
			PrintFormat((char*)gTrack2, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 36:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gTrack3Len = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gTrack3[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gTrack3Len + 1) / 2)
		{
			my_printf("36”Ú\n»˝¥≈µ¿ ˝æ›:");
			PrintFormat((char*)gTrack3, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 37:
		gRetrieval[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gRetrieval))
		{
			my_printf("37”Ú\nPOS÷––ƒ¡˜ÀÆ∫≈:");
			PrintFormat((char*)gRetrieval, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 38:
		gAuthIdentiRespon[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gAuthIdentiRespon))
		{
			my_printf("38”Ú\n ⁄»®±Í ∂”¶¥¬Î:");
			PrintFormat((char*)gAuthIdentiRespon, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 39:
		gResponCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gResponCode))
		{
			my_printf("39”Ú\nœÏ”¶¬Î:");
			PrintFormat((char*)gResponCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 41:
		gTerminalCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gTerminalCode))
		{
			my_printf("41”Ú\n÷’∂À∫≈:");
			PrintFormat((char*)gTerminalCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 42:
		gMerchantCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gMerchantCode))
		{
			my_printf("42”Ú\n…Ãªß∫≈:");
			PrintFormat((char*)gMerchantCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 44:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 1)
			{
				recvindex = 0;
				recvlenmark = 1;
				gAdditionResponLen = BCDToInt((u8*)lenbuf, 1);
			}
			break;
		}
		gAdditionRespon[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gAdditionResponLen)
		{
			my_printf("44”Ú\n∑¢ø®–– ’µ•––±Í ∂¬Î:");
			PrintFormat((char*)gAdditionRespon, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 48:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gAdditionPrivateLen = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gAdditionPrivate[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gAdditionPrivateLen + 1) / 2)
		{
			my_printf("48”Ú:\nÀΩ”–”Ú");
			PrintFormat((char*)gAdditionPrivate, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 49:
		gCurrencyCode[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gCurrencyCode))
		{
			my_printf("49”Ú\nΩª“◊ªı±“¥˙¬Î:");
			PrintFormat((char*)gCurrencyCode, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 52:
		gPinData[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gPinData))
		{
			my_printf("52”Ú\nPIN¬Î:");
			PrintFormat((char*)gPinData, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 53:
		gSecurityInfo[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gSecurityInfo))
		{
			my_printf("53”Ú\n∞≤»´œ‡πÿøÿ÷∆–≈œ¢:");
			PrintFormat((char*)gSecurityInfo, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 54:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gBalanceAmountLen = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gBalanceAmount[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gBalanceAmountLen)
		{
			my_printf("54”Ú\n”‡∂Ó:");
			PrintFormat((char*)gBalanceAmount, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 55:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gICDataLen = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gICData[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gICDataLen)
		{
			my_printf("55”Ú\nICø® ˝æ›:");
			PrintFormat((char*)gICData, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 57:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gOtherTermParamLen = BCDToInt((u8*)lenbuf, 2);
			}
			else
			{
				break;
			}
			if(gOtherTermParamLen)break;
		}
		gOtherTermParam[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gOtherTermParamLen)
		{
			my_printf("57”Ú\n∆‰À˚÷’∂À≤Œ ˝:");
			PrintFormat((char*)gOtherTermParam, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 58:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gPBOCDataLen = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gPBOCData[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gPBOCDataLen)
		{
			my_printf("58”Ú\nµÁ◊”«Æ∞¸Ωª“◊–≈œ¢:");
			PrintFormat((char*)gPBOCData, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 59:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gUserArea59Len = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gUserArea59[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gUserArea59Len)
		{
			my_printf("59”Ú\n◊‘∂®“Â:");
			PrintFormat((char*)gUserArea59, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 60:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gUserArea60Len = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gUserArea60[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gUserArea60Len + 1) / 2)
		{
			my_printf("60”Ú\n◊‘∂®“Â:");
			PrintFormat((char*)gUserArea60, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 61:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gOrgMsgLen = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gOrgMsg[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= (gOrgMsgLen + 1) / 2)
		{
			my_printf("61”Ú\n◊‘∂®“Â:");
			PrintFormat((char*)gOrgMsg, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 62:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gUserArea62Len = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gUserArea62[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gUserArea62Len)
		{
			my_printf("62”Ú\n◊‘∂®“Â:");
			PrintFormat((char*)gUserArea62, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 63:
		if(recvlenmark == 0)
		{
			lenbuf[recvindex] = recvchar;
			recvindex++;
			if(recvindex >= 2)
			{
				recvindex = 0;
				recvlenmark = 1;
				gUserArea63Len = BCDToInt((u8*)lenbuf, 2);
			}
			break;
		}
		gUserArea63[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= gUserArea63Len)
		{
			my_printf("63”Ú\n◊‘∂®“Â:");
			PrintFormat((char*)gUserArea63, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	case 64:
		gMac[recvindex] = recvchar;
		recvindex++;
		if(recvindex >= sizeof(gMac))
		{
			my_printf("64”Ú\n–£—È∫Õ:");
			PrintFormat((char*)gMac, recvindex);
			recvindex = 0;
			gRecvStep = GetNextBmpArea(gRecvStep - 7) + 7;
			recvlenmark = 0;
		}
		break;
	default:
		break;
	}

	if(gRecvStep == 7)
	{
		/*data recv complete*/
		gRecvStep = 0;
		return 0;
	}

	return 1;
}