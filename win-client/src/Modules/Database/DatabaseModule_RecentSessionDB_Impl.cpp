/******************************************************************************* 
 *  @file      DatabaseModule_RecentSessionDB_Impl.cpp 2015\1\7 18:24:54 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "DatabaseModule_Impl.h"
#include "utility/CppSQLite3.h"
#include "utility/utilStrCodingAPI.h"
/******************************************************************************/
namespace
{
	const std::string createRecentSessionSql =
		"CREATE TABLE IF NOT EXISTS recentSessionInfo"
		"("
		"    [id]                           INTEGER PRIMARY KEY,"
		"    [sessionId]					TEXT NOT NULL UNIQUE,"					//1.session id
		"    [sessionType]					INTEGER DEFAULT 0,"						//2.session type
		"    [updatedTime]					INTEGER DEFAULT 0,"						//3.update time
		"    [lastMsgId]					INTEGER DEFAULT 0,"						//4.last msg id
		"    [lastMsgData]					TEXT DEFAULT NULL,"						//5.last msg data
		"    [latestMsgFromId]				TEXT DEFAULT NULL,"						//6.last msg data from id
		"    [reserve1]                     TEXT DEFAULT NULL,"
		"    [reserve2]                     INTEGER DEFAULT NULL,"
		"    [reserve3]                     INTEGER DEFAULT NULL"
		");";
	const std::string createRecentSessionIndex =
		"create unique index if not exists sessionId_idx ON recentSessionInfo(sessionId);";
	const std::string getAllRecentSessionSql
		= "select * from recentSessionInfo order by updatedTime desc limit 100";
	const std::string getRecentSessionByIdSql
		= "select * from recentSessionInfo where sessionId=? limit 1";
	const std::string insertRecentSessionSql
		= "INSERT OR REPLACE into recentSessionInfo(sessionId,sessionType,updatedTime,lastMsgId,lastMsgData,latestMsgFromId) "
		"VALUES(?,?,?,?,?,?);";
	const std::string deleteRecentSessionSql
		= "delete from recentSessionInfo where sessionId=?";
	const std::string updateRecentSessionByIdSql
		= "UPDATE recentSessionInfo SET sessionId = ?,sessionType = ?,updatedTime = ?,lastMsgId = ?,lastMsgData = ?,latestMsgFromId=? where sessionId = ?";
	const std::string BeginInsert
		= "BEGIN TRANSACTION;";
	const std::string EndInsert
		= "COMMIT TRANSACTION;";
	const std::string RollBack
		= "ROLLBACK TRANSACTION";
}


BOOL DatabaseModule_Impl::sqlGetRecentSessionInfoByGId(IN std::string& sId, OUT module::SessionEntity& sessionInfo)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getRecentSessionByIdSql.c_str());
		stmt.bind(1, sId.c_str());

		CppSQLite3Query query = stmt.execQuery();
		if (!query.eof())
		{
			sessionInfo.sessionID = sId;
			sessionInfo.sessionType = query.getIntField(2);
			sessionInfo.updatedTime = query.getIntField(3);
			sessionInfo.latestmsgId = query.getIntField(4);
			sessionInfo.latestMsgContent = query.getStringField(5);
			sessionInfo.latestMsgFromId = query.getStringField(6);
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

BOOL DatabaseModule_Impl::sqlGetAllRecentSessionInfo(OUT std::vector<module::SessionEntity>& sessionList)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getAllRecentSessionSql.c_str());

		CppSQLite3Query query = stmt.execQuery();
		while (!query.eof())
		{
			module::SessionEntity sessionInfo;
			sessionInfo.sessionID = query.getStringField(1);;
			sessionInfo.sessionType = query.getIntField(2);
			sessionInfo.updatedTime = query.getIntField(3);
			sessionInfo.latestmsgId = query.getIntField(4);
			sessionInfo.latestMsgContent = query.getStringField(5);
			sessionInfo.latestMsgFromId = query.getStringField(6);
			sessionList.push_back(sessionInfo);
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

BOOL DatabaseModule_Impl::sqlInsertRecentSessionInfoEntity(IN const module::SessionEntity& sessionInfo)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertRecentSessionSql.c_str());
		stmt.bind(1, sessionInfo.sessionID.c_str());
		stmt.bind(2, int(sessionInfo.sessionType));
		stmt.bind(3, int(sessionInfo.updatedTime));
		stmt.bind(4, int(sessionInfo.latestmsgId));
		stmt.bind(5, sessionInfo.latestMsgContent.c_str());
		stmt.bind(6, sessionInfo.latestMsgFromId.c_str());
		if (0 == stmt.execDML())
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

BOOL DatabaseModule_Impl::sqlUpdateRecentSessionInfoEntity(IN const module::SessionEntity& sessionInfo)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(updateRecentSessionByIdSql.c_str());
		stmt.bind(1, sessionInfo.sessionID.c_str());
		stmt.bind(2, int(sessionInfo.sessionType));
		stmt.bind(3, int(sessionInfo.updatedTime));
		stmt.bind(4, int(sessionInfo.latestmsgId));
		stmt.bind(5, sessionInfo.latestMsgContent.c_str());
		stmt.bind(6, sessionInfo.latestMsgFromId.c_str());

		stmt.bind(7, sessionInfo.sessionID.c_str());
		int countUpdate = stmt.execDML();
		if (0 == countUpdate)
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
		LOG__(ERR, _T("db failed,error msg:%s"), csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}
	return TRUE;
}

BOOL DatabaseModule_Impl::sqlBatchInsertRecentSessionInfos(IN std::vector<module::SessionEntity>& sessionList)
{
	try
	{
		CppSQLite3Statement stmtBegin = m_pSqliteDB->compileStatement(BeginInsert.c_str());
		stmtBegin.execDML();

		for (module::SessionEntity sessionInfo : sessionList)
		{
			CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertRecentSessionSql.c_str());
			stmt.bind(1, sessionInfo.sessionID.c_str());
			stmt.bind(2, int(sessionInfo.sessionType));
			stmt.bind(3, int(sessionInfo.updatedTime));
			stmt.bind(4, int(sessionInfo.latestmsgId));
			stmt.bind(5, sessionInfo.latestMsgContent.c_str());
			stmt.bind(6, sessionInfo.latestMsgFromId.c_str());
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

BOOL DatabaseModule_Impl::_execRecentSessionInfoCreateTableDML()
{
	try
	{
		m_pSqliteDB->execDML(createRecentSessionSql.c_str());
		m_pSqliteDB->execDML(createRecentSessionIndex.c_str());
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


BOOL DatabaseModule_Impl::sqlDeleteRecentSessionInfoEntity(IN const std::string& sessionId)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(deleteRecentSessionSql.c_str());
		stmt.bind(1, sessionId.c_str());
		if (0 == stmt.execDML())
		{
			LOG__(ERR, _T("delete failed,sessionIdg:%s"), util::stringToCString(sessionId));
			return FALSE;
		}
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