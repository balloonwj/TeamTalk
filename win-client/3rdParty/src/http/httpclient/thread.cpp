/**
 * @file    thread.cpp
 * @brief   线程封装
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-6
 * @website www.xiangwangfeng.com
 */

#include "standard_header.h"
#include "thread.h"
#include "process.h"



NAMESPACE_BEGIN(Util)

Thread::Thread(const std::string& thread_name)
:_thread_name(thread_name),
_thread_handle(0),
_thread_id(0)
{
}

Thread::~Thread()
{
	CloseHandle(_thread_handle);
}

void	Thread::startThread()
{
	launchThread();
}

void	Thread::launchThread()
{
	_thread_handle	=	(HANDLE)_beginthreadex(0,0,&Thread::ThreadProc,this,0,&_thread_id);
}

unsigned int	__stdcall	Thread::ThreadProc(void *data)
{
	Thread* thread = (Thread*)data;
	thread->enterThread();
	return 0;
}

void	Thread::enterThread()
{
	setThreadName();	//设置当前Thread名字，方便调试
	run();				
}

void	Thread::waitThreadExit()
{
	if (_thread_handle)
	{
		WaitForSingleObject(_thread_handle,INFINITE);
	}
}

void	Thread::setThreadName()
{
	struct
	{
		DWORD dwType;
		LPCSTR szName;
		DWORD dwThreadID;
		DWORD dwFlags;
	} info;

	info.dwType = 0x1000;
	info.szName = _thread_name.c_str();
	info.dwThreadID = GetCurrentThreadId();
	info.dwFlags = 0;

	__try
	{
		RaiseException (0x406d1388 /*MS_VC_EXCEPTION*/, 0, sizeof (info) / sizeof (ULONG_PTR), (ULONG_PTR*) &info);
	}
	__except (EXCEPTION_CONTINUE_EXECUTION)
	{}
}

NAMESPACE_END(Util)