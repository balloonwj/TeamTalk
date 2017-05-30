/******************************************************************************* 
 *  @file      main_frame_event.cpp 2014\7\24 16:04:42 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "main_frame.hpp"
#include "UIGroups.hpp"
#include "UIUserList.h"
#include "main_frame.hpp"
#include "color_skin.hpp"
#include "chat_dialog.hpp"
#include "UIMenu.h"
#include "Modules/ILoginModule.h"
#include "MakeGroupWnd.h"
#include "UI/FloatWnd.h"
#include "UI/LoginWnd.h"
#include "UI/MainDialog.h"
/******************************************************************************/
DUI_BEGIN_MESSAGE_MAP(MainFrame, WindowImplBase)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_WINDOWINIT, OnPrepare)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_TEXTCHANGED, OnTextChanged)
	DUI_ON_KILLFOCUS_CTRNAME(kSignatureControlName, OnKillFocusSignature)
	DUI_ON_KILLFOCUS_CTRNAME(kSearchEditControlName, OnKillFocusSearchEdit)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_CLICK, OnClick)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_TIMER, OnTimer)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_SELECTCHANGED, OnSelectChange)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_ITEMACTIVATE, OnItemActivate)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_ITEMCLICK, OnItemClick)
DUI_END_MESSAGE_MAP()

void MainFrame::OnLoginModuleEvent(UInt16 moduleId, UInt32 keyId, MKO_TUPLE_PARAM mkoParam)
{
	Int32 bb = std::get<MKO_INT>(mkoParam);
	APP_LOG(LOG_DEBUG, _T("OnLoginModuleEvent : %d"),bb);
}

void MainFrame::OnTimer(TNotifyUI& msg)
{
}
void MainFrame::OnTextChanged(TNotifyUI& msg)
{
	ShowSearchResList();
}

void MainFrame::OnKillFocusSignature(TNotifyUI& msg)
{
	msg.pSender->SetVisible(false);
	CControlUI* signature_tip = m_PaintManager.FindControl(kSignatureTipsControlName);
	if (signature_tip != NULL)
	{
		CEditUI* signature = static_cast<CEditUI*>(msg.pSender);
		if (signature != NULL)
			signature_tip->SetText(signature->GetText());
		signature_tip->SetVisible(true);
	}
}

void MainFrame::OnKillFocusSearchEdit(TNotifyUI& msg)
{
	//CEditUI* search_edit = static_cast<CEditUI*>(msg.pSender);
	//if (search_edit != NULL)
	//{
	//	search_edit->SetVisible(false);
	//	CControlUI* search_tip = static_cast<CEditUI*>(m_PaintManager.FindControl(kSearchEditTipControlName));
	//	if (search_tip)
	//	{
	//		search_tip->SetText(search_edit->GetText());
	//		search_tip->SetVisible(true);
	//	}
	//}
	
	//msg.pSender->SetVisible(false);
	//CControlUI* search_tip = static_cast<CRichEditUI*>(m_PaintManager.FindControl(kSearchEditTipControlName));
	//if (search_tip != NULL)
	//{
	//	CRichEditUI* search_edit = static_cast<CRichEditUI*>(msg.pSender);
	//	if (search_edit != NULL)
	//		search_tip->SetText(search_edit->GetText());
	//	search_tip->SetVisible(true);
	//}
}
void MainFrame::OnClick(TNotifyUI& msg)
{
	WindowImplBase::OnClick(msg);
	if (_tcsicmp(msg.pSender->GetName(), kHideLeftMainPannelControlName) == 0)
	{
		CControlUI* left_main_pannel = m_PaintManager.FindControl(kLeftMainPannelControlName);
		CControlUI* hide_left_main_pannel = m_PaintManager.FindControl(kHideLeftMainPannelControlName);
		CControlUI* show_left_main_pannel = m_PaintManager.FindControl(kShowLeftMainPannelControlName);
		if ((left_main_pannel != NULL) && (show_left_main_pannel != NULL) && (hide_left_main_pannel != NULL))
		{
			hide_left_main_pannel->SetVisible(false);
			left_main_pannel->SetVisible(false);
			show_left_main_pannel->SetVisible(true);
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kShowLeftMainPannelControlName) == 0)
	{
		CControlUI* left_main_pannel = m_PaintManager.FindControl(kLeftMainPannelControlName);
		CControlUI* hide_left_main_pannel = m_PaintManager.FindControl(kHideLeftMainPannelControlName);
		CControlUI* show_left_main_pannel = m_PaintManager.FindControl(kShowLeftMainPannelControlName);
		if ((left_main_pannel != NULL) && (show_left_main_pannel != NULL) && (hide_left_main_pannel != NULL))
		{
			hide_left_main_pannel->SetVisible(true);
			left_main_pannel->SetVisible(true);
			show_left_main_pannel->SetVisible(false);
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kSignatureTipsControlName) == 0)
	{
		msg.pSender->SetVisible(false);
		CEditUI* signature = static_cast<CEditUI*>(m_PaintManager.FindControl(kSignatureControlName));
		if (signature != NULL)
		{
			signature->SetText(msg.pSender->GetText());
			signature->SetVisible(true);
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kSearchEditTipControlName) == 0)
	{
		msg.pSender->SetVisible(false);
		CEditUI* search_edit = static_cast<CEditUI*>(m_PaintManager.FindControl(kSearchEditControlName));
		if (search_edit != NULL)
		{
			search_edit->SetText(msg.pSender->GetText());
			search_edit->SetVisible(true);
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kChangeBkSkinControlName) == 0)
	{
		CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
		if (background != NULL)
		{
			TCHAR szBuf[MAX_PATH] = { 0 };
			++bk_image_index_;
			if (kBackgroundSkinImageCount < bk_image_index_)
				bk_image_index_ = 0;

			_stprintf_s(szBuf, MAX_PATH - 1, _T("file='bg%d.png' corner='600,200,1,1'"), bk_image_index_);

			background->SetBkImage(szBuf);

			SkinChangedParam param;
			CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
			if (background != NULL)
			{
				param.bkcolor = background->GetBkColor();
				if (_tcslen(background->GetBkImage()) > 0)
				{
					_stprintf_s(szBuf, MAX_PATH - 1, _T("bg%d.png"), bk_image_index_);
				}

				param.bgimage = szBuf;
			}
			skin_changed_observer_.Broadcast(param);
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kChangeColorSkinControlName) == 0)
	{
		CDuiRect rcWindow;
		GetWindowRect(m_hWnd, &rcWindow);
		rcWindow.top = rcWindow.top + msg.pSender->GetPos().bottom;
		new ColorSkinWindow(this, rcWindow);
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("phone")))
	{
		logic::GetLogic()->asynNotifyObserver(module::KEY_LOGIN_USERID,10);
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("QQpalycenter")))
	{
		logic::GetLogic()->removeObserver(this);
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("MainMenu")))
	{
		CMenuWnd* pMenu = new CMenuWnd(m_hWnd);
		DuiLib::CPoint point = msg.ptMouse;
		ClientToScreen(m_hWnd, &point);
		STRINGorID xml(_T("menutest.xml"));
		pMenu->Init(NULL, xml, _T("xml"), point);
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("ToolsBtn")))//设置按钮
	{
		MakeGroupWnd* pFrame = new MakeGroupWnd();
		if (pFrame == NULL) return;
		pFrame->Create(NULL, _T("MakeGroupWnd"), UI_WNDSTYLE_FRAME, WS_EX_STATICEDGE | WS_EX_APPWINDOW, 0, 0, 600, 800);
		pFrame->CenterWindow();
		pFrame->ShowWindow(true);

	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("QQSafeBtn")))//安全中心
	{
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("messageCenterBtn")))//消息中心
	{
		FloatWnd* pFloatWnd = new FloatWnd();
		if (pFloatWnd == NULL) return;
		pFloatWnd->Create(m_hWnd, _T("FloatWnd"), UI_WNDSTYLE_FRAME|WS_THICKFRAME,  WS_EX_TOOLWINDOW | WS_EX_TOPMOST| WS_EX_STATICEDGE, 0, 0, 0, 0);
		//pFloatWnd->ShowWindow(true);
		pFloatWnd->BringToTop();
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("QzoneBtn")))
	{

	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("QQTradeCenterBtn")))
	{
		int n = 0;
		n++;
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("paipaiBtn")))
	{
		int n = 0;
		n++;
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("PaiPaiChongzhiBtn")))
	{
		int n = 0;
		n++;
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("addBtn")))
	{
		int n = 0;
		n++;
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("friend_circleBtn")))
	{
		LoginWnd* pLoginWnd = new LoginWnd();
		if (pLoginWnd == NULL) return;
		pLoginWnd->Create(NULL, _T("LoginWnd"), /*WS_POPUP | WS_VISIBLE | WS_CLIPSIBLINGS*/UI_WNDSTYLE_FRAME | WS_POPUP, 0/*WS_EX_LAYERED*/, 0, 0, 0, 0);
		pLoginWnd->CenterWindow();
		pLoginWnd->ShowWindow(true); 
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("mailBtn")))
	{
		MainDialog* pMainDialog = new MainDialog();
		if (pMainDialog == NULL) return;
		pMainDialog->Create(NULL, _T("MainDialog"), UI_WNDSTYLE_FRAME | WS_POPUP, 0, 0, 0, 0, 0);
		pMainDialog->CenterWindow();
		pMainDialog->ShowWindow(true);
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("XiaoYouBtn")))
	{
		int n = 0;
		n++;
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("sosoBtn")))
	{
		int n = 0;
		n++;
	}
}

void MainFrame::OnSelectChange(TNotifyUI& msg)
{
	CTabLayoutUI* pTabControl = static_cast<CTabLayoutUI*>(m_PaintManager.FindControl(kMainTabControlName));
	if (_tcsicmp(msg.pSender->GetName(), kFriendButtonControlName) == 0)
	{
		if (pTabControl && pTabControl->GetCurSel() != 0)
		{
			pTabControl->SelectItem(0);
			UpdateFriendsList();
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kGroupButtonControlName) == 0)
	{
		if (pTabControl && pTabControl->GetCurSel() != 1)
		{
			pTabControl->SelectItem(1);
			UpdateGroupsList();
		}
	}
	else if (_tcsicmp(msg.pSender->GetName(), kMicroBlogButtonControlName) == 0)
	{
		if (pTabControl && pTabControl->GetCurSel() != 2)
		{
			pTabControl->SelectItem(2);
			UpdateRecentlyList();
		}
	}
}

void MainFrame::OnItemActivate(TNotifyUI& msg)
{
	CTabLayoutUI* pTabControl = static_cast<CTabLayoutUI*>(m_PaintManager.FindControl(kMainTabControlName));
	if (pTabControl != NULL)
	{
		if (pTabControl->GetCurSel() == 0)
		{
			CFriendsUI* pFriendsList = static_cast<CFriendsUI*>(m_PaintManager.FindControl(kFriendsListControlName));
			if ((pFriendsList != NULL) && pFriendsList->GetItemIndex(msg.pSender) != -1)
			{
				if (_tcsicmp(msg.pSender->GetClass(), _T("ListContainerElementUI")) == 0)
				{
					Node* node = (Node*)msg.pSender->GetTag();

					CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
					if (!pFriendsList->CanExpand(node) && (background != NULL))
					{
						FriendListItemInfo friend_info;

						for (std::vector<FriendListItemInfo>::const_iterator citer = friends_.begin(); citer != friends_.end(); ++citer)
						{
							if (_tcsicmp(citer->id, node->data().value) == 0)
							{
								friend_info = *citer;
								break;
							}
						}
						TCHAR szBuf[MAX_PATH] = { 0 };
						if (_tcslen(background->GetBkImage()) > 0)
						{
							_stprintf_s(szBuf, MAX_PATH - 1, _T("bg%d.png"), bk_image_index_);
						}

						ChatDialog* pChatDialog = new ChatDialog(szBuf, background->GetBkColor(), myself_info_, friend_info);
						if (pChatDialog == NULL)
							return;
						pChatDialog->Create(NULL, _T("ChatDialog"), UI_WNDSTYLE_FRAME | WS_POPUP, NULL, 0, 0, 0, 0);
						skin_changed_observer_.AddReceiver(pChatDialog);
						pChatDialog->CenterWindow();
						::ShowWindow(*pChatDialog, SW_SHOW);
					}
				}
			}
		}
	}
}

void MainFrame::OnItemClick(TNotifyUI& msg)
{
	CTabLayoutUI* pTabControl = static_cast<CTabLayoutUI*>(m_PaintManager.FindControl(kMainTabControlName));
	if (pTabControl != NULL)
	{
		if (pTabControl->GetCurSel() == 0)
		{
			CFriendsUI* pFriendsList = static_cast<CFriendsUI*>(m_PaintManager.FindControl(kFriendsListControlName));
			if ((pFriendsList != NULL) && pFriendsList->GetItemIndex(msg.pSender) != -1)
			{
				if (_tcsicmp(msg.pSender->GetClass(), _T("ListContainerElementUI")) == 0)
				{
					Node* node = (Node*)msg.pSender->GetTag();

					if (pFriendsList->CanExpand(node))
					{
						pFriendsList->SetChildVisible(node, !node->data().child_visible_);
					}
				}
			}
		}
		else if (pTabControl->GetCurSel() == 1)
		{
			CGroupsUI* pGroupsList = static_cast<CGroupsUI*>(m_PaintManager.FindControl(kGroupsListControlName));
			if ((pGroupsList != NULL) && pGroupsList->GetItemIndex(msg.pSender) != -1)
			{
				if (_tcsicmp(msg.pSender->GetClass(), _T("ListContainerElementUI")) == 0)
				{
					Node* node = (Node*)msg.pSender->GetTag();

					if (pGroupsList->CanExpand(node))
					{
						pGroupsList->SetChildVisible(node, !node->data().child_visible_);
					}
				}
			}
		}
	}
}

LRESULT MainFrame::OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	BOOL bZoomed = ::IsZoomed(m_hWnd);
	LRESULT lRes = CWindowWnd::HandleMessage(uMsg, wParam, lParam);
	if (::IsZoomed(m_hWnd) != bZoomed)
	{
		if (!bZoomed)
		{
			CControlUI* pControl = static_cast<CControlUI*>(m_PaintManager.FindControl(kMaxButtonControlName));
			if (pControl) pControl->SetVisible(false);
			pControl = static_cast<CControlUI*>(m_PaintManager.FindControl(kRestoreButtonControlName));
			if (pControl) pControl->SetVisible(true);
		}
		else
		{
			CControlUI* pControl = static_cast<CControlUI*>(m_PaintManager.FindControl(kMaxButtonControlName));
			if (pControl) pControl->SetVisible(true);
			pControl = static_cast<CControlUI*>(m_PaintManager.FindControl(kRestoreButtonControlName));
			if (pControl) pControl->SetVisible(false);
		}
	}
	return 0;
}

/******************************************************************************/