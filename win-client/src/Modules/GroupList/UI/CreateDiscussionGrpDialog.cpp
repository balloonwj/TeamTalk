/******************************************************************************* 
 *  @file      CreateDiscussionGrpDialog.cpp 2015\1\14 19:37:01 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "CreateDiscussionGrpDialog.h"
#include "Modules/ITcpClientModule.h"
#include "Modules/IUserListModule.h"
#include "Modules/UI/SearchLayout.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/UI/UIIMList.h"
#include "utility/Multilingual.h"
#include "ProtocolBuffer/IM.Group.pb.h"
#include "network/ImCore.h"

DUI_BEGIN_MESSAGE_MAP(CreateDiscussionGrpDialog, WindowImplBase)
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

CreateDiscussionGrpDialog::CreateDiscussionGrpDialog(std::string sid)
:m_pListCreatFrom(nullptr)
,m_pListGroupMembers(nullptr)
,m_editSearch(nullptr)
,m_searchePanel(nullptr)
, m_currentSessionId(sid)
{

}

// -----------------------------------------------------------------------------
//  MakeGroupWnd: Public, Destructor

CreateDiscussionGrpDialog::~CreateDiscussionGrpDialog()
{

}

LPCTSTR CreateDiscussionGrpDialog::GetWindowClassName() const
{
	return _T("CreateDiscussionGrpDialog");
}

DuiLib::CDuiString CreateDiscussionGrpDialog::GetSkinFile()
{
	return  _T("CreateDiscussionGrpDialog\\CreateDiscussionGrpDialog.xml");
}

DuiLib::CDuiString CreateDiscussionGrpDialog::GetSkinFolder()
{
	return _T("");
}

CControlUI* CreateDiscussionGrpDialog::CreateControl(LPCTSTR pstrClass)
{
	if (_tcsicmp(pstrClass, _T("CreatFromList")) == 0)
	{
		return new UIIMList(m_PaintManager);
	}
	return NULL;

}
void CreateDiscussionGrpDialog::OnFinalMessage(HWND hWnd)
{
	WindowImplBase::OnFinalMessage(hWnd);
	delete this;
}


LRESULT CreateDiscussionGrpDialog::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (WM_NCLBUTTONDBLCLK != uMsg)//禁用双击标题栏最大化
	{
		return WindowImplBase::HandleMessage(uMsg, wParam, lParam);
	}
	return 0;
}

void CreateDiscussionGrpDialog::OnPrepare(TNotifyUI& msg)
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
	m_TextErrorTip = static_cast<CTextUI*>(m_PaintManager.FindControl(_T("errorTip")));
	if (m_TextErrorTip)
	{
		m_TextErrorTip->SetText(_T(""));
	}
	const module::DepartmentMap mapDeparments
		= module::getUserListModule()->getAllDepartments();
	for (auto itDepart : mapDeparments)
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

	std::string mySid = module::getSysConfigModule()->userID();
	_AddToGroupMemberList(mySid);
	_AddToGroupMemberList(m_currentSessionId);
}

void CreateDiscussionGrpDialog::OnItemActive(TNotifyUI& msg)
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
				
				_AddToGroupMemberList(sId);
				_refreshUIAddedNum();
			}
		}
		else if (0 == _tcsicmp(msg.pSender->GetName(), _T("SearchResultItem")))
		{
			CString csId = msg.pSender->GetUserData();
			if (csId.IsEmpty())
				return;
			std::string sId = util::cStringToString(csId);

			_AddToGroupMemberList(sId);
			_refreshUIAddedNum();
		}
	}
}

void CreateDiscussionGrpDialog::OnItemClick(TNotifyUI& msg)
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

void CreateDiscussionGrpDialog::OnClick(TNotifyUI& msg)
{
	__super::OnClick(msg);
	if (0 == _tcsicmp(msg.pSender->GetName(), _T("okbtn"))
		&& m_pListCreatFrom && m_pListGroupMembers)
	{
		CDuiString groupName = m_editGroupName->GetText();
		if (groupName.IsEmpty())
		{
			m_TextErrorTip->SetText(util::getMultilingual()->getStringById(
				_T("STRID_CREATEDISCUSSIONGRPDIALOG_ERROR_EMPTY_GROUPNAME")));
			return; 
		}
		if (m_pListGroupMembers->GetCount() < 2)
		{
			m_TextErrorTip->SetText(util::getMultilingual()->getStringById(
				_T("STRID_CREATEDISCUSSIONGRPDIALOG_ERROR_COUNT")));
			return;
		}

		std::vector<std::string> vecMembers;
		for (int n = 0; n < m_pListGroupMembers->GetCount(); ++n)
		{
			CControlUI* pItem = m_pListGroupMembers->GetItemAt(n);
			if (pItem)
			{
				CString strID = pItem->GetUserData();
				vecMembers.push_back(util::cStringToString(strID));
			}
		}
		std::string strGroupName = util::cStringToString(CString(groupName));
		imcore::IMLibCoreStartOperationWithLambda(		//创建讨论组
			[=]()
		{

			IM::Group::IMGroupCreateReq imGroupCreateReq;
			imGroupCreateReq.set_user_id(module::getSysConfigModule()->userId());
			imGroupCreateReq.set_group_type(IM::BaseDefine::GroupType::GROUP_TYPE_TMP);
			imGroupCreateReq.set_group_name(strGroupName);
			imGroupCreateReq.set_group_avatar(std::string(""));//群头像先不传
			for (auto sid : vecMembers)
			{
				imGroupCreateReq.add_member_id_list(util::stringToInt32(sid));
			}
			module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_GROUP
				, IM::BaseDefine::GroupCmdID::CID_GROUP_CREATE_REQUEST
				, &imGroupCreateReq);
		}
		);
		Close(IDCANCEL);			
	}
	else if (0 == _tcsicmp(msg.pSender->GetName(), _T("removebtn")))
	{
		CListContainerElementUI* pListElement = reinterpret_cast<CListContainerElementUI*>(msg.pSender->GetTag());
		if (pListElement)
		{
			m_pListGroupMembers->Remove(pListElement);

			_refreshUIAddedNum();
		}
	}
}

void CreateDiscussionGrpDialog::_AddToGroupMemberList(std::string sid)
{
	if (sid.empty())
	{
		return;
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
					return;
				}
			}
		}
	}
	//插入ITEM
	module::UserInfoEntity userInfo;
	if (!module::getUserListModule()->getUserInfoBySId(sid, userInfo))
	{
		LOG__(DEBG, _T("can't find the userInfo:%s"), util::stringToCString(sid));
		return;
	}
	CDialogBuilder dlgBuilder;
	CListContainerElementUI* pListElement = (CListContainerElementUI*)dlgBuilder.Create(_T("CreateDiscussionGrpDialog\\ListGroupMembersItem.xml"), (UINT)0, NULL, &m_PaintManager);
	if (!pListElement)
	{
		LOG__(ERR, _T("群item创建失败"));
		return;
	}
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
		//点击删除按钮的时候根据这个来判断是哪个项
		pRemoveBtn->SetTag(UINT_PTR(pListElement));
	}

	if (module::getSysConfigModule()->userID() == userInfo.sId)//自己不能删除
	{
		pRemoveBtn->SetVisible(false);
	}
	
	pListElement->SetUserData(util::stringToCString(userInfo.sId));

	m_pListGroupMembers->Add(pListElement);

}

void CreateDiscussionGrpDialog::OnTextChanged(TNotifyUI& msg)
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

void CreateDiscussionGrpDialog::_updateSearchResultList(IN const std::vector<std::string>& nameList)
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
			LOG__(ERR, _T("群item创建失败"));
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

void CreateDiscussionGrpDialog::_refreshUIAddedNum()
{
	if (m_TextaddNums)
	{
		CString strFormat = util::getMultilingual()->getStringById(_T("STRID_CREATEDISCUSSIONGRPDIALOG_TOP_COUNT"));
		CString strContent;
		strContent.Format(strFormat, m_pListGroupMembers->GetCount());
		m_TextaddNums->SetText(strContent);
	}
}


/******************************************************************************/