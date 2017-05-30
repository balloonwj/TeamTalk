#include "stdafx.h"
#include <windows.h>
#if !defined(UNDER_CE)
#include <shellapi.h>
#endif

#include "UIGroups.hpp"
#include "UIUserList.h"
#include "main_frame.hpp"
#include "color_skin.hpp"
#include "chat_dialog.hpp"
#include "UIMenu.h"
#include "TTLogic/ILogic.h"
#include "Modules/ILoginModule.h"
#include "Modules/IMiscModule.h"
#include "Modules/IHitoryMsgModule.h"
#include "UI/FloatWnd.h"

MainFrame::MainFrame()
: bk_image_index_(0)
{}

MainFrame::~MainFrame()
{
	PostQuitMessage(0);
}

LPCTSTR MainFrame::GetWindowClassName() const
{
	return _T("TXGuiFoundation");
}

CControlUI* MainFrame::CreateControl(LPCTSTR pstrClass)
{
	if (_tcsicmp(pstrClass, _T("FriendList")) == 0)
	{
		return new CFriendsUI(m_PaintManager);
	}
	else if (_tcsicmp(pstrClass, _T("GroupList")) == 0)
	{
		return new CGroupsUI(m_PaintManager);
	}
	else if (_tcsicmp(pstrClass, _T("RecentlyList")) == 0)
	{
		return new UIUserList(m_PaintManager);
	}

	return NULL;
}

void MainFrame::OnFinalMessage(HWND hWnd)
{
	WindowImplBase::OnFinalMessage(hWnd);
	delete this;
}

CDuiString MainFrame::GetSkinFile()
{
	return _T("main_frame.xml");
}

CDuiString MainFrame::GetSkinFolder()
{
	return  _T("..\\gui\\");
}

LRESULT MainFrame::OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT MainFrame::ResponseDefaultKeyEvent(WPARAM wParam)
{
	if (wParam == VK_RETURN)
	{
		return FALSE;
	}
	else if (wParam == VK_ESCAPE)
	{
		return TRUE;
	}
	return FALSE;
}

void MainFrame::OnExit(TNotifyUI& msg)
{
	Close();
}

void MainFrame::InitWindow()
{
	logic::GetLogic()->addObserver(this,MODULE_ID_LOGIN
		, fastdelegate::MakeDelegate(this, &MainFrame::OnLoginModuleEvent));

	module::getLoginModule()->test();

	module::getMiscModule()->getUserDataDir();

	module::getHitoryMsgModule()->openDB();
}

DWORD MainFrame::GetBkColor()
{
	CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
	if (background != NULL)
		return background->GetBkColor();

	return 0;
}

void MainFrame::SetBkColor(DWORD dwBackColor)
{
	CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
	if (background != NULL)
	{
		background->SetBkImage(_T(""));
		background->SetBkColor(dwBackColor);
		background->NeedUpdate();

		SkinChangedParam param;
		param.bkcolor = background->GetBkColor();
		param.bgimage = background->GetBkImage();
		skin_changed_observer_.Broadcast(param);
	}
}

void MainFrame::UpdateFriendsList()
{
	CFriendsUI* pFriendsList = static_cast<CFriendsUI*>(m_PaintManager.FindControl(kFriendsListControlName));
	if (pFriendsList != NULL)
	{
		if (!friends_.empty())
			friends_.clear();
		if (pFriendsList->GetCount() > 0)
			pFriendsList->RemoveAll();

		FriendListItemInfo item;

		item.id = _T("0");
		item.folder = true;
		item.empty = false;
		item.nick_name = _T("SWAT");

		Node* root_parent = pFriendsList->AddNode(item, NULL);
		friends_.push_back(item);

		item.id = _T("1");
		item.folder = false;		
		item.logo = _T("man_big.png");
		item.nick_name = _T("大佛");
		item.description = _T("dafo@mogujie.com");

		myself_info_ = item;

		pFriendsList->AddNode(item, root_parent);
		friends_.push_back(item);

		item.id = _T("2");
		item.folder = false;
		item.logo = _T("default.png");
		item.nick_name = _T("快刀");
		item.description = _T("kuaidao@mogujie.com");
		pFriendsList->AddNode(item, root_parent);
		friends_.push_back(item);

        item.id = _T("2");
        item.folder = false;
        item.logo = _T("default.png");
        item.nick_name = _T("子烨");
        item.description = _T("万恶的地主");
        pFriendsList->AddNode(item, root_parent);
        friends_.push_back(item);

        for( int i = 0; i < 100; ++i )
        {
            item.id = _T("2");
            item.folder = false;
            item.logo = _T("default.png");
            item.nick_name = _T("duilib");
            item.description = _T("www.duilib.com");
            pFriendsList->AddNode(item, root_parent);
            friends_.push_back(item);
        }

		item.id = _T("3");
		item.folder = true;
		item.empty = false;
		item.nick_name = _T("企业好友");
		Node* root_parent2 = pFriendsList->AddNode(item, NULL);
		friends_.push_back(item);

		item.id = _T("4");
		item.folder = false;
		item.logo = _T("icon_home.png");
		item.nick_name = _T("腾讯企业QQ的官方展示号");
		item.description = _T("");
		pFriendsList->AddNode(item, root_parent2);
		friends_.push_back(item);

		item.id = _T("5");
		item.folder = true;
		item.empty = false;
		item.nick_name = _T("陌生人");
		Node* root_parent3 = pFriendsList->AddNode(item, NULL);
		friends_.push_back(item);


		item.id = _T("6");
		item.folder = true;
		item.empty = false;
		item.nick_name = _T("黑名单");
		Node* root_parent4 = pFriendsList->AddNode(item, NULL);
		friends_.push_back(item);
	}
}

void MainFrame::UpdateGroupsList()
{
	CGroupsUI* pGroupsList = static_cast<CGroupsUI*>(m_PaintManager.FindControl(kGroupsListControlName));
	if (pGroupsList != NULL)
	{
		if (pGroupsList->GetCount() > 0)
			pGroupsList->RemoveAll();

		GroupsListItemInfo item;

		item.folder = true;
		item.empty = false;
		item.nick_name = _T("我的QQ群");

		Node* root_parent = pGroupsList->AddNode(item, NULL);

		item.folder = false;
		item.logo = _T("duilib.png");
		item.nick_name = _T("Duilib官方交流群");
		item.description = _T("153787916");
		pGroupsList->AddNode(item, root_parent);

		item.folder = false;
		item.logo = _T("groups.png");
		item.nick_name = _T("Duilib官方交流群2");
		item.description = _T("79145400");
		pGroupsList->AddNode(item, root_parent);
	}
}

void MainFrame::UpdateRecentlyList()
{
	UIUserList* pRecentlyList = static_cast<UIUserList*>(m_PaintManager.FindControl(kRecentlyListControlName));
	if (pRecentlyList != NULL)
	{
		if (pRecentlyList->GetCount() > 0)
			pRecentlyList->RemoveAll();

		UserListItemInfo item;

		srand((UINT)time(0));
		item.Time = rand() % 200;
		item.folder = false;
		item.empty = false;
		item.logo = _T("duilib.png");
		item.nick_name = _T("子烨");
		item.description.Format(_T("%d"),item.Time);

		pRecentlyList->AddNode(item, NULL);


		item.Time = rand() % 200;
		item.logo = _T("duilib.png");
		item.nick_name = _T("麦克");
		//item.description = _T("大帅哥");
		item.description.Format(_T("%d"), item.Time);
		pRecentlyList->AddNode(item, NULL);


		item.Time = rand() % 200;
		item.logo = _T("duilib.png");
		item.nick_name = _T("四叶");
		//item.description = _T("闷骚的少年");
		item.description.Format(_T("%d"), item.Time);
		pRecentlyList->AddNode(item, NULL, 2);

		item.Time = rand() % 200;
		item.logo = _T("duilib.png");
		item.nick_name = _T("独嘉");
		//item.description = _T("风一般的少年");
		item.description.Format(_T("%d"), item.Time);
		pRecentlyList->AddNode(item, NULL);

		item.Time = rand() % 200;
		item.logo = _T("duilib.png");
		item.nick_name = _T("四叶");
		//item.description = _T("闷骚的少年");
		item.description.Format(_T("%d"), item.Time);
		pRecentlyList->AddNode(item, NULL);

		item.Time = rand() % 200;
		item.logo = _T("duilib.png");
		item.nick_name = _T("千凡");
		//item.description = _T("养猫的孩纸");
		item.description.Format(_T("%d"), item.Time);
		pRecentlyList->AddNode(item, NULL,3);

		pRecentlyList->sort();

		// List控件中添加数据
		// 注意：添加List列表内容，必须先Add(pListElement)添加元素，再SetText进行元素值的设置
		//for (int i = 0; i < 10; i++)
		//{
		//	CListTextElementUI* pListElement = new CListTextElementUI;
		//	pListElement->SetTag(i);
		//	pRecentlyList->Add(pListElement);

		//	pListElement->SetText(0, _T("WHO1753"));
		//	pListElement->SetText(1, _T("程序设计"));
		//	pListElement->SetText(2, _T("100"));
		//}

		//UserListItemInfo item;
		//item.folder = true;
		//item.empty = false;
		//item.nick_name = _T("我的QQ群");

		//pRecentlyList->addItem(item);
	}
}

void MainFrame::OnPrepare(TNotifyUI& msg)
{
	CControlUI* background = m_PaintManager.FindControl(kBackgroundControlName);
	if (background != NULL)
	{
		TCHAR szBuf[MAX_PATH] = {0};
		_stprintf_s(szBuf, MAX_PATH - 1, _T("file='bg%d.png' corner='600,200,1,1'"), bk_image_index_);
		background->SetBkImage(szBuf);
	}

	UpdateFriendsList();

	UpdateGroupsList();

	UpdateRecentlyList();
}

LRESULT MainFrame::HandleCustomMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	return 0;
}

void MainFrame::ShowSearchResList()
{
	CControlUI* MainListPanel = m_PaintManager.FindControl(_T("MainListPanel"));
	CControlUI* SearchUserResPanel = m_PaintManager.FindControl(_T("SearchUserResPanel"));

	if (MainListPanel)
	{
		MainListPanel->SetVisible(false);
	}
	if (SearchUserResPanel)
	{
		SearchUserResPanel->SetVisible(true);
	}
	CFriendsUI* pSearchUserList = static_cast<CFriendsUI*>(m_PaintManager.FindControl(_T("SearchUserList")));
	if (pSearchUserList != NULL)
	{

		if (!friends_.empty())
			friends_.clear();
		if (pSearchUserList->GetCount() > 0)
			pSearchUserList->RemoveAll();

		FriendListItemInfo item;

		item.id = _T("0");
		item.folder = true;
		item.empty = false;
		item.nick_name = _T("SWAT");

		Node* root_parent = pSearchUserList->AddNode(item, NULL);
		friends_.push_back(item);

		item.id = _T("1");
		item.folder = false;
		item.logo = _T("man_big.png");
		item.nick_name = _T("大佛");
		item.description = _T("dafo@mogujie.com");

		myself_info_ = item;

		pSearchUserList->AddNode(item, root_parent);
		friends_.push_back(item);

		item.id = _T("2");
		item.folder = false;
		item.logo = _T("default.png");
		item.nick_name = _T("快刀");
		item.description = _T("kuaidao@mogujie.com");
		pSearchUserList->AddNode(item, root_parent);
		friends_.push_back(item);

		item.id = _T("2");
		item.folder = false;
		item.logo = _T("default.png");
		item.nick_name = _T("子烨");
		item.description = _T("万恶的地主");
		pSearchUserList->AddNode(item, root_parent);
		friends_.push_back(item);
	}
}

//UILIB_RESOURCETYPE MainFrame::GetResourceType() const
//{
//	return UILIB_ZIPRESOURCE;
//	//return UILIB_FILE;
//}

//LPCTSTR MainFrame::GetResourceID() const
//{
//	return MAKEINTRESOURCE(500);
//}
