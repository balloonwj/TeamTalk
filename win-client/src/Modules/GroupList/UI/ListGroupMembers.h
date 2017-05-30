 /*******************************************************************************
 *  @file      ListGroupMembers.h 2014\8\13 11:09:44 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef LISTGROUPMEMBERS_511D645A_CDE2_46B9_9F84_B2D413FFCC54_H__
#define LISTGROUPMEMBERS_511D645A_CDE2_46B9_9F84_B2D413FFCC54_H__

#include "Modules/UI/UIIMList.h"
/******************************************************************************/

/**
 * The class <code>ListGroupMembers</code> 
 *
 */
class ListGroupMembers : public UIIMList
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	ListGroupMembers(CPaintManagerUI& paint_manager);

	Node* AddNode(const IMListItemInfo& item, Node* parent = NULL, int index = 0);
    //@}
};
/******************************************************************************/
#endif// LISTGROUPMEMBERS_511D645A_CDE2_46B9_9F84_B2D413FFCC54_H__
