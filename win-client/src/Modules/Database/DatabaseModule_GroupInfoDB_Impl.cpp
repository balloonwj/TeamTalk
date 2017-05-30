/******************************************************************************* 
 *  @file      DatabaseModule_GroupInfoDB_Impl.cpp 2014\12\30 16:12:41 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     group info db manage
 ******************************************************************************/

#include "stdafx.h"
#include "DatabaseModule_Impl.h"
#include "utility/CppSQLite3.h"
#include "utility/utilStrCodingAPI.h"
#include "json/reader.h"
#include "json/writer.h"
/******************************************************************************/
namespace
{
	const std::string createGroupInfoSql =
		"CREATE TABLE IF NOT EXISTS groupinfo"
		"("
		"    [id]                           INTEGER PRIMARY KEY,"
		"    [groupId]						TEXT NOT NULL UNIQUE,"					//1.
		"    [name]							TEXT DEFAULT NULL,"						//2.group name
		"    [desc]							TEXT DEFAULT NULL,"						//3.group descripe
		"    [avatarUrl]					TEXT DEFAULT NULL,"						//4.group avatar url path
		"    [creatorId]					TEXT DEFAULT NULL,"						//5.group creator user id
		"    [type]							INTEGER DEFAULT 2,"						//6.group type,1，固定群 2,讨论组
		"    [version]						INTEGER DEFAULT 0,"						//7.group info version
		"    [lastUpdateTime]				INTEGER DEFAULT 0,"						//8.last update time
		"    [shieldStatus]					INTEGER DEFAULT 0,"						//9.群消息推送是否屏蔽 0: 不屏蔽 1: 屏蔽
		"    [memberlist]					TEXT NOT NULL,"							//10.group member list which storage by json format
		"    [reserve1]                     TEXT DEFAULT NULL,"
		"    [reserve2]                     INTEGER DEFAULT NULL,"
		"    [reserve3]                     INTEGER DEFAULT NULL"
		");";
	const std::string createGroupInfoIndex =
		"create unique index if not exists groupid_idx ON groupinfo(groupId);";
	const std::string getAllGroupInfoSql
		= "select * from groupinfo limit 10000";
	const std::string getGroupInfoByGIdSql
		= "select * from groupinfo where groupId=? limit 1";
	const std::string insertGroupInfoSql
		= "INSERT OR REPLACE into groupinfo(groupId,name,desc,avatarUrl,creatorId,type,version,lastUpdateTime,shieldStatus,memberlist) "
		"VALUES(?,?,?,?,?,?,?,?,?,?);";
	const std::string deleteGroupInfoSql
		= "delete from groupinfo where groupId=?";
	const std::string updateGroupInfoBySIdSql
		= "update groupinfo set name=?,desc=?,avatarUrl=?,creatorId=?,type=?,version=?,lastUpdateTime=?,shieldStatus=?,memberlist=? where groupId=?";
	const std::string BeginInsert
		= "BEGIN TRANSACTION;";
	const std::string EndInsert
		= "COMMIT TRANSACTION;";
	const std::string RollBack
		= "ROLLBACK TRANSACTION";
}

BOOL DatabaseModule_Impl::sqlGetGroupInfoByGId(IN std::string& gId, OUT module::GroupInfoEntity& groupInfo)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getGroupInfoByGIdSql.c_str());
		stmt.bind(1, gId.c_str());

		CppSQLite3Query query = stmt.execQuery();
		if (!query.eof())
		{
			groupInfo.gId = gId;
			groupInfo.csName = util::stringToCString(query.getStringField(2));
			groupInfo.desc = util::stringToCString(query.getStringField(3));
			groupInfo.avatarUrl = query.getStringField(4);
			groupInfo.creatorId = query.getStringField(5);
			groupInfo.type = query.getIntField(6);
			groupInfo.version = query.getIntField(7);
			groupInfo.groupUpdated = query.getIntField(8);
			groupInfo.shieldStatus = query.getIntField(9);
			_parseJsonForGroupMembers(query.getStringField(10), groupInfo.groupMemeberList);
		}
		else
		{
			return FALSE;
		}
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("db failed,error msg:%s"),
			csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}

	return TRUE;

}

BOOL DatabaseModule_Impl::sqlGetAllGroupInfo(OUT std::vector<module::GroupInfoEntity>& groupList)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getAllGroupInfoSql.c_str());

		CppSQLite3Query query = stmt.execQuery();
		while (!query.eof())
		{
			module::GroupInfoEntity groupInfo;
			groupInfo.gId = query.getStringField(1);
			groupInfo.csName = util::stringToCString(query.getStringField(2));
			groupInfo.desc = util::stringToCString(query.getStringField(3));
			groupInfo.avatarUrl = query.getStringField(4);
			groupInfo.creatorId = query.getStringField(5);
			groupInfo.type = query.getIntField(6);
			groupInfo.version = query.getIntField(7);
			groupInfo.groupUpdated = query.getIntField(8);
			groupInfo.shieldStatus = query.getIntField(9);
			_parseJsonForGroupMembers(query.getStringField(10), groupInfo.groupMemeberList);

			groupList.push_back(groupInfo);
			query.nextRow();
		}
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("select failed,error msg:%s"),
			csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}

	return TRUE;
}

BOOL DatabaseModule_Impl::sqlInsertOrReplaceGroupInfoEntity(IN const module::GroupInfoEntity& groupInfo)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertGroupInfoSql.c_str());
		stmt.bind(1, groupInfo.gId.c_str());
		stmt.bind(2, util::cStringToString(groupInfo.csName).c_str());
		stmt.bind(3, util::cStringToString(groupInfo.desc).c_str());
		stmt.bind(4, groupInfo.avatarUrl.c_str());
		stmt.bind(5, groupInfo.creatorId.c_str());
		stmt.bind(6, int(groupInfo.type));
		stmt.bind(7, int(groupInfo.version));
		stmt.bind(8, int(groupInfo.groupUpdated));
		stmt.bind(9, int(groupInfo.shieldStatus));
		std::string& strJson = _makeJsonForGroupMembers(groupInfo.groupMemeberList);
		stmt.bind(10, strJson.c_str());
		stmt.execDML();
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("insert failed,error msg:%s"), csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}

	return TRUE;
}

BOOL DatabaseModule_Impl::sqlUpdateGroupInfoEntity(std::string& sId, IN const module::GroupInfoEntity& groupInfo)
{
	try
	{
		//"update groupinfo set name=?,desc=?,avatarUrl=?,creatorId=?,type=?,version=?,lastUpdateTime=?,shieldStatus=?,memberlist=? where groupId=?";
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(updateGroupInfoBySIdSql.c_str());
		stmt.bind(1, util::cStringToString(groupInfo.csName).c_str());
		stmt.bind(2, util::cStringToString(groupInfo.desc).c_str());
		stmt.bind(3, groupInfo.avatarUrl.c_str());
		stmt.bind(4, groupInfo.creatorId.c_str());
		stmt.bind(5, int(groupInfo.type));
		stmt.bind(6, int(groupInfo.version));
		stmt.bind(7, int(groupInfo.groupUpdated));
		stmt.bind(8, int(groupInfo.shieldStatus));
		std::string& strJson = _makeJsonForGroupMembers(groupInfo.groupMemeberList);
		stmt.bind(9, strJson.c_str());
		stmt.bind(9, groupInfo.gId.c_str());
		int countUpdate = stmt.execDML();
		if (0 == countUpdate)
		{
			LOG__(ERR, _T("db update failed:%s"), util::stringToCString(groupInfo.gId));
			return FALSE;
		}
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("db failed,error msg:%s"), csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		return FALSE;
	}

	return TRUE;
}

BOOL DatabaseModule_Impl::sqlBatchInsertGroupInfos(IN module::GroupInfoMap& mapGroupInfos)
{
	try
	{
		CppSQLite3Statement stmtBegin = m_pSqliteDB->compileStatement(BeginInsert.c_str());
		stmtBegin.execDML();

		for (auto kv : mapGroupInfos)
		{
			module::GroupInfoEntity& groupInfo = kv.second;
			CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertGroupInfoSql.c_str());
			stmt.bind(1, groupInfo.gId.c_str());
			stmt.bind(2, util::cStringToString(groupInfo.csName).c_str());
			stmt.bind(3, util::cStringToString(groupInfo.desc).c_str());
			stmt.bind(4, groupInfo.avatarUrl.c_str());
			stmt.bind(5, groupInfo.creatorId.c_str());
			stmt.bind(6, int(groupInfo.type));
			stmt.bind(7, int(groupInfo.version));
			stmt.bind(8, int(groupInfo.groupUpdated));
			stmt.bind(9, int(groupInfo.shieldStatus));
			std::string& strJson = _makeJsonForGroupMembers(groupInfo.groupMemeberList);
			stmt.bind(10, strJson.c_str());
			stmt.execDML();
		}

		CppSQLite3Statement stmtEnd = m_pSqliteDB->compileStatement(EndInsert.c_str());
		stmtEnd.execDML();
	}
	catch (CppSQLite3Exception& e)
	{
		CString csErrMsg = util::stringToCString(e.errorMessage());
		LOG__(ERR, _T("batch insert failed,error msg:%s"), csErrMsg);
		CppSQLite3Statement stmtRollback = m_pSqliteDB->compileStatement(RollBack.c_str());
		stmtRollback.execDML();
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("batch insert unknown exception"));
		return FALSE;
	}

	return TRUE;
}

BOOL DatabaseModule_Impl::_execGroupInfoCreateTableDML()
{
	try
	{
		m_pSqliteDB->execDML(createGroupInfoSql.c_str());
		m_pSqliteDB->execDML(createGroupInfoIndex.c_str());
	}
	catch (CppSQLite3Exception& sqliteException)
	{
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("create table failed,error msg:%s")
			, csErrMsg);
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif	
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("create table unknown exception"));
		return FALSE;
	}

	return TRUE;
}
std::string DatabaseModule_Impl::_makeJsonForGroupMembers(IN std::list<std::string> groupMemeberList)
{
	Json::Value value;
	for (std::string sid:groupMemeberList)
	{
		value["UserIds"].append(sid);
	}
	Json::StyledWriter styleWrite;
	return styleWrite.write(value);
}

void DatabaseModule_Impl::_parseJsonForGroupMembers(IN std::string strJson, OUT std::list<std::string>& groupMemeberList)
{
	Json::Reader reader;
	Json::Value root;

	try
	{
		if (reader.parse(strJson, root) || root.isNull())
		{
			const Json::Value arrayObj = root["UserIds"];
			for (int i = 0; i < static_cast<int>(arrayObj.size()); ++i)
			{
				groupMemeberList.push_back(arrayObj[i].asString());
			}
		}
		else
		{
			LOG__(ERR, _T("json parse falied! json data:%s"),util::stringToCString(strJson));
		}
	}
	catch (...)
	{
		LOG__(ERR, _T("json parse falied! json data:%s"), util::stringToCString(strJson));
	}
}

BOOL DatabaseModule_Impl::sqlDeleteGroupInfoEntity(IN const std::string& groupId)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(deleteGroupInfoSql.c_str());
		stmt.bind(1, groupId.c_str());
		stmt.execDML();
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("delete failed,error msg:%s"), csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}

	return TRUE;
}


/******************************************************************************/