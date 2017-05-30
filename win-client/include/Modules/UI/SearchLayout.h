 /*******************************************************************************
 *  @file      SearchLayout.h 2014\8\11 16:30:53 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     搜索框，用以存放搜索业务逻辑
 ******************************************************************************/

#ifndef SEARCHLAYOUT_444A5D88_D118_4093_8D80_C63672830D2D_H__
#define SEARCHLAYOUT_444A5D88_D118_4093_8D80_C63672830D2D_H__

#include "DuiLib/UIlib.h"
/******************************************************************************/
using namespace DuiLib;

/**
 * The class <code>SearchLayout</code> 
 *
 */
class CGroupsTreelistUI;
class SearchLayout :public CVerticalLayoutUI, public INotifyUI
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    SearchLayout();
    /**
     * Destructor
     */
    ~SearchLayout();
    //@}

public:
	virtual LPVOID GetInterface(LPCTSTR pstrName);
	virtual LPCTSTR GetClass() const;

	virtual void DoInit();
	virtual void Notify(TNotifyUI& msg);
private:
	void _updateSearchResultList(IN const std::vector<std::string>& nameList,int IdType);
	void _updateSearchResultListForDepartMent(IN const CString strSearch);
private:
	CButtonUI*	m_btnSearch;
	CButtonUI*	m_btnCancel;
	CEditUI*	m_edit;
	CControlUI*	m_layoutSearchResult;
	CGroupsTreelistUI*	m_SearchResultList;
};
/******************************************************************************/
#endif// SEARCHLAYOUT_444A5D88_D118_4093_8D80_C63672830D2D_H__
