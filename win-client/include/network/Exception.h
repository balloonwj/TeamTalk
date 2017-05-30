/*******************************************************************************
 *  @file      Exception.h 2012\9\10 16:25:53 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   Âß¼­ÒýÇæÒì³£
 ******************************************************************************/

#ifndef EXCEPTION_7889B422_4F2F_495F_AFAC_180F657486D2_H__
#define EXCEPTION_7889B422_4F2F_495F_AFAC_180F657486D2_H__

#include "GlobalDefine.h"
#include "networkdll.h"
#include <string>
/******************************************************************************/
NAMESPACE_BEGIN(imcore)

#pragma warning(disable: 4251)
struct NETWORK_DLL Exception : public std::exception
{
public:
	Exception(int errorCode, const std::string& msg)
   :m_ErrorCode(errorCode)
   ,m_msg(msg)
    {
    }

public:
    int				m_ErrorCode;
	std::string		m_msg;
};

NAMESPACE_END(imcore)
/******************************************************************************/
#endif// EXCEPTION_7889B422_4F2F_495F_AFAC_180F657486D2_H__