/*******************************************************************************
 *  @file      Multilingual.h 2014\11\25 21:14:44 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     多语言支持工具类，利用windows ini api实现
 ******************************************************************************/

#ifndef MULTILINGUAL_93AF83ED_9E20_45F1_8C1A_48CA7C6D3FF9_H__
#define MULTILINGUAL_93AF83ED_9E20_45F1_8C1A_48CA7C6D3FF9_H__

#include "GlobalDefine.h"
#include "utility/utilityDll.h"
/******************************************************************************/
NAMESPACE_BEGIN(util)

/**
 * The class <code>Multilingual</code> 
 *
 */
class UTILITY_CLASS Multilingual
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    Multilingual();
    /**
     * Destructor
     */
    ~Multilingual();
    //@}

public:
	CString getStringById(LPCTSTR strID);
};
extern UTILITY_API Multilingual* getMultilingual();

NAMESPACE_END(util)
/******************************************************************************/
#endif// MULTILINGUAL_93AF83ED_9E20_45F1_8C1A_48CA7C6D3FF9_H__
