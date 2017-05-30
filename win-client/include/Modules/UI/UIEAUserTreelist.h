/*******************************************************************************
 *  @file      UIEAUserTreelist.h 2014\8\7 15:46:39 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     企业组织架构树形控件
 ******************************************************************************/

#ifndef UIEAUSERTREELIST_336BA069_7979J_4659_9E6C_0409B5280078_H__
#define UIEAUSERTREELIST_336BA069_7979J_4659_9E6C_0409B5280078_H__

#include "Modules/UI/UIIMList.h"
/******************************************************************************/

class EAUserTreeListItemInfo :public IMListItemInfo
{

};

/**
* The class <code>企业组织架构树形控件</code>
*
*/
class CEAUserTreelistUI final: public UIIMList
{
public:

	CEAUserTreelistUI(CPaintManagerUI& paint_manager);

	Node* AddNode(const EAUserTreeListItemInfo& item, Node* parent = NULL);
	BOOL UpdateItemBySId(const std::string& sId);
	void ClearItemMsgCount(IN const std::string& sId);//清除显示的未读计数
	void sortByOnlineState();
};
/******************************************************************************/
#endif// UIEAUSERTREELIST_336BA069_7979J_4659_9E6C_0409B5280078_H__