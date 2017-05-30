#pragma once

#ifndef __AFXWIN_H__
	#error "在包含此文件之前包含“stdafx.h”以生成 PCH 文件"
#endif

#include "resource.h"

class MainDialog;

class CteamtalkApp : public CWinApp
{
public:
	CteamtalkApp();

public:
	virtual BOOL InitInstance();
	virtual BOOL ExitInstance();

private:
	/**
	 *  创建用户目录
	 *
	 * @return  BOOL
	 * @exception there is no any exception to throw.
	 */	
	BOOL _CreateUsersFolder();
	/**
	 * 创建主窗口
	 *
	 * @return  BOOL
	 * @exception there is no any exception to throw.
	 */	
	BOOL _CreateMainDialog();
	/**
	* 销毁主窗口
	*
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	BOOL _DestroyMainDialog();
	/**
	* 判断是否是单实例
	*
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	BOOL _IsHaveInstance();

	void _InitLog();

private:
	MainDialog*						m_pMainDialog;
};

extern CteamtalkApp theApp;