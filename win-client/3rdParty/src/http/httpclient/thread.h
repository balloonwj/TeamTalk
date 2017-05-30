/**
 * @file    thread.h
 * @brief   线程封装
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-6
 * @website www.xiangwangfeng.com
 * @note 这个类只在内部使用 所以不提供对线程强杀的方法，也不推荐使用
 */
#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(Util)

class Thread
{
public:
	explicit Thread(const std::string& thread_name);
	virtual ~Thread();
public:
	void	waitThreadExit();
	void	startThread();
	void	enterThread();
	virtual	void	run()	=	0;
	static	unsigned int __stdcall	ThreadProc(void* data);
private:
	void	setThreadName();
	void	launchThread();
protected:
	std::string		_thread_name;
	void *			_thread_handle;
	unsigned int	_thread_id;
	
};

NAMESPACE_END(Util)