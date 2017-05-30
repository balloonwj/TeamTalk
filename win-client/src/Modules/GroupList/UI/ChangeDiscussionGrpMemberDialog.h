/*******************************************************************************
 *  @file      ChangeDiscussionGrpMemberDialog.h 2015\1\14 19:38:29 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef CHANGEDISCUSSIONGRPMEMBERDIALOG_66DC2707_07BD_4D1E_BE03_D3DA670C1E13_H__
#define CHANGEDISCUSSIONGRPMEMBERDIALOG_66DC2707_07BD_4D1E_BE03_D3DA670C1E13_H__

#include "DuiLib/UIlib.h"
#include <list>
using namespace DuiLib;
class UIIMList;

/**
 * The class <code>ChangeDiscussionGrpMemberDialog</code> 
 *
 */
class ChangeDiscussionGrpMemberDialog : public WindowImplBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	ChangeDiscussionGrpMemberDialog(IN const std::string& sid);
    /**
     * Destructor
     */
	virtual ~ChangeDiscussionGrpMemberDialog();
    //@}
	DUI_DECLARE_MESSAGE_MAP()
public:
	LPCTSTR GetWindowClassName() const;
	virtual CDuiString GetSkinFile();
	virtual CDuiString GetSkinFolder();
	virtual CControlUI* CreateControl(LPCTSTR pstrClass);
	virtual void OnFinalMessage(HWND hWnd);
	virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
protected:
	void OnPrepare(TNotifyUI& msg);
	void OnItemActive(TNotifyUI& msg);
	void OnItemClick(TNotifyUI& msg);
	void OnClick(TNotifyUI& msg);
	void OnTextChanged(TNotifyUI& msg);
private:
	BOOL _AddToGroupMemberList(IN std::string sid,IN const BOOL bEnableDelete = TRUE);
	void _updateSearchResultList(IN const std::vector<std::string>& nameList);
	void _refreshUIAddedNum();
	void _changeResultList(IN const std::string& sid ,IN const BOOL bAdded);
	void _sendChangeReq();
private:
	UIIMList*				m_pListCreatFrom;		//讨论组数据源列表	左
	CListUI*				m_pListGroupMembers;	//讨论组结果列表	右
	CListUI*				m_pListSearchResult;	//搜索结果列表
	CEditUI*				m_editGroupName;
	CVerticalLayoutUI*		m_searchePanel;
	CEditUI*				m_editSearch;			//搜索框
	CTextUI*				m_TextaddNums;			//已经加了多少人
	std::string				m_currentSessionId;		//会话Id

	std::list<std::string>  m_addedUsers;	//增加的用户
	std::list<std::string>  m_deleteUsers;	//删除的用户
};
/******************************************************************************/
#endif// CHANGEDISCUSSIONGRPMEMBERDIALOG_66dc2707-07bd-4d1e-be03-d3da670c1e13_H__
