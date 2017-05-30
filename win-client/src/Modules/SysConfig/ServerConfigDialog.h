 /*******************************************************************************
 *  @file      ServerConfigDialog.h 2014\9\16 13:24:12 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef SERVERCONFIGDIALOG_7A5E8519_6F0B_4583_BAE3_DD51D7A1BE7C_H__
#define SERVERCONFIGDIALOG_7A5E8519_6F0B_4583_BAE3_DD51D7A1BE7C_H__

#include "DuiLib/UIlib.h"
/******************************************************************************/
using namespace DuiLib;

/**
 * The class <code>ServerConfigDialog</code> 
 *
 */
class ServerConfigDialog final : public WindowImplBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    ServerConfigDialog();
    /**
     * Destructor
     */
	virtual ~ServerConfigDialog();
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
	BOOL _ApplySetting();
private:
	CButtonUI*				m_pbtnApply;
	CTextUI*				m_pText;
	CEditUI*				m_pEditAddress;
};
/******************************************************************************/
#endif// SERVERCONFIGDIALOG_7A5E8519_6F0B_4583_BAE3_DD51D7A1BE7C_H__