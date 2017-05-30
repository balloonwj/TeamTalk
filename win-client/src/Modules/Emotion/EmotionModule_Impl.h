/*******************************************************************************
 *  @file      EmotionModule_Impl.h 2014\8\6 20:05:39 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef EMOTIONMODULE_IMPL_9432EBF5_DD5E_4C01_BF4B_A8D3E1E11CB9_H__
#define EMOTIONMODULE_IMPL_9432EBF5_DD5E_4C01_BF4B_A8D3E1E11CB9_H__

#include "Modules/IEmotionModule.h"
#include "EmoCfgParseTool.h"
/******************************************************************************/
class EmotionDialog;

/**
 * The class <code>EmotionModule_Impl</code> 
 *
 */

class EmotionModule_Impl final : public module::IEmotionModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    EmotionModule_Impl();
    /**
     * Destructor
     */
    virtual ~EmotionModule_Impl();
    //@}

public:
	virtual void showEmotionDialog(IN std::string sid,IN POINT pt);
	virtual BOOL getEmotionNameByID(IN CString ID, OUT CString& csPath);
	virtual BOOL getEmotionIDByName(IN CString csName, OUT CString& csID);
	virtual std::string  getCurEmotionWndSessionId(void);

	virtual void getAllEmotionFileNames(OUT std::list<CString>& nameList);
private:
	EmotionDialog*				m_emotionWindow;
	std::string					m_sid;
	EmoCfgParseTool*				m_pEmotionKey;
};
/******************************************************************************/
#endif// EMOTIONMODULE_IMPL_9432EBF5_DD5E_4C01_BF4B_A8D3E1E11CB9_H__
