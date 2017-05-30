/******************************************************************************* 
 *  @file      IniOperation.cpp 2014\12\30 15:27:52 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     Source: http://www.codeproject.com/Articles/10809/A-Small-Class-to-Read-INI-File ////
 ******************************************************************************/

#include "stdafx.h"
#include "utility/IniOperation.h"
#include <iostream>

NAMESPACE_BEGIN(util)

/////////////////////////////CIniReader/////////////////////////////////////////////
CIniReader::CIniReader(LPCTSTR szFileName)
{
	memset(m_szFileName, 0x00, sizeof(m_szFileName));
	memcpy(m_szFileName, szFileName, _tcslen(szFileName)*sizeof(TCHAR));
}
int CIniReader::ReadInteger(LPCTSTR szSection, LPCTSTR szKey, int iDefaultValue)
{
	int iResult = GetPrivateProfileInt(szSection, szKey, iDefaultValue, m_szFileName);
	return iResult;
}
float CIniReader::ReadFloat(LPCTSTR szSection, LPCTSTR szKey, float fltDefaultValue)
{
	TCHAR szResult[255] = { 0 };
	TCHAR szDefault[255] = { 0 };
	float fltResult;
	_stprintf_s(szDefault, 255, TEXT("%f"), fltDefaultValue);
	GetPrivateProfileString(szSection, szKey, szDefault, szResult, 255, m_szFileName);
	fltResult = (float)_tstof(szResult);
	return fltResult;
}
bool CIniReader::ReadBoolean(LPCTSTR szSection, LPCTSTR szKey, bool bolDefaultValue)
{
	TCHAR szResult[255] = { 0 };
	TCHAR szDefault[255] = { 0 };
	bool bolResult;
	_stprintf_s(szDefault, 255, TEXT("%s"), bolDefaultValue ? TEXT("True") : TEXT("False"));
	GetPrivateProfileString(szSection, szKey, szDefault, szResult, 255, m_szFileName);
	bolResult = (_tcscmp(szResult, TEXT("True")) == 0 ||
		_tcscmp(szResult, TEXT("true")) == 0) ? true : false;
	return bolResult;
}
CString CIniReader::ReadString(LPCTSTR szSection, LPCTSTR szKey, LPCTSTR szDefaultValue)
{
	TCHAR szResult[255] = { 0 };
	GetPrivateProfileString(szSection, szKey, szDefaultValue, szResult, 255, m_szFileName);
	return CString(szResult);
}

////////////////////////////CIniWriter//////////////////////////////////////////////


CIniWriter::CIniWriter(LPCTSTR szFileName)
{
	memset(m_szFileName, 0x00, sizeof(m_szFileName));
	memcpy(m_szFileName, szFileName, _tcslen(szFileName)*sizeof(TCHAR));
}
void CIniWriter::WriteInteger(LPCTSTR szSection, LPCTSTR szKey, int iValue)
{
	TCHAR szValue[255] = { 0 };
	_stprintf_s(szValue, 255, TEXT("%d"), iValue);
	WritePrivateProfileString(szSection, szKey, szValue, m_szFileName);
}
void CIniWriter::WriteFloat(LPCTSTR szSection, LPCTSTR szKey, float fltValue)
{
	TCHAR szValue[255] = { 0 };
	_stprintf_s(szValue, 255, TEXT("%f"), fltValue);
	WritePrivateProfileString(szSection, szKey, szValue, m_szFileName);
}
void CIniWriter::WriteBoolean(LPCTSTR szSection, LPCTSTR szKey, bool bolValue)
{
	TCHAR szValue[255] = {0};
	_stprintf_s(szValue, 255, TEXT("%s"), bolValue ? TEXT("True") : TEXT("False"));
	WritePrivateProfileString(szSection, szKey, szValue, m_szFileName);
}
void CIniWriter::WriteString(LPCTSTR szSection, LPCTSTR szKey, LPCTSTR szValue)
{
	WritePrivateProfileString(szSection, szKey, szValue, m_szFileName);
}

NAMESPACE_END(util)