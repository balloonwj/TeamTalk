/******************************************************************************* 
 *  @file      SettingDialog.cpp 2014\8\6 20:05:26 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "SysConfigDialog.h"
#include "GlobalDefine.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/IMiscModule.h"
#include "Modules/ITcpClientModule.h"

DUI_BEGIN_MESSAGE_MAP(SysConfigDialog, WindowImplBase)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_WINDOWINIT, OnWindowInitialized)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_CLICK, OnClick)
DUI_END_MESSAGE_MAP()

/******************************************************************************/

// -----------------------------------------------------------------------------
//  SettingDialog: Public, Constructor

SysConfigDialog::SysConfigDialog()
:m_pbtnApply(0)
{

}

// -----------------------------------------------------------------------------
//  SettingDialog: Public, Destructor

SysConfigDialog::~SysConfigDialog()
{

}

LPCTSTR SysConfigDialog::GetWindowClassName() const
{
	return _T("TeamTalkSysConfigDialog");
}

DuiLib::CDuiString SysConfigDialog::GetSkinFile()
{
	return  _T("SysConfigDialog\\SysConfigDialog.xml");
}

CControlUI* SysConfigDialog::CreateControl(LPCTSTR pstrClass)
{
	return nullptr;
}

void SysConfigDialog::OnFinalMessage(HWND hWnd)
{
	module::getSysConfigModule()->setSysConfigDialogFlag(FALSE);
	WindowImplBase::OnFinalMessage(hWnd);
	delete this;
}

void SysConfigDialog::OnWindowInitialized(TNotifyUI& msg)
{
	m_pbtnApply = (CButtonUI*)m_PaintManager.FindControl(_T("applybtn"));
	PTR_VOID(m_pbtnApply);
	m_topmostBtn = (CCheckBoxUI*)m_PaintManager.FindControl(_T("topmostBtn"));
	PTR_VOID(m_topmostBtn);
	m_newmessagealertBtn = (CCheckBoxUI*)m_PaintManager.FindControl(_T("newmessagealertBtn"));
	PTR_VOID(m_newmessagealertBtn);
	m_soundBtn = (CCheckBoxUI*)m_PaintManager.FindControl(_T("soundBtn"));
	PTR_VOID(m_soundBtn);
	m_DingdongRdo = (COptionUI*)m_PaintManager.FindControl(_T("DingdongRdo"));
	PTR_VOID(m_DingdongRdo);
	m_HujiaoRdo = (COptionUI*)m_PaintManager.FindControl(_T("HujiaoRdo"));
	PTR_VOID(m_HujiaoRdo);
	m_JianpanRdo = (COptionUI*)m_PaintManager.FindControl(_T("JianpanRdo"));
	PTR_VOID(m_JianpanRdo);
	m_DinglinRdo = (COptionUI*)m_PaintManager.FindControl(_T("DinglinRdo"));
	PTR_VOID(m_DinglinRdo);
	m_TestSoundBtn = (CButtonUI*)m_PaintManager.FindControl(_T("TestSoundBtn"));
	PTR_VOID(m_TestSoundBtn);
	m_CtrlEntrtRdo = (COptionUI*)m_PaintManager.FindControl(_T("CtrlEntrtRdo"));
	PTR_VOID(m_CtrlEntrtRdo);
	m_EnterRdo = (COptionUI*)m_PaintManager.FindControl(_T("EnterRdo"));
	PTR_VOID(m_EnterRdo);

	_InitlizeSetting();
}

void SysConfigDialog::OnClick(TNotifyUI& msg)
{
	if (msg.pSender == m_pbtnApply)
	{
		_ApplySetting();
		Close();
	}
	else if (m_TestSoundBtn == msg.pSender)
	{
		if (m_DingdongRdo->IsSelected())
		{
			module::getMiscModule()->playSound(module::getMiscModule()->getDataDir() + _T("Sound\\dingdong.wav"));
		}
		else if (m_JianpanRdo->IsSelected())
		{
			module::getMiscModule()->playSound(module::getMiscModule()->getDataDir() + _T("Sound\\keyboard.wav"));
		}
		else if (m_DinglinRdo->IsSelected())
		{
			module::getMiscModule()->playSound(module::getMiscModule()->getDataDir() + _T("Sound\\message.wav"));
		}
		else if (m_HujiaoRdo->IsSelected())
		{
			module::getMiscModule()->playSound(module::getMiscModule()->getDataDir() + _T("Sound\\callmsg.wav"));
		}
	}

	__super::OnClick(msg);
}

DuiLib::CDuiString SysConfigDialog::GetSkinFolder()
{
	return _T("");
}

void SysConfigDialog::_InitlizeSetting()
{
	module::TTConfig* pTTConfig = module::getSysConfigModule()->getSystemConfig();
	if (!pTTConfig)
	{
		LOG__(ERR, _T("_InitlizeSetting,读取设置失败"));
		return;
	}
	if (pTTConfig->sysBaseFlag & module::BASE_FLAG_TOPMOST)
	{
		m_topmostBtn->SetCheck(true);
	}
	if (pTTConfig->sysBaseFlag & module::BASE_FLAG_NOTIPWHENNEWMSG)//ui上设置默认选中
	{
		m_newmessagealertBtn->SetCheck(true);
	}
	if (pTTConfig->sysBaseFlag & module::BASE_FLAG_NOSOUNDWHENMSG)
	{
		m_soundBtn->SetCheck(true);
	}
	if (pTTConfig->sysBaseFlag & module::BASE_FLAG_SENDIMG_BY_CTRLENTER)
	{
		m_CtrlEntrtRdo->Selected(true);
	}
	if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_DINGDONG)
	{
		m_DingdongRdo->Selected(true);
	}
	else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_KEYBOARD)
	{
		m_JianpanRdo->Selected(true);	
	}
	else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_DINGLIN)
	{
		m_DinglinRdo->Selected(true);
	}
	else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_CALLMSG)
	{
		m_HujiaoRdo->Selected(true);
	}
}

void SysConfigDialog::_ApplySetting()
{
	module::TTConfig* pTTConfig = module::getSysConfigModule()->getSystemConfig();
	int baseFlag = 0;
	if (!pTTConfig)
	{
		LOG__(ERR, _T("SysConfigDialog::_ApplySetting,读取设置失败"));
		return;
	}
	if (m_topmostBtn->GetCheck())
	{
		baseFlag |= module::BASE_FLAG_TOPMOST;
	}
	if (m_newmessagealertBtn->GetCheck())
	{
		baseFlag |= module::BASE_FLAG_NOTIPWHENNEWMSG;
	}
	if (m_soundBtn->GetCheck())
	{
		baseFlag |= module::BASE_FLAG_NOSOUNDWHENMSG;
	}
	if (m_CtrlEntrtRdo->IsSelected())
	{
		baseFlag |= module::BASE_FLAG_SENDIMG_BY_CTRLENTER;
	}

	pTTConfig->sysBaseFlag = baseFlag;

	if (m_DingdongRdo->IsSelected())
	{
		pTTConfig->sysSoundTypeBaseFlag = module::MUSIC_SOUND_DINGDONG;
	}
	else if (m_JianpanRdo->IsSelected())
	{
		pTTConfig->sysSoundTypeBaseFlag = module::MUSIC_SOUND_KEYBOARD;
	}
	else if (m_DinglinRdo->IsSelected())
	{
		pTTConfig->sysSoundTypeBaseFlag = module::MUSIC_SOUND_DINGLIN;
	}
	else if (m_HujiaoRdo->IsSelected())
	{
		pTTConfig->sysSoundTypeBaseFlag = module::MUSIC_SOUND_CALLMSG;
	}
	module::getSysConfigModule()->asynNotifyObserver(module::KEY_SYSCONFIG_UPDATED);	//通知改动
	module::getSysConfigModule()->saveData();
}

/******************************************************************************/