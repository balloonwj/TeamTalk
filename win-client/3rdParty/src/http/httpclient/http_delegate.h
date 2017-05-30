/**
 * @file    http_delegate.h
 * @brief   Http传输的回调接口
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-4
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "http_global.h"

NAMESPACE_BEGIN(Http)

class	HttpRequest;
class	HttpResponse;

//传输进度回调
class	IProgressDelegate
{
public:
	virtual	void	dataWriteProgress(int write_length,int total_length) = 0;
	virtual	void	dataReadProgress(int read_length,int total_length) = 0;
	virtual	~IProgressDelegate() {}
};

//异步传输回调
class IAsyncHttpDelegate : public IProgressDelegate
{
public:
	virtual	void	onError(HTTPERROR error_code,const HttpRequest* request,const HttpResponse* resposne) = 0;
	virtual	void	onSuccess(const HttpRequest* request,const HttpResponse* resposne) = 0;
	virtual	~IAsyncHttpDelegate() {}
};



NAMESPACE_END(Http)
