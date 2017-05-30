/*******************************************************************************
 *  @file      IniOperation.h 2014\12\30 15:23:20 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     Source: http://www.codeproject.com/Articles/10809/A-Small-Class-to-Read-INI-File ////
 ******************************************************************************/

#ifndef INIOPERATION_372131CD_292F_4837_8C4D_A01CF07CC4B6_H__
#define INIOPERATION_372131CD_292F_4837_8C4D_A01CF07CC4B6_H__

#include "utility/utilityDll.h"
#include "GlobalDefine.h"
#include <windows.h>

/******************************************************************************/
NAMESPACE_BEGIN(util)
class UTILITY_CLASS CIniReader
{
public:
	CIniReader(LPCTSTR szFileName);
	~CIniReader() = default;
	int ReadInteger(LPCTSTR szSection, LPCTSTR szKey, int iDefaultValue);
	float ReadFloat(LPCTSTR szSection, LPCTSTR szKey, float fltDefaultValue);
	bool ReadBoolean(LPCTSTR szSection, LPCTSTR szKey, bool bolDefaultValue);
	CString ReadString(LPCTSTR szSection, LPCTSTR szKey, LPCTSTR szDefaultValue);
private:
	TCHAR m_szFileName[255];
};


class UTILITY_CLASS CIniWriter
{
public:
	CIniWriter(LPCTSTR szFileName);
	~CIniWriter() = default;
	void WriteInteger(LPCTSTR szSection, LPCTSTR szKey, int iValue);
	void WriteFloat(LPCTSTR szSection, LPCTSTR szKey, float fltValue);
	void WriteBoolean(LPCTSTR szSection, LPCTSTR szKey, bool bolValue);
	void WriteString(LPCTSTR szSection, LPCTSTR szKey, LPCTSTR szValue);
private:
	TCHAR m_szFileName[255];
};

NAMESPACE_END(util)
/******************************************************************************/
#endif// INIOPERATION_372131CD_292F_4837_8C4D_A01CF07CC4B6_H__
