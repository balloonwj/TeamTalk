/******************************************************************************* 
 *  @file      MainDialog_TrayIcon.cpp 2014\8\19 20:17:29 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "MainDialog.h"
/******************************************************************************/

void MainDialog::OnTrayIconNotify(WPARAM wParam, LPARAM lParam)
{
	if (wParam != m_niData.uID)
		return;

	switch (LOWORD(lParam))
	{
	case WM_RBUTTONUP:
	{
		POINT point;
		GetCursorPos(&point);			// 获取鼠标指针位置（屏幕坐标）
		CMenuWnd* pMenu = new CMenuWnd(m_hWnd);
		//ScreenToClient(m_hWnd, &point);	// 将鼠标指针位置转换为窗口坐标
		//ClientToScreen(m_hWnd, &point);
		STRINGorID xml(_T("menu\\TrayIconMenu.xml"));
		pMenu->Init(NULL, xml, _T("xml"), point);
	}
		break;
	case WM_LBUTTONDOWN:
		BringToTop();
		StopNewMsgTrayEmot();
		break;
	case WM_LBUTTONDBLCLK:
		break;
	default:
		break;
	}
}

BOOL MainDialog::InstallIcon(LPCTSTR lpszToolTip, HICON hIcon, UINT nID, BOOL bReInstall /*= FALSE*/)
{
	if (bReInstall)
	{
		RemoveIcon();
	}
	else if (m_bInstalled)
	{
		return false;
	}

	ATLASSERT(m_hWnd && IsWindow(m_hWnd));
	m_niData.hWnd = m_hWnd;

	m_niData.uID = nID;
	m_niData.hIcon = hIcon;
	m_niData.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
	m_niData.uCallbackMessage = WM_TRAYICON_NOTIFY;
	_tcscpy_s(m_niData.szTip, sizeof(m_niData.szTip) / sizeof(TCHAR), lpszToolTip);

	m_bInstalled = Shell_NotifyIcon(NIM_ADD, &m_niData) ? TRUE : false;

	return m_bInstalled;
}

BOOL MainDialog::RemoveIcon()
{
	if (!m_bInstalled)
		return false;

	m_niData.uFlags = 0;
	BOOL ret = Shell_NotifyIcon(NIM_DELETE, &m_niData) ? TRUE : false;

	if (ret)
	{
		m_bInstalled = false;
		m_bHidden = TRUE;
	}

	return ret;
}

BOOL MainDialog::SetTrayIcon(HICON hIcon)
{
	if (!m_bInstalled)
		return false;

	m_niData.uFlags = NIF_ICON;
	m_niData.hIcon = hIcon;

	return Shell_NotifyIcon(NIM_MODIFY, &m_niData) ? TRUE : false;
}

BOOL MainDialog::HideIcon(void)
{
	if (!m_bInstalled)
		return false;

	BOOL bResult = TRUE;
	if (!m_bHidden)
	{
		if (GetShellVersion() >= 5) //use the Shell v5 way of hiding the icon
		{
#if (_WIN32_IE >= 0x0500)
			m_niData.uFlags = NIF_STATE;
			m_niData.dwState = NIS_HIDDEN;
			m_niData.dwStateMask = NIS_HIDDEN;
#endif
			bResult = Shell_NotifyIcon(NIM_MODIFY, &m_niData) ? TRUE : false;
		}
		else
		{
			m_niData.uFlags = 0;
			bResult = Shell_NotifyIcon(NIM_DELETE, &m_niData) ? TRUE : false;
		}

		if (bResult)
		{
			m_bHidden = TRUE;
		}

	}
	return bResult;
}

BOOL MainDialog::ShowIcon()
{
	if (!m_bInstalled)
		return false;

	BOOL bResult = TRUE;
	if (m_bHidden)
	{
		if (GetShellVersion() >= 5) //use the Shell v5 way of showing the icon
		{
#if (_WIN32_IE >= 0x0500)
			m_niData.uFlags = NIF_STATE;
			m_niData.dwState = 0;
			m_niData.dwStateMask = NIS_HIDDEN;
			bResult = Shell_NotifyIcon(NIM_MODIFY, &m_niData) ? TRUE : false;
#endif
		}
		else
		{
			m_niData.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
			bResult = Shell_NotifyIcon(NIM_ADD, &m_niData) ? TRUE : false;
		}

		if (bResult)
		{
			m_bHidden = false;
		}
	}
	return bResult;
}

BOOL MainDialog::SetTrayTooltipText(LPCTSTR pszTooltipText)
{
	if (!m_bInstalled)
		return false;

	m_niData.uFlags = NIF_TIP;
	_tcscpy_s(m_niData.szTip, sizeof(m_niData.szTip) / sizeof(TCHAR), pszTooltipText);

	return Shell_NotifyIcon(NIM_MODIFY, &m_niData) ? TRUE : false;
}

BOOL MainDialog::SetBalloonDetails(LPCTSTR pszBalloonText, LPCTSTR pszBalloonCaption, BalloonStyle style /*= BALLOON_INFO*/, UINT nTimeout /*= 1000*/, HICON hUserIcon /*= NULL*/, BOOL bNoSound /*= FALSE*/)
{
	if (!m_bInstalled)
		return false;

	ATLASSERT(GetShellVersion() >= 5); //Only supported on Shell v5 or later

#if (_WIN32_IE >= 0x0500)
	m_niData.uFlags = NIF_INFO;
#endif
#if (_MSC_VER >= 1400)
	_tcscpy_s(m_niData.szInfo, sizeof(m_niData.szInfo) / sizeof(TCHAR), pszBalloonText);
	_tcscpy_s(m_niData.szInfoTitle, sizeof(m_niData.szInfoTitle) / sizeof(TCHAR), pszBalloonCaption);
#else  
	_tcscpy(m_niData.szInfo, pszBalloonText);
	_tcscpy(m_niData.szInfoTitle, pszBalloonCaption);
#endif  
	m_niData.uTimeout = nTimeout;
#if (_WIN32_IE >= 0x0500)
	switch (style)
	{
	case BALLOON_WARNING:
		m_niData.dwInfoFlags = NIIF_WARNING;
		break;
	case BALLOON_ERROR:
		m_niData.dwInfoFlags = NIIF_ERROR;
		break;
	case BALLOON_INFO:
		m_niData.dwInfoFlags = NIIF_INFO;
		break;
	case BALLOON_NONE:
		m_niData.dwInfoFlags = NIIF_NONE;
		break;
#if (_WIN32_IE >= 0x0600)
	case BALLOON_USER:
		ATLASSERT(hUserIcon != NULL);
		m_niData.dwInfoFlags = NIIF_USER;
		m_niData.hIcon = hUserIcon;
		break;
#endif
	default:
		ATLASSERT(FALSE);
		break;
	}
#endif
#if (_WIN32_IE >= 0x0501)
	if (bNoSound)
		m_niData.dwInfoFlags |= NIIF_NOSOUND;
#endif
	return Shell_NotifyIcon(NIM_MODIFY, &m_niData) ? TRUE : false;
}

BOOL MainDialog::IsIconInstalled()
{
	return m_bInstalled;
}

BOOL MainDialog::SetVersion(UINT uVersion)
{
	ATLASSERT(GetShellVersion() >= 5);

	m_niData.uVersion = uVersion;
#if (_WIN32_IE >= 0x0500)
	return Shell_NotifyIcon(NIM_SETVERSION, &m_niData) ? TRUE : false;
#else
	return FALSE;
#endif
}

DWORD MainDialog::GetShellVersion(void)
{
	if (m_dwShellVersion)
	{
		return m_dwShellVersion;
	}
	else
	{
		m_dwShellVersion = 4;

		typedef HRESULT(CALLBACK *PFNDLLGETVERSION)(DLLVERSIONINFO*);

		HMODULE hShell32 = GetModuleHandle(_T("shell32.dll"));
		PFNDLLGETVERSION lpfnDllGetVersion = reinterpret_cast<PFNDLLGETVERSION>(GetProcAddress(hShell32, "DllGetVersion"));
		if (lpfnDllGetVersion)
		{
			DLLVERSIONINFO vinfo;
			vinfo.cbSize = sizeof(DLLVERSIONINFO);
			if (SUCCEEDED(lpfnDllGetVersion(&vinfo)))
				m_dwShellVersion = vinfo.dwMajorVersion;
		}
	}

	return m_dwShellVersion;
}

/******************************************************************************/