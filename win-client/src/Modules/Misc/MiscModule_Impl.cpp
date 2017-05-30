/******************************************************************************* 
 *  @file      MiscModule.cpp 2014\8\4 9:56:42 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "MiscModule_Impl.h"
#include "utility/utilCommonAPI.h"
#include "utility/Multilingual.h"
#include "utility/utilStrCodingAPI.h"
#include "Modules/ISysConfigModule.h"
#include "../Core/DuiLib/Utils/DialogManager.h"
#include "network/ImCore.h"
#include "security.h"
#include <MMSystem.h>
/******************************************************************************/
namespace module
{
	IMiscModule* getMiscModule()
	{
		static MiscModule_Impl module;
		return &module;
	}
}

// -----------------------------------------------------------------------------
//  MiscModule: Public, Constructor

MiscModule_Impl::MiscModule_Impl()
{

}

// -----------------------------------------------------------------------------
//  MiscModule: Public, Destructor

MiscModule_Impl::~MiscModule_Impl()
{

}

void MiscModule_Impl::release()
{
	delete this;
}

CString MiscModule_Impl::getUsersDir()
{
	return util::getParentAppPath() + _T("users\\");
}

CString MiscModule_Impl::getCurAccountDir()
{
	CString csAccount = _T("default_id");
	module::TTConfig* pCfg = module::getSysConfigModule()->getSystemConfig();
	csAccount = pCfg->csUserId;
	return getUsersDir() + csAccount + _T("\\");
}

CString MiscModule_Impl::getDownloadDir()
{
	return getUsersDir() + _T("download\\");
}

CString MiscModule_Impl::getDataDir()
{
	return util::getParentAppPath() + _T("data\\");
}

CString MiscModule_Impl::getUserTempDir()
{
	return getCurAccountDir() + _T("Temp\\");
}

CString MiscModule_Impl::getDumpDir()
{
	return util::getAppPath() + _T("dumps\\");
}

CString MiscModule_Impl::getFileRecvDir()
{
	return getCurAccountDir() + _T("FileRecv\\");
}

CString MiscModule_Impl::getTTCommonAppdata()
{
	TCHAR szTempDir[MAX_PATH];
	SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, SHGFP_TYPE_DEFAULT, szTempDir);
	CString csDataDir(szTempDir);
	csDataDir += _T("\\TeamTalkOpen\\");

	return csDataDir;
}

CString MiscModule_Impl::getTTCommonAppdataUserDir()
{
	CString csDataDir = getTTCommonAppdata();
	CString csAccount = _T("default_id");
	module::TTConfig* pCfg = module::getSysConfigModule()->getSystemConfig();
	csAccount = pCfg->csUserId;
	csDataDir += csAccount;

	csDataDir += _T("\\");
	return csDataDir;
}
CString MiscModule_Impl::GetAudioFileSavedPath()
{
	return getTTCommonAppdataUserDir() + _T("Audio\\");
}
CString MiscModule_Impl::getEmotionFilesDir()
{
	return getDataDir() + _T("Emotion\\Face\\");
}
void MiscModule_Impl::playSound(const CString& path)
{
	PlaySound(path, NULL, SND_FILENAME | SND_ASYNC);
}

void MiscModule_Impl::quitTheApplication()
{
	DuiLib::DialogManager::getInstance()->closeAllDialogs();
	::PostQuitMessage(0);
	LOG__(APP, _T("quitTheApplication..."));
}

CString MiscModule_Impl::getAppTitle()
{
	return util::getMultilingual()->getStringById(_T("STRID_GLOBAL_CAPTION_NAME"));
}

CString MiscModule_Impl::makeShortTimeDescription(IN UInt32 Intime)
{
	CTime msgTime(Intime);
	CTime currentTime(time(0));
	//CString mor = timeData.Format(_T("-%Y%m%d-%H-%M-%S-"));

	if (Intime > static_cast<UInt32>(time(0)) + 86400)//居然比现在还早 86400为一天，服务器时间可能和本地时间有误差，故加一天时差
	{
		return util::getMultilingual()->getStringById(_T("STRID_MISCMODULE_TIMEDESCRIPTION_FUTURE"));
	}
	else if (currentTime.GetYear() - msgTime.GetYear() == 1)//去年
	{
		return util::getMultilingual()->getStringById(_T("STRID_MISCMODULE_TIMEDESCRIPTION_LASTYEAR"));
	}
	else if (currentTime.GetYear() - msgTime.GetYear() > 1)//几年前
	{
		return util::getMultilingual()->getStringById(_T("STRID_MISCMODULE_TIMEDESCRIPTION_LOONGLONGAGO"));
	}
	//一年以内的
	else if (msgTime.GetMonth() - currentTime.GetMonth())
	{
			return msgTime.Format(_T("%m-%d"));
	}
	else if (msgTime.GetDay() == currentTime.GetDay())
	{
		return msgTime.Format(_T("%H:%M"));
	}
	else if (currentTime.GetDay() - msgTime.GetDay() == 1)
	{
		return util::getMultilingual()->getStringById(_T("STRID_MISCMODULE_TIMEDESCRIPTION_YESTERDAY"));
	}
	else if (currentTime.GetDay() - msgTime.GetDay() > 1)
	{
		return msgTime.Format(_T("%m-%d"));
	}

	return	msgTime.Format(_T("%Y%m%d-%H-%M-%S"));
}

CString MiscModule_Impl::getDownloadDirByToday()
{
	CString csDownloadDir = getDownloadDir();
	CTime timeDate(time(0));
	CString csTime = timeDate.Format(_T("%Y-%m-%d"));
	
	return csDownloadDir + csTime + _T("\\");
}

void MiscModule_Impl::playSysConfigSound()
{
	module::TTConfig* pTTConfig = module::getSysConfigModule()->getSystemConfig();
	if (!pTTConfig)
	{
		return;
	}
	if (pTTConfig->sysBaseFlag & module::BASE_FLAG_NOSOUNDWHENMSG)
	{
		if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_DINGDONG)
		{
			playSound(getDataDir() + _T("Sound\\dingdong.wav"));
		}
		else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_KEYBOARD)
		{
			playSound(getDataDir() + _T("Sound\\keyboard.wav"));
		}
		else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_DINGLIN)
		{
			playSound(getDataDir() + _T("Sound\\message.wav"));
		}
		else if (pTTConfig->sysSoundTypeBaseFlag == module::MUSIC_SOUND_CALLMSG)
		{
			playSound(getDataDir() + _T("Sound\\callmsg.wav"));
		}
	}
}

CString MiscModule_Impl::getDefaultAvatar()
{
	return module::getMiscModule()->getDataDir() + _T("avatar\\");
}

void MiscModule_Impl::asynOpenWebBrowser(CString& url, Int32 nFlag /*= SW_SHOWMAXIMIZED*/)
{
	if (url.IsEmpty())
		return;

	imcore::IMLibCoreStartOperationWithLambda(
		[=]()
	{
		HINSTANCE	hRet = 0;
		hRet = ::ShellExecute(NULL, _T("open"), url, NULL, NULL, nFlag);
		if ((DWORD)hRet <= 32)
		{
			hRet = ::ShellExecute(NULL, _T("open"), _T("IEXPLORE.EXE"), url, NULL, nFlag);
			if ((DWORD)hRet <= 32)
			{
				LOG__(ERR, _T("open IEXPLORE.EXE failed"));
			}
		}
	}
	);
}

void MiscModule_Impl::doProcess1(IN std::string& pData, OUT std::string& pOutData)
{
	LOG__(DEBG, _T("EncryptMsg, pData content:%s")
		, util::stringToCString(pData));
	if (pData.empty())
		return;

	char* pOutDataTemp = 0;
	uint32_t nOutLen = 0;
	int retCode = EncryptMsg(pData.c_str(), pData.length(), &pOutDataTemp, nOutLen);
	if (retCode == 0 && nOutLen > 0 && pOutDataTemp != 0)
	{
		pOutData = std::string(pOutDataTemp,nOutLen);
		Free(pOutDataTemp);
	}
	else
	{
		LOG__(ERR, _T("EncryptMsg Failed!,msg content:%s")
			, util::stringToCString(pData));
		//if failed, copy the source msg data
		pOutData = pData;
	}
}

void MiscModule_Impl::doProcess2(IN std::string& pData, OUT std::string& pOutData)
{
	LOG__(DEBG, _T("DecryptMsg,pData content:%s")
		, util::stringToCString(pData));
	if (pData.empty())
		return;

	char* pOutDataTemp = 0;
	uint32_t nOutLen = 0;
	int retCode = DecryptMsg(pData.c_str(), pData.length(), &pOutDataTemp, nOutLen);
	if (retCode == 0 && nOutLen > 0 && pOutDataTemp != 0)
	{
		pOutData = std::string(pOutDataTemp, nOutLen);
		Free(pOutDataTemp);
	}
	else
	{
		LOG__(ERR, _T("DecryptMsg Failed!,pData content:%s")
			, util::stringToCString(pData));
		//if failed, copy the source msg data
		pOutData = pData;
	}
}

/******************************************************************************/