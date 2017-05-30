/******************************************************************************* 
 *  @file      DatabaseModule_ImageDB_Impl.cpp 2014\12\30 14:06:32 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "DatabaseModule_Impl.h"
#include "utility/CppSQLite3.h"
#include "utility/utilStrCodingAPI.h"

/******************************************************************************/
namespace
{
	const std::string createImImageSql =
		"CREATE TABLE IF NOT EXISTS imimage"
		"("
		"    [id]                   INTEGER PRIMARY KEY,"
		"    [hashcode]             INTEGER DEFAULT 0 NOT NULL UNIQUE,"		//根据url生成的hash code
		"    [localPath]			TEXT NOT NULL,"							//图片本地相对路径
		"    [urlPath]				TEXT NOT NULL"							//图片url地址
		");";
	const std::string createImImageIndex =
		"CREATE unique INDEX IF NOT EXISTS hashcode_idx ON imimage(hashcode);";
	const std::string insertImImageSql
		= "INSERT OR REPLACE INTO imimage(hashcode,localPath,urlPath) "
		"VALUES(?, ? ,? );";
	const std::string getImImageByHashcodeSql
		= "select * from imimage where hashcode=? limit 1";
	const std::string updateImImageByHashcodeSql
		= "update imimage set localPath=? where hashcode=?";
}

BOOL DatabaseModule_Impl::_execImageCreateTableDML()
{
	try
	{
		m_pSqliteGlobalDB->execDML(createImImageSql.c_str());
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

BOOL DatabaseModule_Impl::sqlInsertImImageEntity(const module::ImImageEntity& entity)
{
	try
	{
		CppSQLite3Statement stmt = m_pSqliteGlobalDB->compileStatement(insertImImageSql.c_str());
		stmt.bind(1, (int)entity.hashcode);
		stmt.bind(2, entity.filename.c_str());
		stmt.bind(3, entity.urlPath.c_str());
		stmt.execDML();
	}
	catch (CppSQLite3Exception& sqliteException)
	{
#ifdef _DEBUG
		MessageBoxA(0, sqliteException.errorMessage(), "BD ERROR", MB_OK | MB_ICONHAND);
#endif
		CString csErrMsg = util::stringToCString(sqliteException.errorMessage(), CP_UTF8);
		LOG__(ERR, _T("DatabaseModule_Impl db sqlInsertImImageEntity failed,error msg:%s"), csErrMsg);
		return FALSE;
	}
	catch (...)
	{
		LOG__(ERR, _T("db unknown exception"));
		return FALSE;
	}

	return TRUE;
}

BOOL DatabaseModule_Impl::sqlGetImImageEntityByHashcode(UInt32 hashcode, module::ImImageEntity& entity)
{
	try
	{
		CppSQLite3Statement stmt;
		stmt = m_pSqliteGlobalDB->compileStatement(getImImageByHashcodeSql.c_str());
		stmt.bind(1, (int)hashcode);

		CppSQLite3Query query = stmt.execQuery();
		std::string sId;
		std::string avatarPath;
		if (!query.eof())
		{
			entity.hashcode = hashcode;
			entity.filename = query.getStringField(2);
			entity.urlPath = query.getStringField(3);
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
		LOG__(ERR, _T("db sqlGetImImageEntityByHashcode failed,error msg:%s"),
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

BOOL DatabaseModule_Impl::sqlUpdateImImageEntity(UInt32 hashcode, module::ImImageEntity& entity)
{
	try
	{
		//"update imimage set localPath=? where hashcode=?";
		CppSQLite3Statement stmt = m_pSqliteGlobalDB->compileStatement(updateImImageByHashcodeSql.c_str());
		stmt.bind(1, entity.filename.c_str());
		stmt.bind(2, (int)hashcode);
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
		LOG__(ERR, _T("db sqlUpdateImImageEntity failed,error msg:%s"), csErrMsg);
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