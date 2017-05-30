/**
 * @file    http_thread.h
 * @brief   Http线程
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-8
 * @website www.xiangwangfeng.com
 */
#pragma once

#include "thread.h"

NAMESPACE_BEGIN(Http)

class HttpPool;
class HttpClient;

class HttpThread : public Util::Thread
{
public:
	HttpThread(const std::string& name,HttpPool* http_pool);
	~HttpThread();
	void	killSelf();
	void	run();
private:
	void	executeHttp();
private:
	HttpPool*		_http_pool;
	HttpClient*		_http_client;
};


NAMESPACE_END(Http)
