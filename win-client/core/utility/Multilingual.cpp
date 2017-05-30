/******************************************************************************* 
 *  @file      Multilingual.cpp 2014\11\25 21:14:50 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "GlobalConfig.h"
#include "utility/utilCommonAPI.h"
#include "utility/Multilingual.h"

/******************************************************************************/
NAMESPACE_BEGIN(util)

// -----------------------------------------------------------------------------
//  Multilingual: Public, Constructor

Multilingual::Multilingual()
{

}

// -----------------------------------------------------------------------------
//  Multilingual: Public, Destructor

Multilingual::~Multilingual()
{

}

CString Multilingual::getStringById(LPCTSTR strID)
{
	CString cfgPath = util::getParentAppPath() + UTIL_MULTILIGNUAL;
	TCHAR szValue[MAX_PATH];
	::GetPrivateProfileString(_T("DEFAULT"),strID,_T(""), szValue, MAX_PATH
		, cfgPath);

	return szValue;
}

Multilingual* getMultilingual()
{
	static Multilingual multi;
	return &multi;
}

NAMESPACE_END(util)
/******************************************************************************/