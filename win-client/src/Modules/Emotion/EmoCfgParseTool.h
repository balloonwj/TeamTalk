/*******************************************************************************
 *  @file      EmoCfgParseTool.h 2015\3\17 17:32:10 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef EMOCFGPARSETOOL_5B1DB11A_DE23_4672_9CC0_A5F7C9F27D6B_H__
#define EMOCFGPARSETOOL_5B1DB11A_DE23_4672_9CC0_A5F7C9F27D6B_H__

#include "GlobalDefine.h"

#include <list>
/******************************************************************************/

/**
 * The class <code>Multilingual</code> 
 *
 */
class  EmoCfgParseTool
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	EmoCfgParseTool() = default;;
    /**
     * Destructor
     */
	~EmoCfgParseTool() = default;;
    //@}

public:
	CString	   getIDByName(IN LPCTSTR strID);
	CString    getNameByID(IN LPCTSTR str);
	void       getAllNames(OUT std::list<CString>& nameList);

	void	   loadCfgFile(IN LPCTSTR strFilePath);

private:
	std::map<CString, CString> m_mapKey2Value;
};

/******************************************************************************/
#endif// EMOCFGPARSETOOL_5B1DB11A_DE23_4672_9CC0_A5F7C9F27D6B_H__
