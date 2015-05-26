//
//  des.c
//  GITestDemo
//
//  Created by 吴狄 on 15/5/21.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#include "des.h"


const char PC_1[] = {					//PC_1置换
    57, 49, 41, 33, 25, 17, 9,
    1, 58, 50, 42, 34, 26, 18,
    10, 2, 59, 51, 43, 35, 27,
    19, 11, 3, 60, 52, 44, 36,
    63, 55, 47, 39, 31, 23, 15,
    7, 62, 54, 46, 38, 30, 22,
    14, 6, 61, 53, 45, 37, 29,
    21, 13, 5, 28, 20, 12, 4
};
const char Left_Move[] =
{
    1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1
};

const char PC_2[] =
{
    14, 17, 11, 24, 1, 5,
    3, 28, 15, 6, 21, 10,
    23, 19, 12, 4, 26, 8,
    16, 7, 27, 20, 13, 2,
    41, 52, 31, 37, 47, 55,
    30, 40, 51, 45, 33, 48,
    44, 49, 39, 56, 34, 53,
    46, 42, 50, 36, 29, 32
};

const char IP[] = {                   //IP置换
    58, 50, 42, 34, 26, 18, 10,  2,
    60, 52, 44, 36, 28, 20, 12,  4,
    62, 54, 46, 38, 30, 22, 14,  6,
    64, 56, 48, 40, 32, 24, 16,  8,
    57, 49, 41, 33, 25, 17,  9,  1,
    59, 51, 43, 35, 27, 19, 11,  3,
    61, 53, 45, 37, 29, 21, 13,  5,
    63, 55, 47, 39, 31, 23, 15,  7
};

const char Extern[] = {				//扩展置换
    32,  1,  2,  3,  4,  5,
    4,  5,  6,  7,  8,  9,
    8,  9, 10, 11, 12, 13,
    12, 13, 14, 15, 16, 17,
    16, 17, 18, 19, 20, 21,
    20, 21, 22, 23, 24, 25,
    24, 25, 26, 27, 28, 29,
    28, 29, 30, 31, 32,  1
};

const char IP_1[] = {					//IP逆置换
    40,  8, 48, 16, 56, 24, 64, 32,
    39,  7, 47, 15, 55, 23, 63, 31,
    38,  6, 46, 14, 54, 22, 62, 30,
    37,  5, 45, 13, 53, 21, 61, 29,
    36,  4, 44, 12, 52, 20, 60, 28,
    35,  3, 43, 11, 51, 19, 59, 27,
    34,  2, 42, 10, 50, 18, 58, 26,
    33,  1, 41,  9, 49, 17, 57, 25
};
const char S_BOX[8][64] = {				//S盒子
    /* S1 */
    14,  4, 13,  1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7,
    0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8,
    4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0,
    15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13,
    
    /* S2 */
    15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10,
    3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5,
    0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15,
    13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9,
    
    /* S3 */
    10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8,
    13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1,
    13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7,
    1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12,
    
    /* S4 */
    7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15,
    13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9,
    10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4,
    3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14,
    
    /* S5 */
    2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9,
    14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6,
    4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14,
    11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3,
    
    /* S6 */
    12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11,
    10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8,
    9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6,
    4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13,
    
    /* S7 */
    4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1,
    13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6,
    1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2,
    6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12,
    
    /* S8 */
    13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7,
    1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2,
    7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8,
    2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11
};

const char P[]={					//P置换
    16,  7, 20, 21,
    29, 12, 28, 17,
    1, 15, 23, 26,
    5, 18, 31, 10,
    2,  8, 24, 14,
    32, 27,  3,  9,
    19, 13, 30,  6,
    22, 11,  4, 25
};

static void InputKey(unsigned char* Key);
static void DesCode(unsigned char*lpIn, unsigned char*lpOut, char isEncrypt/*1:加密；0：解密*/);

/****************************************************************************
 **函数名:	void des_encrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
 **描述:     单des加密运算
 **输入参数: lpIn:输入的待加密数据;  key:密钥。
 **输出参数:lpOut:加密出来的密文;
 **返回值:
 **备注:
 **
 **
 **版权:郑州友池电子技术有限公司深圳分公司
 **
 **作者 & 日期:            申伟宏(2015-03-06)
 **---------------------------------------------------------------------------
 **修改记录:
 ****************************************************************************/
void des_encrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
{
    InputKey(key);
    DesCode((unsigned char*)lpIn, (unsigned char*)lpOut, 1);
}

/****************************************************************************
 **函数名:	void des_decrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
 **描述:     单des解密运算
 **输入参数: lpIn:输入的待解密数据;  key:密钥。
 **输出参数:lpOut:解密出来的明文;
 **返回值:
 **备注:
 **
 **
 **版权:郑州友池电子技术有限公司深圳分公司
 **
 **作者 & 日期:            申伟宏(2015-03-06)
 **---------------------------------------------------------------------------
 **修改记录:
 ****************************************************************************/
void des_decrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
{
    InputKey(key);
    DesCode((unsigned char*)lpIn, (unsigned char*)lpOut, 0);
}

/****************************************************************************
 **函数名:	void des3_encrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
 **描述:     3des加密运算
 **输入参数: lpIn:输入的待加密数据;  key:密钥。?
 **输出参数:lpOut:加密出来的密文;
 **返回值:
 **备注:
 **
 **
 **版权:郑州友池电子技术有限公司深圳分公司
 **
 **作者 & 日期:            申伟宏(2015-03-06)
 **---------------------------------------------------------------------------
 **修改记录:
 ****************************************************************************/
void des3_encrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
{
    unsigned char in[8];
    
    memcpy(in, lpIn, sizeof(in));
    
    InputKey(key);
    DesCode(in, lpOut, 1);
    
    InputKey(key + 8);
    DesCode(lpOut, in, 0);
    
    InputKey(key);
    DesCode(in, lpOut, 1);
}

/****************************************************************************
 **函数名:	void des3_decrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
 **描述:     3des解密运算
 **输入参数: lpIn:输入的待解密数据;  key:密钥。
 **输出参数:lpOut:解密出来的明文;
 **返回值:
 **备注:
 **
 **
 **版权:郑州友池电子技术有限公司深圳分公司
 **
 **作者 & 日期:            申伟宏(2015-03-06)
 **---------------------------------------------------------------------------
 **修改记录:
 ****************************************************************************/
void des3_decrypt(unsigned char*lpIn, unsigned char*lpOut, unsigned char* key)
{
    unsigned char in[8];
    
    memcpy(in, lpIn, sizeof(in));
    
    InputKey(key);
    DesCode(in, lpOut, 0);
    
    InputKey(key + 8);
    DesCode(lpOut, in, 1);
    
    InputKey(key);
    DesCode(in, lpOut, 0);
}


char gTmpKey[16][6];


static void Substitution(unsigned char*subIn, unsigned char subLen, unsigned char *lpIn, unsigned char *lpOut)
{
    //置换
    unsigned char i = 0;
    
    for(i = 0; i < subLen; i++)
    {
        if(i % 8 == 0)
        {
            lpOut[i / 8] = 0x00;
        }
        if(lpIn[(subIn[i] - 1) / 8] & (0x80 >> ((subIn[i] - 1) % 8)))
        {
            lpOut[i / 8] |= (0x80 >> (i % 8));
        }
    }
}


static void LeftMove(unsigned char*buf, char move)
{
    unsigned char tmp;
    
    tmp = buf[0];
    buf[0] <<= move;
    buf[0] |= (buf[1] >> (8 - move));
    
    buf[1] <<= move;
    buf[1] |= (buf[2] >> (8 - move));
    
    buf[2] <<= move;
    buf[2] |= (buf[3] >> (8 - move));
    
    buf[3] &= 0xF0;
    buf[3] <<= move;
    buf[3] |= (tmp >> (8 - 4 - move));
}

static void InputKey(unsigned char* Key)
{
    unsigned char tmpkey[32];
    unsigned char C[4];
    unsigned char D[4];
    unsigned char turns;
    
    Substitution((unsigned char*)PC_1, 56, Key, tmpkey);
    
    for(turns = 0; turns < 16; turns++)
    {
        memcpy(C, tmpkey, 4);
        memcpy(D, &tmpkey[3], 4);
        
        D[0] <<= 4;
        D[0] &= 0xF0;
        D[0] |= ((D[1] >> 4) & 0x0F);
        
        D[1] <<= 4;
        D[1] &= 0xF0;
        D[1] |= ((D[2] >> 4) & 0x0F);
        
        D[2] <<= 4;
        D[2] &= 0xF0;
        D[2] |= ((D[3] >> 4) & 0x0F);
        
        D[3] <<= 4;
        D[3] &= 0xF0;
        
        LeftMove((unsigned char*)C, Left_Move[turns]);
        LeftMove((unsigned char*)D, Left_Move[turns]);
        memcpy(tmpkey, C, 4);
        
        tmpkey[3] &= 0xF0;
        tmpkey[3] |= ((D[0] >> 4) & 0x0F);
        
        tmpkey[4] = (D[0] << 4) & 0xF0;
        tmpkey[4] |= ((D[1] >> 4) & 0x0F);
        
        tmpkey[5] = (D[1] << 4) & 0xF0;
        tmpkey[5] |= ((D[2] >> 4) & 0x0F);
        
        tmpkey[6] = (D[2] << 4) & 0xF0;
        tmpkey[6] |= ((D[3] >> 4) & 0x0F);
        
        Substitution((unsigned char*)PC_2, 48, tmpkey, (unsigned char*)gTmpKey[turns]);
    }
}

static void DesCode(unsigned char*lpIn, unsigned char*lpOut, char isEncrypt/*1:加密；0：解密*/)
{
    unsigned char tmp[64];
    char L[4];
    char R[4];
    char KeepR[4];
    int i = 0;
    int j;
    
    signed char turns = 0;
    unsigned char tmpchar;
    
    Substitution((unsigned char*)IP, 64,lpIn, (unsigned char*)tmp);/*IP置换*/
    memcpy(L, tmp, 4);
    memcpy(R, &tmp[4], 4);
    
    if(isEncrypt)
    {
        turns = 0;
    }
    else
    {
        turns = 15;
    }
    
    while(1)
    {
        if(isEncrypt)
        {
            if(turns >= 16)
            {
                break;
            }
        }
        else
        {
            if(turns < 0)
            {
                break;
            }
        }
        memcpy(KeepR, R, sizeof(R));
        Substitution((unsigned char*)Extern, 48, (unsigned char*)R, (unsigned char*)tmp);
        
        for(i = 0; i < 6; i++)
        {
            tmp[i] = tmp[i] ^ gTmpKey[turns][i];
        }
        
        /*S盒子计算*/
        for(i = 0; i < 8; i++)
        {
            /*8bit*6字节 转换成6bit*8字节*/
            tmpchar = tmp[i * 6 / 8];
            j = (i * 6) % 8;
            if(j > 2)
            {
                //两个字节
                tmpchar <<= (j - 2);
                tmpchar |= (tmp[i * 6 / 8 + 1] >> (10 - j));
                tmpchar &= 0x3F;
            }
            else
            {
                tmpchar >>= (2- j);
                tmpchar &= 0x3F;
            }
            tmpchar |= ((tmpchar & 0x20) << 1);
            tmpchar &= (~0x20);
            tmpchar |= ((tmpchar & 0x01) << 5);
            tmpchar = (tmpchar >> 1) & 0x3F;
            tmpchar = (unsigned char)S_BOX[i][tmpchar];
            tmpchar &= 0x0F;
            tmpchar = (tmpchar << (((i + 1) % 2) * 4));
            tmp[i / 2] &= (0x0F << (((i) % 2) * 4));
            tmp[i / 2] |= tmpchar;
        }
        Substitution((unsigned char*)P, 32, (unsigned char*)tmp, (unsigned char*)R);
        
        for(j = 0; j < sizeof(R); j++)
        {
            R[j] ^= L[j];/*异或运算*/
            L[j] = KeepR[j];/*交换左右明文*/
        }
        
        /*合到一起*/
        memcpy(tmp, L, sizeof(L));
        memcpy(tmp + 4, R, sizeof(R));
        
        if(isEncrypt)
        {
            turns++;
        }
        else
        {
            turns--;
        }
    }
    
    for(i = 0; i < 4; i++)
    {
        tmpchar = tmp[4 + i];
        tmp[4 + i] = tmp[i];
        tmp[i] = tmpchar;
    }
    
    /*IP的逆置换*/
    Substitution((unsigned char*)IP_1, 64, (unsigned char*)tmp, lpOut);
    //OutHex(lpOut, 8);
}

/*
 int main(array<System::String ^> ^args)
 {
	int i;
	unsigned char key[] = "111111111111111111";//"\xa3\x44\x57\x79\x9b\xbc\xdf\xf1";
	unsigned char EnData[] = "1111111111111111";//"\xA4\x06\x75\x38\x54\xAB\xCD\xEF";
	char DeData[8];
 
	InputKey((unsigned char*)key);
	DesCode((unsigned char*)EnData, (unsigned char*)DeData, 0);
 
	getchar();
	return 0;
 }
 */
