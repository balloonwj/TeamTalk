/**
 * @file    http_client.h
 * @brief   Http传输类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"
#include "http_global.h"
#include "proxy_config.h"

namespace Util
{
	class Lock;
}

NAMESPACE_BEGIN(Http)

class	ProxySocket;
class	HttpRequest;
class	HttpResponse;
class	IHttpPostFile;
class	IProgressDelegate;

//Http传输类
class	HTTP_CLASS	HttpClient
{
public:
	HttpClient(bool keep_connection = false);
	~HttpClient();
public:
	//执行Http参数方法
	bool			execute(HttpRequest* request,HttpResponse* respone);							//执行Http传输
	static	void	setProxy(const ProxyConfig*	proxy_config);										//设置代理
	HTTPERROR		getErrorCode()	const {	return	_http_error;}									//返回错误码
	void			setProgressDelegate(IProgressDelegate* delegate)	{ _delegate = delegate;}	//设置进度委托
	void			killSelf();																		//弃用当前HttpClient

private:
	void		reset();																		//重设当前HttpClient
	void		setErrorCode(HTTPERROR http_error);
	bool		httpGet();
	bool		httpPost();
	bool		getResponse();
	bool		downloadHeader(std::string&	body_header);
	bool		downloadBody(const std::string& body_header);
	bool		downloadFixedSizeBody(const std::string& body_header,int content_length);
	bool		downloadChunkedBody(const std::string& body_header);
	bool		continueToReceiveBody(std::string&	body);
	bool		sendHeader();
	bool		sendBody();
	bool		doMultipartPost();
	bool		uploadFile(IHttpPostFile*	post_file);
	void		onDataReadProgress(int read_length,int total_length);
	DECLARE_NON_COPYABLE(HttpClient)
private:
	ProxySocket*			_proxy_socket;			//支持代理的Socket类
	HTTPERROR				_http_error;			//Http传输错误码
	bool					_keep_connection;		//是否保持连接
	HttpRequest*			_request;				//Http请求方法
	HttpResponse*			_response;				//Http反馈数据
	IProgressDelegate*		_delegate;				//Http传输的委托
	bool					_is_valid;				//是否可用(如果调用了killSelf接口这个Client就弃用)
	Util::Lock*				_is_valid_lock;			//是否可用的同步锁

	friend	class HttpThread;
};

NAMESPACE_END(Http)