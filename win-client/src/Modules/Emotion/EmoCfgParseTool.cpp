/******************************************************************************* 
 *  @file      EmoCfgParseTool.cpp 2015\3\17 17:33:01 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "EmoCfgParseTool.h"
#include "Modules/IMiscModule.h"
#include "utility/utilStrCodingAPI.h"
#include "utility/utilCommonAPI.h"
#include "json/reader.h"
/******************************************************************************/

CString EmoCfgParseTool::getIDByName(IN LPCTSTR  str)
{
	for (auto item : m_mapKey2Value)
	{
		if (item.second == CString(str))
		{
			return item.first;
		}
	}
	LOG__(ERR, _T("Can't get the id, name:%s"),str);
	return CString(_T(""));
}
CString EmoCfgParseTool::getNameByID(IN LPCTSTR strID)
{
	std::map<CString, CString>::iterator item = m_mapKey2Value.find(CString(strID));
	if (item != m_mapKey2Value.end())
	{
		return item->second;
	}
	LOG__(ERR, _T("Can't get the name, id:%s"), strID);
	return CString(_T(""));
}

void EmoCfgParseTool::getAllNames(OUT std::list<CString>& nameList)
{
	for (auto item : m_mapKey2Value)
	{
		nameList.push_back(item.first);
	}
}

void EmoCfgParseTool::loadCfgFile(IN LPCTSTR strFilePath)
{
	if (!util::isFileExist(strFilePath))
	{
		return;
	}
	
	//读取配置文件到内存
	std::string strData;
	CFile f;
	f.Open(strFilePath,
		CFile::modeReadWrite);
	char* buf = new char[MAX_PATH];
	ZeroMemory(buf, MAX_PATH);
	while (f.Read(buf, MAX_PATH))
	{
		strData += std::string(buf, MAX_PATH);
		ZeroMemory(buf, MAX_PATH);
	}
	delete buf;
	buf = nullptr;
	f.Close();

	//json解析内容
	Json::Reader reader;
	Json::Value root;
	if (!reader.parse(strData, root)
		|| root.isNull())
	{
		return;
	}
	Json::Value::Members member;
	for (Json::Value::iterator itr = root.begin();
		itr != root.end(); ++itr)
	{
		member = (*itr).getMemberNames();
		for (Json::Value::Members::iterator iter = member.begin();
			iter != member.end(); ++iter)
		{
			std::string sValue = (*itr)[(*iter)].asString();
			std::string sKey = (*iter);
			m_mapKey2Value[util::stringToCString(sKey, CP_ACP)] = util::stringToCString(sValue, CP_ACP);
		}
	}
}

/******************************************************************************/