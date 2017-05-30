/**
 * @file    http_pool.h
 * @brief   Http传输池
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-6
 * @website www.xiangwangfeng.com
 */
#pragma once
#pragma warning(disable:4251)

#include <vector>
#include <list>
#include "global_defs.h"

NAMESPACE_BEGIN(Util)
class Lock;
NAMESPACE_END(Util)

NAMESPACE_BEGIN(Http)

class	HttpPool;
class	HttpClient;
class	HttpRequest;
class	IAsyncHttpDelegate;
class	HttpThread;

struct HttpWorkItem 
{
	HttpRequest*		_http_request;
	IAsyncHttpDelegate*	_async_delegate;
	HttpWorkItem(HttpRequest* http_request,IAsyncHttpDelegate* delegate);
	~HttpWorkItem();
};


class HTTP_CLASS HttpPool	
{
public:
	~HttpPool();
	static HttpPool*	getInstance();
	static void			freeInstance();
	
	//异步调用HTTP传输，外部必须自己控制http_request和delegate的生存期
	void				postRequest(HttpRequest* http_request,IAsyncHttpDelegate* delegate);
private:
	HttpPool();
	void		init();
	void		releaseAll();
	HttpWorkItem*	getWork();
	std::string		genThreadName(int index);
private:
	std::vector<HttpThread*>	_http_threads;		//线程列表
	std::list<HttpWorkItem*>	_http_work_list;	//工作对象
	static	HttpPool*			_pool;				//静态池对象
	void*						_exit_event;		//退出事件
	void*						_work_semaphore;	//工作信号量
	Util::Lock*					_work_lock;			//线程池队列的锁
	friend	class	HttpThread;
};

NAMESPACE_END(Http)
