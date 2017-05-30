/******************************************************************************* 
 *  @file      utilCommonAPI.cpp 2014\7\15 20:30:45 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "utility/utilCommonAPI.h"
#include "md5.h"
#include <shlwapi.h>
#include <shellapi.h>

/******************************************************************************/
NAMESPACE_BEGIN(util)

CString binToHexToCString(const unsigned char * data, size_t len)
{
	TCHAR * Hex = (TCHAR *)_T("0123456789abcdef");
	std::wstring hex;
	hex.resize(len << 1);

	for (size_t i = 0; i < len; i++)
	{
		UINT b = (UINT)data[i];
		hex[i * 2] = Hex[b >> 4];
		hex[i * 2 + 1] = Hex[b & 0xF];
	}

	return hex.c_str();
}

void getMd5CString(const char* pSrc, size_t length, std::vector<unsigned char>& res)
{
	res.clear();
	res.resize(16);
	md5_ctxt ctx;
	md5_init(&ctx);
	md5_loop(&ctx, (BYTE*)pSrc, length);
	md5_pad(&ctx);
	md5_result(&res[0], &ctx);
}

CString getMd5CString(const char* pSrc, size_t length)
{
	std::vector<unsigned char> bmd5;
	getMd5CString(pSrc, length, bmd5);

	return binToHexToCString(&bmd5[0], 16);
}

CString getAppPath()
{
	static CString g_sDllPath = _T("");

	if (g_sDllPath.IsEmpty())
	{
		TCHAR	buffer[MAX_PATH];
		ZeroMemory(buffer, sizeof(TCHAR)* MAX_PATH);
		HMODULE h = GetModuleHandle(NULL);
		::GetModuleFileName(h, buffer, MAX_PATH);
		::PathRemoveFileSpec(buffer);
		g_sDllPath = buffer;
		g_sDllPath += _T("\\");
	}
	return g_sDllPath;
}

CString getParentAppPath()
{
	static CString g_csParentAppPath = _T("");
	if (g_csParentAppPath.IsEmpty())
	{
		g_csParentAppPath = getAppPath();
		LPTSTR lpszPath = g_csParentAppPath.GetBuffer();
		::PathRemoveBackslash(lpszPath);
		::PathRemoveFileSpec(lpszPath);
		g_csParentAppPath = lpszPath;
		g_csParentAppPath += _T("\\");
	}
	return g_csParentAppPath;
}

BOOL createAllDirectories(CString & csDir)
{
	if (csDir.Right(1) == _T("\\"))
	{
		csDir = csDir.Left(csDir.GetLength() - 1);
	}

	if (::GetFileAttributes(csDir) != INVALID_FILE_ATTRIBUTES)
	{
		return TRUE;
	}

	int nFound = csDir.ReverseFind('\\');
	createAllDirectories(csDir.Left(nFound));

	if (!::CreateDirectory(csDir, NULL))
	{
		return FALSE;
	}

	return TRUE;
}

UInt32 hash_BKDR(const char* str)
{
	unsigned int seed = 131; // 31 131 1313 13131 131313 etc.
	unsigned int hash = 0;
	while (*str)
	{
		hash = hash * seed + (*str++);
	}

	return (hash & 0x7FFFFFFF);
}

void messagePump()
{
	MSG msg;
	while (::GetMessage(&msg, NULL, 0, 0) > 0)
	{
		::TranslateMessage(&msg);
		::DispatchMessage(&msg);
	}
}

std::string getHumanReadableSizeString(double size)
{
	//const TCHAR* units[] = { _T("B"), _T("KB"), _T("MB"), _T("GB"), _T("TB"), _T("PB"), _T("EB"), _T("ZB"), _T("YB") };
	const char* units[] = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" };
	int i = 0;
	while (size > 1024)
	{
		size /= 1024;
		i++;
	}
	char buf[1024];
	sprintf_s(buf, 1024,"%.*f %s", i, size, units[i]);
	return std::string(buf);
}

BOOL isFileExist(IN const LPCTSTR csFileName)
{
	PTR_FALSE(csFileName);
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind;

	hFind = FindFirstFile(csFileName, &FindFileData);

	if (hFind == INVALID_HANDLE_VALUE)
	{
		LOG__(DEBG, _T("Invalid File Handle,maybe file isn't exist! filepath:%s,Get Last Error:%d"),csFileName, GetLastError());
		return FALSE;
	}
	else
	{
		FindClose(hFind);
	}
	return TRUE;
}

BOOL registerDll(const CString& sFilePath)
{
	if (!PathFileExists(sFilePath))
		return FALSE;

	typedef LRESULT(*DllRegisterServerProc)(void);
	BOOL retVal = FALSE;
	HINSTANCE hDll = LoadLibrary(sFilePath);
	while (TRUE)
	{
		if (hDll == NULL)
			break;
		DllRegisterServerProc DllRegisterServer;
		DllRegisterServer = (DllRegisterServerProc)GetProcAddress(hDll, "DllRegisterServer");
		if (DllRegisterServer == NULL)
			break;

		int temp = DllRegisterServer();
		if (temp != S_OK)
			break;

		retVal = TRUE;
		break;
	}

	if (retVal == FALSE)
	{
		LOG__(ERR, _T("register dll failed,%s"), sFilePath);
	}

	FreeLibrary(hDll);
	return retVal;
}

BOOL waitSingleObject(HANDLE handle, Int32 timeout)
{
	int t = 0;
	DWORD waitResult = WAIT_FAILED;
	do
	{
		int timeWaiter = 500;
		t += timeWaiter;
		waitResult = WaitForSingleObject(handle, timeWaiter);
	} while ((WAIT_TIMEOUT == waitResult) && (t < timeout));

	return (WAIT_OBJECT_0 == waitResult);
}

NAMESPACE_END(util)
/******************************************************************************/