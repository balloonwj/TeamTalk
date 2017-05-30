/*******************************************************************************
 *  @file      DialogManager.h 2014\9\9 10:51:47 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     duilib窗口管理器
 ******************************************************************************/

#ifndef DIALOGMANAGER_1119417E_2736_419F_B096_964E2676382E_H__
#define DIALOGMANAGER_1119417E_2736_419F_B096_964E2676382E_H__

#include "GlobalDefine.h"
#include "../core/DuiLib/UIlib.h"
#include <vector>
/******************************************************************************/
NAMESPACE_BEGIN(DuiLib)

/**
 * The class <code>duilib窗口管理器</code> 
 *
 */
class UILIB_API DialogManager
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    DialogManager();
    /**
     * Destructor
     */
    ~DialogManager();
    //@}
	static DialogManager* getInstance();

public:
	void registerDialog(WindowImplBase* pDialog);
	void unRegisterDialog(WindowImplBase* pDialog);
	void closeAllDialogs();

private:
	#pragma warning(disable : 4251)
	std::vector<WindowImplBase*>			m_vecDialogs;
};

NAMESPACE_END(DuiLib)
/******************************************************************************/
#endif// DIALOGMANAGER_1119417E_2736_419F_B096_964E2676382E_H__
