/******************************************************************************* 
 *  @file      ListCreatFrom.cpp 2014\8\12 15:01:27 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief      用于创建群窗口的用户数据源列表
 ******************************************************************************/

#include "stdafx.h"
#include "ListCreatFrom.h"



/******************************************************************************/

Node* ListCreatFrom::AddNode(const IMListItemInfo& item, Node* parent /*= NULL*/, int index /*= 0*/)
{

	return __super(item,parent,index);
}
