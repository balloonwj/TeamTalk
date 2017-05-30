/*******************************************************************************
 *  @file      CreateDiscussionGrpDialog.h 2015\1\14 19:36:23 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef CREATEDISCUSSIONGRPDIALOG_311BC0B4_F7F8_47C6_8D52_352E69A9C6E5_H__
#define CREATEDISCUSSIONGRPDIALOG_311BC0B4_F7F8_47C6_8D52_352E69A9C6E5_H__

#include "DuiLib/UIlib.h"
/******************************************************************************/
using namespace DuiLib;

/**
 * The class <code>CreateDiscussionGrpDialog</code> 
 *
 */
class UIIMList;

class CreateDiscussionGrpDialog : public WindowImplBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	CreateDiscussionGrpDialog(std::string currentSessionId);
    /**
     * Destructor
     */
    virtual ~CreateDiscussionGrpDialog();
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
	void _AddToGroupMemberList(std::string sid);
	void _updateSearchResultList(IN const std::vector<std::string>& nameList);
	void _refreshUIAddedNum();
private:
	UIIMList*				m_pListCreatFrom;		//讨论组数据源列表	左
	CListUI*				m_pListGroupMembers;	//讨论组结果列表	右
	CListUI*				m_pListSearchResult;	//搜索结果列表
	CEditUI*				m_editGroupName;		
	CVerticalLayoutUI*		m_searchePanel;
	CEditUI*				m_editSearch;			//搜索框
	CTextUI*				m_TextaddNums;			//已经加了多少人
	CTextUI*				m_TextErrorTip;			//错误提示
	std::string				m_currentSessionId;
};
/******************************************************************************/
#endif// CREATEDISCUSSIONGRPDIALOG_311BC0B4_F7F8_47C6_8D52_352E69A9C6E5_H__
