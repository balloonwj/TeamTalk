 /*******************************************************************************
 *  @file      MainListLayout.h 2014\8\4 10:15:42 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef LISTPANEL_00907A2F_35FC_48EE_B385_4C5DE6018C6A_H__
#define LISTPANEL_00907A2F_35FC_48EE_B385_4C5DE6018C6A_H__

#include "GlobalDefine.h"
#include "DuiLib/UIlib.h"
/******************************************************************************/
using namespace DuiLib;
class CEAUserTreelistUI;
class CGroupsTreelistUI;
class CUIRecentSessionList;
class UIIMList;
class Node;

/**
 * The class <code>TestButton</code> 
 *
 */
class MainListLayout :public CHorizontalLayoutUI,public INotifyUI
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    MainListLayout();
    /**
     * Destructor
     */
    ~MainListLayout();
    //@}
public:
	virtual LPVOID GetInterface(LPCTSTR pstrName);
	virtual LPCTSTR GetClass() const;

	virtual void DoInit();
	virtual void Notify(TNotifyUI& msg);

	/**@name MKO*/
	//@{
public:
	void MKOForUserlistModuleCallback(const std::string& keyId, MKO_TUPLE_PARAM mkoParam);
	void MKOForGrouplistModuleCallback(const std::string& keyId, MKO_TUPLE_PARAM mkoParam);
	void MKOForSessionModuleCallback(const std::string& keyId, MKO_TUPLE_PARAM mkoParam);
	void MKOForSysConfigModuleCallback(const std::string& keyId, MKO_TUPLE_PARAM mkoParam);
	void MKOForFileTransferModuleCallback(const std::string& keyId, MKO_TUPLE_PARAM mkoParam);
	//@}

private:
	void _CreatSessionDialog(IN UIIMList* pList,IN CControlUI* pMsgSender);
	void _CreateMenu(IN const TNotifyUI& msg);
	void _LoadAllDepartment();

	void _AddGroupList();
	void _AddDiscussGroupList();
	void _AddRecentSessionListToUI();
	void _NewGroupAdded(std::string& gId);
	void _NewGroupsUpdate(std::shared_ptr<void> pGroupIDs);
	void _GroupMembersChanged(std::shared_ptr<void> pMembers);
	void _NewMsgUpdate(std::string& sId);			//收到新消息更新
	void _CreatNewDiscussGroupRes(std::string& sId);//创建新的讨论组

	void _UpdateRecentSessionItem(IN const std::string& sessionId, IN const UInt32 sessionType);
	void _UpdateGroupList(IN const std::string& groupID);
	void _MySelfKickedFromDiscusGrp(IN const std::string& groupID);
private:
	CTabLayoutUI*			m_Tab;
	CEAUserTreelistUI*		m_EAuserTreelist;
	CGroupsTreelistUI*		m_GroupList;
	CUIRecentSessionList*	m_UIRecentConnectedList;

	Node*					m_groupRootParent;
	Node*					m_DiscussGroupRootParent;
};
/******************************************************************************/
#endif// LISTPANEL_00907A2F_35FC_48EE_B385_4C5DE6018C6A_H__
