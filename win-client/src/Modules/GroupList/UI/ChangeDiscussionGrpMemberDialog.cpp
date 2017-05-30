/******************************************************************************* 
 *  @file      ChangeDiscussionGrpMemberDialog.cpp 2015\1\14 19:42:25 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "ChangeDiscussionGrpMemberDialog.h"
#include "Modules/ITcpClientModule.h"
#include "Modules/IUserListModule.h"
#include "Modules/IGroupListModule.h"
#include "Modules/UI/SearchLayout.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/UI/UIIMList.h"
#include "ProtocolBuffer/IM.Group.pb.h"
#include "network/ImCore.h"

DUI_BEGIN_MESSAGE_MAP(ChangeDiscussionGrpMemberDialog, WindowImplBase)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_WINDOWINIT, OnPrepare)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_ITEMACTIVATE, OnItemActive)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_ITEMCLICK,OnItemClick)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_CLICK,OnClick)
	DUI_ON_MSGTYPE(DUI_MSGTYPE_TEXTCHANGED,OnTextChanged)
	//DUI_ON_MSGTYPE(DUI_MSGTYPE_ITEMDBCLICK,OnItemDBClick)
DUI_END_MESSAGE_MAP()

/******************************************************************************/

// -----------------------------------------------------------------------------
//  MakeGroupWnd: Public, Constructor

ChangeDiscussionGrpMemberDialog::ChangeDiscussionGrpMemberDialog(IN const std::string& sid)
:m_pListCreatFrom(nullptr)
,m_pListGroupMembers(nullptr)
,m_editSearch(nullptr)
,m_searchePanel(nullptr)
, m_currentSessionId(sid)
{

}

// -----------------------------------------------------------------------------
//  MakeGroupWnd: Public, Destructor

ChangeDiscussionGrpMemberDialog::~ChangeDiscussionGrpMemberDialog()
{

}

LPCTSTR ChangeDiscussionGrpMemberDialog::GetWindowClassName() const
{
	return _T("ChangeDiscussionGrpMemberDialog");
}

DuiLib::CDuiString ChangeDiscussionGrpMemberDialog::GetSkinFile()
{
	return  _T("CreateDiscussionGrpDialog\\ChangeDiscussionMemberDialog.xml");
}

DuiLib::CDuiString ChangeDiscussionGrpMemberDialog::GetSkinFolder()
{
	return _T("");
}

CControlUI* ChangeDiscussionGrpMemberDialog::CreateControl(LPCTSTR pstrClass)
{
	if (_tcsicmp(pstrClass, _T("CreatFromList")) == 0)
	{
		return new UIIMList(m_PaintManager);
	}
	return NULL;

}
void ChangeDiscussionGrpMemberDialog::OnFinalMessage(HWND hWnd)
{
	WindowImplBase::OnFinalMessage(hWnd);
	delete this;
}


LRESULT ChangeDiscussionGrpMemberDialog::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (WM_NCLBUTTONDBLCLK != uMsg)//禁用双击标题栏最大化
	{
		return WindowImplBase::HandleMessage(uMsg, wParam, lParam);
	}
	return 0;
}

void ChangeDiscussionGrpMemberDialog::OnPrepare(TNotifyUI& msg)
{
	m_pListCreatFrom = static_cast<UIIMList*>(m_PaintManager.FindControl(_T("CreatFromList")));
	m_pListCreatFrom->SetIitemXmlFile(_T("CreateDiscussionGrpDialog\\ListCreatFromItem.xml"));
	m_pListCreatFrom->SetItemNormalHeight(40);
	m_pListGroupMembers = static_cast<CListUI*>(m_PaintManager.FindControl(_T("GroupMembersList")));
	m_editGroupName = static_cast<CEditUI*>(m_PaintManager.FindControl(_T("editGroupName")));
	m_editSearch = static_cast<CEditUI*>(m_PaintManager.FindControl(_T("editSearch")));
	m_pListSearchResult = static_cast<CListUI*>(m_PaintManager.FindControl(_T("searchResultList")));
	m_searchePanel = static_cast<CVerticalLayoutUI*>(m_PaintManager.FindControl(_T("SearchPanel")));
	m_TextaddNums = static_cast<CTextUI*>(m_PaintManager.FindControl(_T("TextaddNums")));
	const module::DepartmentMap mapDeparments
		= module::getUserListModule()->getAllDepartments();
	for (auto itDepart : mapDeparments)//左侧列表
	{
		module::DepartmentEntity& depart = itDepart.second;
		IMListItemInfo item;
		item.id = util::stringToCString(depart.dId);
		item.folder = true;
		item.empty = false;
		item.nickName = depart.name;
		Node* root_parent = m_pListCreatFrom->AddNode(item, NULL);

		for (std::string uId : depart.members)
		{
			module::UserInfoEntity user;
			if (module::getUserListModule()->getUserInfoBySId(uId, user))
			{
				item.id = util::stringToCString(uId);
				item.folder = false;
				item.avatarPath = util::stringToCString(user.getAvatarPath());
				item.nickName = user.getRealName();
				item.description = _T("");
				m_pListCreatFrom->AddNode(item, root_parent);
			}
		}
		m_pListCreatFrom->SetChildVisible(root_parent, false);
	}
	module::GroupInfoEntity groupInfo;
	if (module::getGroupListModule()->getGroupInfoBySId(m_currentSessionId, groupInfo))
	{
		BOOL  bEnableDeleteBtn = groupInfo.creatorId == module::getSysConfigModule()->userID() ? TRUE : FALSE;
		for (std::string sid:groupInfo.groupMemeberList)
		{
			_AddToGroupMemberList(sid, bEnableDeleteBtn);
		}
		m_editGroupName->SetText(groupInfo.csName);
	}
}

void ChangeDiscussionGrpMemberDialog::OnItemActive(TNotifyUI& msg)
{
	if (0 == _tcsicmp(msg.pSender->GetClass(),_T("ListContainerElementUI")))
	{
		if (0 == _tcsicmp(msg.pSender->GetName(), _T("ListCreatFromItem")))
		{
			Node* node = (Node*)msg.pSender->GetTag();
			if (!m_pListCreatFrom->CanExpand(node))
			{
				CString csId = node->data().sId;
				if (csId.IsEmpty())
					return;
				std::string sId = util::cStringToString(csId);
				
				if (_AddToGroupMemberList(sId))
				{
					_changeResultList(sId, TRUE);
					_refreshUIAddedNum();
				}	
			}
		}
		else if (0 == _tcsicmp(msg.pSender->GetName(), _T("SearchResultItem")))
		{
			CString csId = msg.pSender->GetUserData();
			if (csId.IsEmpty())
				return;
			std::string sId = util::cStringToString(csId);

			if (_AddToGroupMemberList(sId))
			{
				_changeResultList(sId, TRUE);
				_refreshUIAddedNum();
			}
		}
	}
}

void ChangeDiscussionGrpMemberDialog::OnItemClick(TNotifyUI& msg)
{
	CDuiString cname = msg.pSender->GetClass();
	CDuiString name = msg.pSender->GetName();
	if (0 == _tcsicmp(msg.pSender->GetClass(),_T("ListContainerElementUI")))
	{
		if (0 == _tcsicmp(msg.pSender->GetName(),_T("ListCreatFromItem")))
		{
			Node* node = (Node*)msg.pSender->GetTag();

			if (m_pListCreatFrom->CanExpand(node))
			{
				m_pListCreatFrom->SetChildVisible(node, !node->data().child_visible_);
			}
		}
	}
}

void ChangeDiscussionGrpMemberDialog::OnClick(TNotifyUI& msg)
{
	__super::OnClick(msg);
	if (0 == _tcsicmp(msg.pSender->GetName(), _T("okbtn"))
		&& m_pListCreatFrom && m_pListGroupMembers)
	{
		CDuiString groupName = m_editGroupName->GetText();
		if (m_pListGroupMembers->GetCount() >= 2)
		{
			_sendChangeReq();
			Close(IDCANCEL);
		}
		
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("removebtn")))
	{
		CListContainerElementUI* pListElement = reinterpret_cast<CListContainerElementUI*>(msg.pSender->GetTag());
		if (pListElement)
		{
			CString strId = pListElement->GetUserData();
			if (m_pListGroupMembers->Remove(pListElement))
			{
				std::string sid = util::cStringToString(strId);
				_changeResultList(sid, FALSE);//删除群成员
				_refreshUIAddedNum();
			}
		}
	}
}

BOOL ChangeDiscussionGrpMemberDialog::_AddToGroupMemberList(IN std::string sid, IN const BOOL bEnableDelete/* = TRUE*/)
{
	if (sid.empty())
	{
		return FALSE;
	}
	//确认没有重复的项
	for (int n = 0; n < m_pListGroupMembers->GetCount();n++)
	{
		CControlUI* pItem = m_pListGroupMembers->GetItemAt(n);
		if (pItem)
		{
			CString strId = pItem->GetUserData();
			if (!strId.IsEmpty())
			{
				std::string sId = util::cStringToString(strId);
				if (sId == sid)
				{
					return FALSE;
				}
			}
		}
	}
	//插入ITEM
	module::UserInfoEntity userInfo;
	if (!module::getUserListModule()->getUserInfoBySId(sid, userInfo))
	{
		LOG__(DEBG, _T("can't find the userInfo:%s"), util::stringToCString(sid));
		return FALSE;
	}
	CDialogBuilder dlgBuilder;
	CListContainerElementUI* pListElement = (CListContainerElementUI*)dlgBuilder.Create(_T("CreateDiscussionGrpDialog\\ListGroupMembersItem.xml"), (UINT)0, NULL, &m_PaintManager);
	if (!pListElement)
	{
		LOG__(ERR, _T("群item创建失败"));
		return FALSE;
	}
	CControlUI* pLogo = static_cast<CControlUI*>(pListElement->FindSubControl(_T("AvatarInfo")));
	if (!pLogo)
	{
		return FALSE;
	}
	pLogo->SetBkImage(util::stringToCString(userInfo.getAvatarPath()));

	CLabelUI* pNameLable = static_cast<CLabelUI*>(pListElement->FindSubControl(_T("nickname")));
	if (!pNameLable)
	{
		return FALSE;
	}
	pNameLable->SetText(userInfo.getRealName());

	CButtonUI* pRemoveBtn = static_cast<CButtonUI*>(pListElement->FindSubControl(_T("removebtn")));
	if (pRemoveBtn)
	{
		//点击删除按钮的时候根据这个来判断是哪个项
		pRemoveBtn->SetTag(UINT_PTR(pListElement));
		if (!bEnableDelete)
		{
			pRemoveBtn->SetVisible(FALSE);
		}
	}

	if (module::getSysConfigModule()->userID() == userInfo.sId)//自己不能删除
	{
		pRemoveBtn->SetVisible(false);
	}
	
	pListElement->SetUserData(util::stringToCString(userInfo.sId));

	m_pListGroupMembers->Add(pListElement);

	return TRUE;
}

void ChangeDiscussionGrpMemberDialog::OnTextChanged(TNotifyUI& msg)
{
	if (msg.pSender == m_editSearch)
	{
		m_pListSearchResult->RemoveAll();

		CDuiString inputText = m_editSearch->GetText();
		if (inputText.IsEmpty())
		{
			m_pListSearchResult->SetVisible(false);
			m_pListCreatFrom->SetVisible(true);
		}
		else
		{
			m_pListCreatFrom->SetVisible(false);
			m_pListSearchResult->SetVisible(true);

			module::UserInfoEntityVec userList;
			module::getUserListModule()->getSearchUserNameListByShortName(inputText.GetData(), userList);
			_updateSearchResultList(userList);
		}
	}
}

void ChangeDiscussionGrpMemberDialog::_updateSearchResultList(IN const std::vector<std::string>& nameList)
{
	if (nameList.empty())
	{
		return;
	}
	for (std::string sid : nameList)
	{
		module::UserInfoEntity userInfo;
		if (!module::getUserListModule()->getUserInfoBySId(sid, userInfo))
		{
			LOG__(ERR, _T("can't find the userInfo:%s"), util::stringToCString(sid));
			return;
		}
		CDialogBuilder dlgBuilder;
		CListContainerElementUI* pListElement = (CListContainerElementUI*)dlgBuilder.Create(_T("CreateDiscussionGrpDialog\\ListGroupMembersItem.xml"), (UINT)0, NULL, &m_PaintManager);
		if (!pListElement)
		{
			LOG__(ERR, _T("Creat group item failed!"));
			return;
		}
		pListElement->SetName(_T("SearchResultItem"));
		CControlUI* pLogo = static_cast<CControlUI*>(pListElement->FindSubControl(_T("AvatarInfo")));
		if (!pLogo)
		{
			return;
		}
		pLogo->SetBkImage(util::stringToCString(userInfo.getAvatarPath()));

		CLabelUI* pNameLable = static_cast<CLabelUI*>(pListElement->FindSubControl(_T("nickname")));
		if (!pNameLable)
		{
			return;
		}
		pNameLable->SetText(userInfo.getRealName());

		CButtonUI* pRemoveBtn = static_cast<CButtonUI*>(pListElement->FindSubControl(_T("removebtn")));
		if (pRemoveBtn)
		{
			pRemoveBtn->SetVisible(false);
		}

		pListElement->SetUserData(util::stringToCString(userInfo.sId));

		m_pListSearchResult->Add(pListElement);
	}
}

void ChangeDiscussionGrpMemberDialog::_refreshUIAddedNum()
{
	if (m_TextaddNums)
	{
		CString strFormat;
		strFormat.Format(_T("(%d/50)"), m_pListGroupMembers->GetCount());
		m_TextaddNums->SetText(strFormat);
	}
}

void ChangeDiscussionGrpMemberDialog::_changeResultList(IN const std::string& sid, IN const BOOL bAdded)
{
	if (bAdded)//增加成员
	{
		auto iter = std::find_if(m_deleteUsers.begin(),m_deleteUsers.end(),
			[=](std::string id){
			return id == sid;
		});
		if (iter == m_deleteUsers.end())
		{
			m_addedUsers.push_back(sid);
		}
		else
		{
			m_deleteUsers.erase(iter);
		}
	}
	else//删除成员
	{		
		auto iter = std::find_if(m_addedUsers.begin(), m_addedUsers.end(),
			[=](std::string id){
			return id == sid;
		});
		if (iter == m_addedUsers.end())
		{
			m_deleteUsers.push_back(sid);
		}
		else
		{
			m_addedUsers.erase(iter);
		}
	}
}

void ChangeDiscussionGrpMemberDialog::_sendChangeReq()
{
	std::string oSid = module::getGroupListModule()->getOriginalSId(m_currentSessionId);
	if (!m_addedUsers.empty())
	{
		IM::Group::IMGroupChangeMemberReq imGroupChangeMemberReq;
		imGroupChangeMemberReq.set_user_id(module::getSysConfigModule()->userId());
		imGroupChangeMemberReq.set_change_type(IM::BaseDefine::GroupModifyType::GROUP_MODIFY_TYPE_ADD);
		imGroupChangeMemberReq.set_group_id(util::stringToInt32(oSid));
		for (std::string sid:m_addedUsers)
		{
			imGroupChangeMemberReq.add_member_id_list(util::stringToInt32(sid));
		}
		LOG__(APP, _T("IMGroupChangeMemberReq - add,groupID = %s,size = %d")
			, util::stringToCString(m_currentSessionId),m_addedUsers.size());
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_GROUP
			, IM::BaseDefine::GroupCmdID::CID_GROUP_CHANGE_MEMBER_REQUEST
			, &imGroupChangeMemberReq);
	}
	if (!m_deleteUsers.empty())
	{
		IM::Group::IMGroupChangeMemberReq imGroupChangeMemberReq;
		imGroupChangeMemberReq.set_user_id(module::getSysConfigModule()->userId());
		imGroupChangeMemberReq.set_change_type(IM::BaseDefine::GroupModifyType::GROUP_MODIFY_TYPE_DEL);
		imGroupChangeMemberReq.set_group_id(util::stringToInt32(oSid));
		for (std::string sid : m_deleteUsers)
		{
			imGroupChangeMemberReq.add_member_id_list(util::stringToInt32(sid));
		}
		LOG__(APP, _T("IMGroupChangeMemberReq - del,groupID = %s,size = %d")
			, util::stringToCString(m_currentSessionId), m_deleteUsers.size());
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_GROUP
			, IM::BaseDefine::GroupCmdID::CID_GROUP_CHANGE_MEMBER_REQUEST
			, &imGroupChangeMemberReq);
	}
}

/******************************************************************************/