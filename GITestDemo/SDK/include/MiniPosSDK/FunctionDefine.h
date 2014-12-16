//
//  Header.h
//  MiniPosSDK
//
//  Created by Tara. on 14-8-13.
//  Copyright (c) 2014年 yogia. All rights reserved.
//

#ifndef MiniPosSDK_Header_h
#define MiniPosSDK_Header_h

/************************************************************
 处理设备要发往POS中心的数据，该函数用于改变发往POS中心的数据格式，如将8583包Base64编码后嵌入到xml中
 参数1 设备要发往POS中心的8583包数据
 参数2 设备要发往POS中心的8583包数据长度
 参数3 处理后将发往POS中心的数据，请使用malloc申请内存
 参数4 处理后将发往POS中心的数据长度
 *************************************************************/
typedef void (*NetworkProcessSendDataFunc)(char *inData, int inDataLen, char **outData, int *outDataLen);

/************************************************************
 处理从POS中心接收到数据，该函数用于将POS中心返回的数据转换为8583包的格式，如从xml中取出8583包数据
 参数1 从POS中心收到的数据
 参数2 从POS中心收到的数据长度
 参数3 处理后将返回给设备的8583包数据，请使用malloc申请内存
 参数4 处理后将返回给设备的8583包数据长度
 *************************************************************/
typedef void (*NetworkProcessReciveDataFunc)(char *inData, int inDataLen, char **outData, int *outDataLen);

/************************************************************
 从POS中心收到的数据头部，解析数据包的长度和真实数据的起始位置函数，该函数用于将HTTP等头中取出真实数据的长度和真实数据的起始位置
 参数1 从POS中心收到的头部数据
 参数2 从POS中心收到的头部数据长度
 参数3 解析出的真实有效数据的长度
 参数4 真实有效数据相对于头部的起始位置
 *************************************************************/
typedef void (*NetworkProcessHeadDataFunc)(char *headData, int headDataLen, int *responceDataLen, int *responceDataStartPos);

#endif
