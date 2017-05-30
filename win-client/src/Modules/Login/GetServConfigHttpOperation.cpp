/******************************************************************************* 
 *  @file      PHPConectOperation.cpp 2014\9\17 20:01:16 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "GetServConfigHttpOperation.h"
#include "utility/utilStrCodeAPI.h"
#include "Modules/ISysConfigModule.h"
#include "http/httpclient/http.h"
#include "json/reader.h"

GetServConfigHttpOperation::GetServConfigHttpOperation(module::IOperationDelegate callback, GetServConfigParam& param)
:IHttpOperation(callback)
,m_param(param)
{

}



GetServConfigHttpOperation::~GetServConfigHttpOperation()
{

}

void GetServConfigHttpOperation::processOpertion()
{
	module::TTConfig* pCfg = module::getSysConfigModule()->getSystemConfig();
	std::string& phpAddr = pCfg->phpServerAddr;
	std::string url = phpAddr + "/config/json";
	
	GetServConfigParam* pPamram = new GetServConfigParam();
	Http::HttpResponse	response;
	Http::HttpClient	client;
	Http::HttpRequest	request("post", url);
	if (!client.execute(&request, &response))
	{
		CString csTemp = util::stringToCString(url);
		pPamram->result = GETSERV_CONFIT_FAIL;
		LOG__(ERR,_T("GetServConfigHttpOperation failed %s"), csTemp);
		asyncCallback(std::shared_ptr<void>(pPamram));
		client.killSelf();
		return;
	}
	std::string body = response.getBody();
	client.killSelf();
	//json½âÎö
	try
	{
		Json::Reader reader;
		Json::Value root;
		if (!reader.parse(body, root))
		{
			CString csTemp = util::stringToCString(body);
			LOG__(ERR, _T("GetServConfigHttpOperation parse data failed,%s"), csTemp);
			pPamram->result = GETSERV_CONFIT_FAIL;
			goto End;
		}
		std::string loginAddr = root.get("login", "").asString();
		size_t startIndex = loginAddr.find(':');
		if (startIndex == std::string::npos)
		{
			CString csTemp = util::stringToCString(body);
			LOG__(ERR, _T("GetServConfigHttpOperation parse login IP failed,%s"), csTemp);
			pPamram->result = GETSERV_CONFIT_FAIL;
			goto End;
		}
		std::string loginIP = loginAddr.substr(0, startIndex);
		std::string loginPort = loginAddr.substr(startIndex + 1
			, loginAddr.length() - startIndex);
		pCfg->loginServIP = util::stringToCString(loginIP);
		pCfg->loginServPort = util::cstringToInt32(util::stringToCString(loginPort));
		if (0 == pCfg->loginServPort)
		{
			CString csTemp = util::stringToCString(body);
			LOG__(ERR, _T("GetServConfigHttpOperation parse login IP failed,%s"), csTemp);
			pPamram->result = GETSERV_CONFIT_FAIL;
			goto End;
		}
		std::string fileAddr = root.get("file", "").asString();
		pCfg->fileSysAddr = _T("http://") + util::stringToCString(fileAddr) + _T("/");
		pPamram->result = GETSERV_CONFIT_SUCC;
	}
	catch (...)
	{
		CString csTemp = util::stringToCString(body);
		LOG__(ERR,_T("GetServConfigHttpOperation parse json execption,%s"), csTemp);
		pPamram->result = GETSERV_CONFIT_FAIL;
	}

End:
	asyncCallback(std::shared_ptr<void>(pPamram));
}

void GetServConfigHttpOperation::release()
{
	delete this;
}

/******************************************************************************/