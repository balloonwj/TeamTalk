/**
 * @file    http_pool.cpp
 * @brief   Http传输池
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-6
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_pool.h"
#include "lock.h"
#include "http_delegate.h"
#include "http_request.h"
#include "http_response.h"
#include "http_client.h"
#include "http_thread.h"

NAMESPACE_BEGIN(Http)

HttpPool* HttpPool::_pool = 0;


HttpWorkItem::HttpWorkItem(HttpRequest* http_request,
						   IAsyncHttpDelegate* delegate)
						   	:_http_request(http_request),_async_delegate(delegate)
{
	assert(_http_request);
}

HttpWorkItem::~HttpWorkItem()
{
	//HttpWorkItem不负责清理内部数据
}



HttpPool::HttpPool()
{
	init();
}

HttpPool::~HttpPool()
{
	releaseAll();
}


HttpPool*	HttpPool::getInstance()
{
	if (_pool == 0)
	{
		_pool = new HttpPool();
	}
	return _pool;
}

void	HttpPool::freeInstance()
{
	SAFE_DELETE(_pool);
}

void	HttpPool::init()
{
	//初始化信号量,退出事件,锁
	_exit_event		=	CreateEvent(NULL,TRUE,FALSE,NULL);
	_work_semaphore	=	CreateSemaphore(NULL,0,INT_MAX,NULL);
	_work_lock		=	new Util::Lock();

	//初始化线程
	for (int i = 0; i < kmax_http_pool_threads_num; i++)
	{	
		std::string thread_name = genThreadName(i);
		HttpThread* http_thread = new HttpThread(thread_name,this);
		_http_threads.push_back(http_thread);
		http_thread->startThread();
	}
}

void	HttpPool::releaseAll()
{
	//释放退出事件
	::SetEvent(_exit_event);

	//调用HttpThread自杀的方法
	for (size_t i = 0; i < _http_threads.size(); i++)
	{
		_http_threads[i]->killSelf();
	}

	//等待HttpThread退出
	for (size_t i = 0; i < _http_threads.size(); i++)
	{
		_http_threads[i]->waitThreadExit();
		delete _http_threads[i];
	}
	_http_threads.clear();

	//清理任务队列
	for (std::list<HttpWorkItem*>::iterator it = _http_work_list.begin();
		it != _http_work_list.end(); it++)
	{
		delete *it;
	}
	_http_work_list.clear();

	//清理句柄
	CloseHandle(_exit_event);
	CloseHandle(_work_semaphore);
	delete _work_lock;
}

void	HttpPool::postRequest(HttpRequest* http_request,IAsyncHttpDelegate* delegate)
{
	const Util::ScopedLock scoped_lock(*_work_lock);
	PTR_VOID(http_request);
	PTR_VOID(delegate);
	HttpWorkItem* item = new HttpWorkItem(http_request,delegate);
	_http_work_list.push_back(item);
	ReleaseSemaphore(_work_semaphore,1,0);
}


HttpWorkItem*	HttpPool::getWork()
{
	const Util::ScopedLock scoped_lock(*_work_lock);
	if (_http_work_list.size() == 0)
	{
		return 0;
	}
	else
	{
		HttpWorkItem* item = *(_http_work_list.begin());
		_http_work_list.pop_front();
		return item;
	}
}

std::string		HttpPool::genThreadName(int index)
{
	char buffer[256] = {0};
	sprintf_s(buffer,256,"HttpThread%d",index);
	return std::string(buffer);
}


NAMESPACE_END(HttpPool)
