 /*******************************************************************************
 *  @file      UserDetailInfoDialog.h 2014\10\22 11:14:34 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef USERDETAILINFODIALOG_9D88F1FB_337B_4EF3_8282_4B28D272199E_H__
#define USERDETAILINFODIALOG_9D88F1FB_337B_4EF3_8282_4B28D272199E_H__

#include "DuiLib/UIlib.h"
#include "GlobalDefine.h"
#include <memory>
using namespace DuiLib;
namespace module
{
	struct IHttpOperation;
}

/******************************************************************************/

/**
 * The class <code>UserDetailInfoDialog</code> 
 *
 */
class UserDetailInfoDialog : public WindowImplBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    UserDetailInfoDialog(IN std::string sid);
    /**
     * Destructor
     */
    ~UserDetailInfoDialog() = default;
    //@}

	LPCTSTR GetWindowClassName() const;
	virtual CDuiString GetSkinFile();
	virtual CDuiString GetSkinFolder();
	virtual void OnFinalMessage(HWND hWnd);
	DUI_DECLARE_MESSAGE_MAP()

	void onHttpGetAvatarCallback(std::shared_ptr<void> param);
private:
	void OnWindowInitialized(TNotifyUI& msg);
	void OnClick(TNotifyUI& msg);

	void _refreshAvatar(IN const std::string& avatarPath);
private:
	std::string m_sid;
	CControlUI* m_AvatarUI;
	module::IHttpOperation*		m_pDownHttpOper = 0;
};
/******************************************************************************/
#endif// USERDETAILINFODIALOG_9D88F1FB_337B_4EF3_8282_4B28D272199E_H__
