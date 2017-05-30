/******************************************************************************* 
 *  @file      SearchLayout.cpp 2014\8\11 16:31:05 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/UI/SearchLayout.h"
#include "Modules/IUserListModule.h"
#include "Modules/IGroupListModule.h"
#include "Modules/ISessionModule.h"
#include "Modules/UI/UIGroupsTreelist.h"
#include "utility/Multilingual.h"
/******************************************************************************/

// -----------------------------------------------------------------------------
//  SearchLayout: Public, Constructor

SearchLayout::SearchLayout()
:m_btnSearch(nullptr)
, m_btnCancel(nullptr)
, m_edit(nullptr)
, m_SearchResultList(nullptr)
, m_layoutSearchResult(nullptr)
{

}

// -----------------------------------------------------------------------------
//  SearchLayout: Public, Destructor

SearchLayout::~SearchLayout()
{
	m_pManager->RemoveNotifier(this);
}

LPVOID SearchLayout::GetInterface(LPCTSTR pstrName)
{
	if (_tcscmp(pstrName, _T("SearchLayout")) == 0) return static_cast<SearchLayout*>(this);
	return __super::GetInterface(pstrName);
}

LPCTSTR SearchLayout::GetClass() const
{
	return _T("SearchLayout");
}

void SearchLayout::DoInit()
{
	m_pManager->AddNotifier(this);

	m_btnSearch = static_cast<CButtonUI*>(m_pManager->FindSubControlByName(this, _T("searchbtn")));
	m_btnCancel = static_cast<CButtonUI*>(m_pManager->FindSubControlByName(this, _T("cancelbtn")));
	m_edit = static_cast<CEditUI*>(m_pManager->FindSubControlByName(this, _T("editSearch")));
	m_SearchResultList = static_cast<CGroupsTreelistUI*>(m_pManager->FindSubControlByName(this, _T("searchResultList")));
	m_layoutSearchResult = m_pManager->FindSubControlByName(this, _T("searchResultLayout"));
}

void SearchLayout::Notify(TNotifyUI& msg)
{
	if (msg.pSender == m_edit)
	{
		if (msg.sType == DUI_MSGTYPE_TEXTCHANGED && m_SearchResultList)
		{
			m_SearchResultList->RemoveAll();
			CDuiString inputText = m_edit->GetText();
			if (inputText.IsEmpty())
			{
				SetFixedHeight(27);
				m_layoutSearchResult->SetVisible(false);
				m_btnSearch->SetVisible(true);
				m_btnCancel->SetVisible(false);
			}
			else
			{
				m_btnSearch->SetVisible(false);
				m_btnCancel->SetVisible(true);
				m_layoutSearchResult->SetVisible(true);
				module::UserInfoEntityVec userList;
				module::getUserListModule()->getSearchUserNameListByShortName(inputText.GetData(), userList);

				//搜索彩蛋,随机获取一个异性
				if (inputText == _T("-random"))
				{
					std::string sid = module::getUserListModule()->randomGetUser();
					userList.push_back(sid);
				}

				_updateSearchResultList(userList,1);//搜索结果：联系人

				module::GroupVec gidList;
				module::getGroupListModule()->GetSearchGroupNameListByShortName(inputText.GetData(), gidList);
				_updateSearchResultList(gidList,2);//搜索结果：讨论组，群

				_updateSearchResultListForDepartMent(inputText.GetData());//搜索结果：部门

				if (0 != GetHeight())
				{
					m_SearchResultList->SetVisible(true);
					SetFixedHeight(0);
				}
			}
		}
		else if (msg.sType == DUI_MSGTYPE_RETURN && m_SearchResultList)
		{
			std::string sId;
			if (m_SearchResultList->GetFirstChildItemSId(sId))
			{
				module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_OPENNEWSESSION, sId);
				//恢复原列表
				m_edit->SetText(_T(""));
				m_pManager->SendNotify(m_edit, DUI_MSGTYPE_TEXTCHANGED, 0, 0);
			}
		}
	}
	else if (msg.pSender == m_btnSearch && msg.sType == DUI_MSGTYPE_CLICK)
	{
	}
	else if (msg.pSender == m_btnCancel && msg.sType == DUI_MSGTYPE_CLICK)
	{
		m_edit->SetText(_T(""));
		m_pManager->SendNotify(m_edit,DUI_MSGTYPE_TEXTCHANGED,0,0);
	}
	else if (msg.sType == DUI_MSGTYPE_ITEMACTIVATE
		&&m_SearchResultList
		&& -1 != m_SearchResultList->GetItemIndex(msg.pSender)
		&& 0 == _tcsicmp(msg.pSender->GetClass(), _T("ListContainerElementUI")))
	{
		Node* node = (Node*)msg.pSender->GetTag();
		if (!m_SearchResultList->CanExpand(node)&& node)
		{
			std::string sid = util::cStringToString(CString(node->data().sId));
			module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_OPENNEWSESSION, sid);//通知主窗口创建会话
		}
	}
	else if (msg.sType == DUI_MSGTYPE_ITEMCLICK
		&&m_SearchResultList
		&& -1 != m_SearchResultList->GetItemIndex(msg.pSender)
		&& 0 == _tcsicmp(msg.pSender->GetClass(), _T("ListContainerElementUI")))
	{
		Node* node = (Node*)msg.pSender->GetTag();

		if (m_SearchResultList->CanExpand(node))
		{
			m_SearchResultList->SetChildVisible(node, !node->data().child_visible_);
		}
	}
}

void SearchLayout::_updateSearchResultList(IN const std::vector<std::string>& nameList, int IdType)
{
	if (nameList.empty())
	{
		return;
	}
	GroupsListItemInfo item;

	item.folder = true;
	item.empty = false;
	//item.description = _T("搜索结果1");
	if (1 == IdType)
	{
		item.nickName = util::getMultilingual()->getStringById(_T("STRID_SEARCHLAYOUT_GROUP_USERSITEM")); 
	}
	else 
	{
		item.nickName = util::getMultilingual()->getStringById(_T("STRID_SEARCHLAYOUT_GROUP_GROUPITEM"));
	}
	Node* root_parent = m_SearchResultList->AddNode(item, NULL);

	item.folder = false;
	for (std::string sid : nameList)
	{
		if (1 == IdType)
		{
			module::UserInfoEntity userInfo;
			if (module::getUserListModule()->getUserInfoBySId(sid, userInfo))
			{
				item.id = util::stringToCString(userInfo.sId);
				item.nickName = userInfo.getRealName();
				item.avatarPath = util::stringToCString(userInfo.getAvatarPath());
				m_SearchResultList->AddNode(item, root_parent);
			}
		}
		else if (2 == IdType)
		{
			module::GroupInfoEntity groupInfo;
			if (module::getGroupListModule()->getGroupInfoBySId(sid, groupInfo))
			{
				item.id = util::stringToCString(groupInfo.gId);
				item.nickName = groupInfo.csName;
				item.avatarPath = util::stringToCString(groupInfo.getAvatarPath());
				m_SearchResultList->AddNode(item, root_parent);
			}
		}
		
	}
	m_SearchResultList->SetChildVisible(root_parent, true);
}

void SearchLayout::_updateSearchResultListForDepartMent(IN const CString strSearch)
{
	module::DepartmentMap  departmentMap = module::getUserListModule()->getAllDepartments();
	if (departmentMap.empty())
	{
		return;
	}
	std::vector<std::string> departmentList;
	module::getUserListModule()->getSearchDepartmentsByShortName(strSearch, departmentList);
	for (std::string groupId:departmentList)
	{
		module::DepartmentEntity  departmentEntity = departmentMap[groupId];
		GroupsListItemInfo item;
		item.folder = true;
		item.empty = false;
		item.nickName = departmentEntity.name;
		Node* root_parent = m_SearchResultList->AddNode(item, NULL);

		item.folder = false;
		std::list<std::string>&	members = departmentMap[groupId].members;
		for (std::string userId:members)
		{
			module::UserInfoEntity userInfo;
			if (module::getUserListModule()->getUserInfoBySId(userId,userInfo))
			{
				item.id = util::stringToCString(userInfo.sId);
				item.nickName = userInfo.getRealName();
				item.avatarPath = util::stringToCString(userInfo.getAvatarPath());
				m_SearchResultList->AddNode(item, root_parent);
			}
		}
		//m_SearchResultList->SetChildVisible(root_parent, false);
	}
}

/******************************************************************************/