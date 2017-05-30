/******************************************************************************* 
 *  @file      DatabaseModule_DepartmentInfoDB_Impl.cpp 2015\3\17 11:24:57 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "DatabaseModule_Impl.h"
#include "utility/CppSQLite3.h"
#include "utility/utilStrCodingAPI.h"
/******************************************************************************/
namespace
{
	const std::string createDepartmentInfoSql =
		"CREATE TABLE IF NOT EXISTS departmentinfo"
		"("
		"    [id]                           INTEGER PRIMARY KEY,"
		"    [dId]							TEXT NOT NULL UNIQUE,"					//1 ID
		"    [priority]						INTEGER DEFAULT 0,"						//2 优先级
		"    [name]							TEXT DEFAULT NULL,"						//3 部门名称
		"    [parentDepartId]				TEXT DEFAULT NULL,"						//4 上级部门ID
		"    [status]						INTEGER DEFAULT 0,"						//5 部门状态  0:正常 1:删除	
		"    [reserve1]                     TEXT DEFAULT NULL,"
		"    [reserve2]                     INTEGER DEFAULT NULL,"
		"    [reserve3]                     INTEGER DEFAULT NULL"
		");";
	const std::string createDepartmentInfoIndex =
		"create unique index if not exists dId_idx ON departmentinfo(dId);";
	const std::string getAllDepartmentInfoSql
		= "select * from departmentinfo where status=0 limit 10000";
	const std::string getDepartmentInfoBySIdSql
		= "select * from departmentinfo where dId=? limit 1";
	const std::string insertDepartmentInfoSql
		= "INSERT OR REPLACE into departmentinfo(dId,priority,name,parentDepartId,status) "
		"VALUES(?,?,?,?,?);";
	const std::string updateDepartmentBySIdSql
		= "update departmentinfo set dId=?,priority=?,name=?,departmentId=?,parentDepartId=?,status=? where dId=?";
	const std::string BeginInsert
		= "BEGIN TRANSACTION;";
	const std::string EndInsert
		= "COMMIT TRANSACTION;";
	const std::string RollBack
		= "ROLLBACK TRANSACTION";
}

BOOL DatabaseModule_Impl::sqlUpdateDepartmentInfoEntity(std::string& sId, IN const module::DepartmentEntity& departmentInfo)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(updateDepartmentBySIdSql.c_str());
		stmt.bind(1, departmentInfo.dId.c_str());
		stmt.bind(2, (int)departmentInfo.priority);
		stmt.bind(3, util::cStringToString(departmentInfo.name).c_str());
		stmt.bind(4, departmentInfo.parentDepartId.c_str());
		stmt.bind(5, (int)departmentInfo.status);
		int countUpdate = stmt.execDML();
		if (0 == countUpdate)
		{
			LOG__(ERR, _T("db update failed:%s"), util::stringToCString(departmentInfo.dId));
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

BOOL DatabaseModule_Impl::sqlBatchInsertDepartmentInfos(IN module::DepartmentMap& mapDepartmentInfos)
{
	try
	{
		CppSQLite3Statement stmtBegin = m_pSqliteDB->compileStatement(BeginInsert.c_str());
		stmtBegin.execDML();

		for (auto kv : mapDepartmentInfos)
		{
			module::DepartmentEntity& departmentInfo = kv.second;
			CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertDepartmentInfoSql.c_str());
			stmt.bind(1, departmentInfo.dId.c_str());
			stmt.bind(2, (int)departmentInfo.priority);
			stmt.bind(3, util::cStringToString(departmentInfo.name).c_str());
			stmt.bind(4, departmentInfo.parentDepartId.c_str());
			stmt.bind(5, (int)departmentInfo.status);
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

BOOL DatabaseModule_Impl::sqlInsertDepartmentInfoEntity(IN const module::DepartmentEntity& departmentInfo)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteDB->compileStatement(insertDepartmentInfoSql.c_str());
		stmt.bind(1, departmentInfo.dId.c_str());
		stmt.bind(2, (int)departmentInfo.priority);
		stmt.bind(3, util::cStringToString(departmentInfo.name).c_str());
		stmt.bind(4, departmentInfo.parentDepartId.c_str());
		stmt.bind(5, (int)departmentInfo.status);
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

BOOL DatabaseModule_Impl::sqlGetDepartmentBySId(IN std::string& sId, OUT module::DepartmentEntity& departmentInfo)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getDepartmentInfoBySIdSql.c_str());
		stmt.bind(1, sId.c_str());

		CppSQLite3Query query = stmt.execQuery();
		if (!query.eof())
		{
			departmentInfo.dId = sId;
			departmentInfo.priority = query.getIntField(2);
			departmentInfo.name = util::stringToCString(query.getStringField(3));
			departmentInfo.parentDepartId = query.getStringField(4);
			departmentInfo.status = query.getIntField(5);
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

BOOL DatabaseModule_Impl::sqlGetAllDepartmentInfo(OUT std::vector<module::DepartmentEntity>& departmentList)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteDB->compileStatement(getAllDepartmentInfoSql.c_str());
		CppSQLite3Query query = stmt.execQuery();
		while (!query.eof())
		{
			module::DepartmentEntity departmentInfo;
			departmentInfo.dId = query.getStringField(1);
			departmentInfo.priority = query.getIntField(2);
			departmentInfo.name = util::stringToCString(query.getStringField(3));
			departmentInfo.parentDepartId = query.getStringField(4);
			departmentInfo.status = query.getIntField(5);
			departmentList.push_back(departmentInfo);
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

BOOL DatabaseModule_Impl::_execDepartmentInfoCreateTableDML()
{
	try
	{
		m_pSqliteDB->execDML(createDepartmentInfoSql.c_str());
		m_pSqliteDB->execDML(createDepartmentInfoIndex.c_str());
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

/******************************************************************************/