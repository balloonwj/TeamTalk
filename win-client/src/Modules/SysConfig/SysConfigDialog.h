 /*******************************************************************************
 *  @file      SettingDialog.h 2014\8\6 20:05:34 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef SETTINGDIALOG_D45AE043_1F5F_4CBD_833A_309EBBA7F18E_H__
#define SETTINGDIALOG_D45AE043_1F5F_4CBD_833A_309EBBA7F18E_H__

#include "DuiLib/UIlib.h"
/******************************************************************************/
using namespace DuiLib;

/**
 * The class <code>SettingDialog</code> 
 *
 */
class SysConfigDialog final : public WindowImplBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    SysConfigDialog();
    /**
     * Destructor
     */
    virtual ~SysConfigDialog();
    //@}
	DUI_DECLARE_MESSAGE_MAP()
public:
	LPCTSTR GetWindowClassName() const;
	virtual CDuiString GetSkinFile();
	virtual CDuiString GetSkinFolder();
	virtual CControlUI* CreateControl(LPCTSTR pstrClass);
	virtual void OnFinalMessage(HWND hWnd);

protected:
	void OnWindowInitialized(TNotifyUI& msg);
	void OnClick(TNotifyUI& msg);

private:
	void _InitlizeSetting();
	void _ApplySetting();
private:
	CButtonUI*				m_pbtnApply;
	CButtonUI*				m_pbtnClose;

	CCheckBoxUI*			m_topmostBtn;
	CCheckBoxUI*			m_newmessagealertBtn;
	
	CCheckBoxUI*			m_soundBtn;
	COptionUI*				m_DingdongRdo;
	COptionUI*				m_HujiaoRdo;
	COptionUI*				m_JianpanRdo;
	COptionUI*				m_DinglinRdo;
	CButtonUI*				m_TestSoundBtn;

	COptionUI*				m_CtrlEntrtRdo;
	COptionUI*				m_EnterRdo;
};
/******************************************************************************/
#endif// SETTINGDIALOG_D45AE043_1F5F_4CBD_833A_309EBBA7F18E_H__
