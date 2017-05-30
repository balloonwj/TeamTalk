/*******************************************************************************
 *  @file      ErrorCode.h 2012\8\16 22:21:34 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief	   IMCORE本地错误码的定义,通信协议的错误码定义在PortErrorCode.h
 ******************************************************************************/

#ifndef ERRORCODE_4A19179B_20B8_4BF7_AD9A_2468C3BF9AB7_H__
#define ERRORCODE_4A19179B_20B8_4BF7_AD9A_2468C3BF9AB7_H__

#include "GlobalDefine.h"
/******************************************************************************/
NAMESPACE_BEGIN(imcore)

typedef UInt32  IMCoreErrorCode;

//错误掩码，error code flag
const IMCoreErrorCode IMCORE_FLAG					= 0x000000U; // 此码代表常规错误
const IMCoreErrorCode IMCORE_WORK_FLAG				= 0x010000U; // 此码代表后台任务opertaion,event产生的错误

//常规错误
const IMCoreErrorCode IMCORE_OK									= IMCORE_FLAG | 0x00U;   //一切OK
const IMCoreErrorCode IMCORE_ALLOC_ERROR						= IMCORE_FLAG | 0x01U;   //内存分配错误
const IMCoreErrorCode IMCORE_INVALID_HWND_ERROR					= IMCORE_FLAG | 0x02U;   //无效的窗口句柄
const IMCoreErrorCode IMCORE_ARGUMENT_ERROR						= IMCORE_FLAG | 0x03U;   //逻辑参数错误
const IMCoreErrorCode IMCORE_FILE_OPEN_ERROR					= IMCORE_FLAG | 0x04U;   //文件打开失败
const IMCoreErrorCode IMCORE_FILE_READ_ERROR					= IMCORE_FLAG | 0x05U;   //文件读取失败
const IMCoreErrorCode IMCORE_FILE_WRITE_ERROR					= IMCORE_FLAG | 0x06U;   //文件读取失败
const IMCoreErrorCode IMCORE_FILE_SYSTEM_ERROR					= IMCORE_FLAG | 0x07U;   //文件未知异常

//opertaion event错误
const IMCoreErrorCode IMCORE_WORK_INTERNEL_ERROR				= IMCORE_WORK_FLAG | 0x01;   //worker内部错误
const IMCoreErrorCode IMCORE_WORK_PUSHOPERTION_ERROR			= IMCORE_WORK_FLAG | 0x02;   //opertaion start失败
const IMCoreErrorCode IMCORE_WORK_POSTMESSAGE_ERROR				= IMCORE_WORK_FLAG | 0x03;   //
const IMCoreErrorCode IMCORE_WORK_TIMER_INEXISTENCE_ERROR		= IMCORE_WORK_FLAG | 0x04;   //Timer不存在

NAMESPACE_END(imcore)
/******************************************************************************/
#endif// ERRORCODE_4A19179B_20B8_4BF7_AD9A_2468C3BF9AB7_H__