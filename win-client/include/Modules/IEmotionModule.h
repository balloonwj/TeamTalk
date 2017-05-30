/*******************************************************************************
 *  @file      IEmotionModule.h 2014\8\6 20:03:22 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     表情管理模块
 ******************************************************************************/

#ifndef IEMOTIONMODULE_8E431B43_8F05_4934_8B5B_BB839730F3A6_H__
#define IEMOTIONMODULE_8E431B43_8F05_4934_8B5B_BB839730F3A6_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"
#include "Modules/ModuleBase.h"
/******************************************************************************/
NAMESPACE_BEGIN(module)
const std::string MODULE_EMOTION_PREFIX = "Emotion";

//KEYID
const std::string KEY_EMOTION_SELECTED = MODULE_EMOTION_PREFIX + "selected";      //选择了某个表情

/**
 * The class <code>表情管理模块</code> 
 *
 */

class EmotionParam
{
public:
	std::string			 sid;
	CString				 strPath;
};

class MODULE_API IEmotionModule : public module::ModuleBase
{
public:
	/**
	 * 显示表情窗口
	 *
	 * @param   POINT pt 显示的位置
	 * @return  void
	 * @exception there is no any exception to throw.
	 */
	virtual void showEmotionDialog(IN std::string sid, IN POINT pt) = 0;
	virtual BOOL getEmotionNameByID(IN CString ID, OUT CString& csPath) = 0;
	virtual BOOL getEmotionIDByName(IN CString csPath, OUT CString& ID) = 0;
	/**
	* 获取当前显示窗口的会话ID
	*
	* @param   POINT pt 显示的位置
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual std::string  getCurEmotionWndSessionId(void) = 0;


	virtual void getAllEmotionFileNames(OUT std::list<CString>& nameList) = 0;
};

MODULE_API IEmotionModule* getEmotionModule();

NAMESPACE_END(module)
/******************************************************************************/
#endif// IEMOTIONMODULE_8E431B43_8F05_4934_8B5B_BB839730F3A6_H__
