/******************************************************************************* 
 *  @file      DoLoginServerHttpOperation.cpp 2014\12\23 10:10:54 $
 *  @author    大佛<大佛@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "DoLoginServerHttpOperation.h"
#include "utility/utilStrCodingAPI.h"
#include "utility/Multilingual.h"
#include "Modules/ISysConfigModule.h"
#include "http/httpclient/http.h"
#include "json/reader.h"

DoLoginServerHttpOperation::DoLoginServerHttpOperation(IN module::IOperationDelegate callback,IN DoLoginServerParam& param)
:IHttpOperation(callback)
,m_param(param)
{

}
void DoLoginServerHttpOperation::processOpertion()
{
	module::TTConfig* pCfg = module::getSysConfigModule()->getSystemConfig();
	LOG__(APP, _T("loginAddr = %s"), pCfg->loginServIP);
	std::string& loginAddr = util::cStringToString(pCfg->loginServIP);
	std::string url = loginAddr;
	
	DoLoginServerParam* pPamram = new DoLoginServerParam();
	pPamram->resMsg = util::getMultilingual()->getStringById(_T("STRID_LOGINDIALOG_LOGIN_HTTP_DEFERROR"));
	Http::HttpResponse	response;
	Http::HttpClient	client;
    //对于登录：url=http://192.168.226.128:8080/msg_server
	Http::HttpRequest	request("get", url);
	if (!client.execute(&request, &response))
	{
		CString csTemp = util::stringToCString(url);
		pPamram->result = DOLOGIN_FAIL;
		LOG__(ERR,_T("failed %s"), csTemp);
		asyncCallback(std::shared_ptr<void>(pPamram));
		client.killSelf();
		return;
	}
    /**
        {
           "backupIP" : "localhost",
           "code" : 0,
           "discovery" : "http://127.0.0.1/api/discovery",
           "msfsBackup" : "http://127.0.0.1:8700/",
           "msfsPrior" : "http://127.0.0.1:8700/",
           "msg" : "",
           "port" : "8000",
           "priorIP" : "localhost"
        }
     */
	std::string body = response.getBody();
	client.killSelf();
	//json解析
	try
	{
		Json::Reader reader;
		Json::Value root;
		if (!reader.parse(body, root))
		{
			CString csTemp = util::stringToCString(body);
			LOG__(ERR, _T("parse data failed,%s"), csTemp);
			pPamram->result = DOLOGIN_FAIL;
			pPamram->resMsg = util::getMultilingual()->getStringById(_T("STRID_LOGINDIALOG_LOGIN_HTTP_JSONERROR"));
			goto End;
		}
		int nCode = root.get("code", "").asInt();
		if (0 == nCode)//登陆成功
		{
			LOG__(APP, _T("get msgSvr IP succeed!"));
			pCfg->msgSevPriorIP = root.get("priorIP", "").asString();
			pCfg->msgSevBackupIP = root.get("backupIP", "").asString();
			std::string strPort = root.get("port", "").asString();
			pCfg->msgServPort = util::stringToInt32(strPort);

			pCfg->fileSysAddr = util::stringToCString(root.get("msfsPrior", "").asString());
			pCfg->fileSysBackUpAddr = util::stringToCString(root.get("msfsBackup", "").asString());
			pPamram->result = DOLOGIN_SUCC;
		}
		else
		{
			LOG__(ERR, _T("get msgSvr IP failed! Code = %d"),nCode);
			pPamram->result = DOLOGIN_FAIL;
			CString csRetMsgTemp = util::stringToCString(root.get("msg", "").asString());
			if (!csRetMsgTemp.IsEmpty())
				pPamram->resMsg = csRetMsgTemp;
		}
	}
	catch (...)
	{
		CString csTemp = util::stringToCString(body);
		LOG__(ERR,_T("parse json execption,%s"), csTemp);
		pPamram->result = DOLOGIN_FAIL;
		pPamram->resMsg = util::getMultilingual()->getStringById(_T("STRID_LOGINDIALOG_LOGIN_HTTP_JSONERROR"));
	}

End:
	asyncCallback(std::shared_ptr<void>(pPamram));
}

void DoLoginServerHttpOperation::release()
{
	delete this;
}

/******************************************************************************/