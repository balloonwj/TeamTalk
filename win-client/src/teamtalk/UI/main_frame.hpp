#ifndef MAINFRAME_HPP
#define MAINFRAME_HPP

#include "GlobalDefine.h"
#include "TTLogic/MKObserver.h"
#include "skin_change_event.hpp"
#include "UIFriends.hpp"

namespace
{
	const TCHAR* const kTitleControlName = _T("apptitle");
	const TCHAR* const kCloseButtonControlName = _T("closebtn");
	const TCHAR* const kMinButtonControlName = _T("minbtn");
	const TCHAR* const kMaxButtonControlName = _T("maxbtn");
	const TCHAR* const kRestoreButtonControlName = _T("restorebtn");

	const TCHAR* const kMainTabControlName = _T("tabs");

	const TCHAR* const kFriendButtonControlName = _T("friendbtn");
	const TCHAR* const kGroupButtonControlName = _T("groupbtn");
	const TCHAR* const kMicroBlogButtonControlName = _T("RecentlyListbtn");

	const TCHAR* const kFriendsListControlName = _T("friends");
	const TCHAR* const kGroupsListControlName = _T("groups");
	const TCHAR* const kRecentlyListControlName = _T("RecentlyList");//最近联系人

	const TCHAR* const kHideLeftMainPannelControlName = _T("btnleft");
	const TCHAR* const kShowLeftMainPannelControlName = _T("btnright");
	const TCHAR* const kLeftMainPannelControlName = _T("LeftMainPanel");

	const TCHAR* const kSignatureTipsControlName = _T("signaturetip");
	const TCHAR* const kSignatureControlName = _T("signature");

	const TCHAR* const kSearchEditTipControlName = _T("search_tip");
	const TCHAR* const kSearchEditControlName = _T("search_edit");

	const TCHAR* const kChangeBkSkinControlName = _T("bkskinbtn");
	const TCHAR* const kChangeColorSkinControlName = _T("colorskinbtn");

	const TCHAR* const kBackgroundControlName = _T("bg");

	const int kBackgroundSkinImageCount = 3;
}
class MainFrame : public WindowImplBase
{
public:
	MainFrame();
	virtual ~MainFrame();
	DUI_DECLARE_MESSAGE_MAP()

public:
	LPCTSTR GetWindowClassName() const;	
	virtual void OnFinalMessage(HWND hWnd);
	virtual void InitWindow();
	virtual LRESULT ResponseDefaultKeyEvent(WPARAM wParam);
	virtual CDuiString GetSkinFile();
	virtual CDuiString GetSkinFolder();
	//virtual UILIB_RESOURCETYPE GetResourceType() const;
	//virtual LPCTSTR GetResourceID() const;
	virtual CControlUI* CreateControl(LPCTSTR pstrClass);
	virtual LRESULT OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	virtual LRESULT HandleCustomMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	virtual LRESULT OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    DWORD GetBkColor();
    void SetBkColor(DWORD dwBackColor);

public:
	void OnLoginModuleEvent(UInt16 moduleId, UInt32 keyId, MKO_TUPLE_PARAM mkoParam);

protected:	
	void OnPrepare(TNotifyUI& msg);
	void OnExit(TNotifyUI& msg);
	void OnTimer(TNotifyUI& msg);
	void OnTextChanged(TNotifyUI& msg);
	void OnKillFocusSignature(TNotifyUI& msg);
	void OnKillFocusSearchEdit(TNotifyUI& msg);
	void OnClick(TNotifyUI& msg);
	void OnSelectChange(TNotifyUI& msg);
	void OnItemActivate(TNotifyUI& msg);
	void OnItemClick(TNotifyUI& msg);
private:

	void UpdateFriendsList();

	void UpdateGroupsList();

	void UpdateRecentlyList();

	void ShowSearchResList();

private:
	int bk_image_index_;

	FriendListItemInfo myself_info_;
	std::vector<FriendListItemInfo> friends_;

	SkinChangedObserver skin_changed_observer_;
};

#endif // MAINFRAME_HPP