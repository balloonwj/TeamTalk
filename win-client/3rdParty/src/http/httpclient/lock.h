/**
 * @file    lock.h
 * @brief   同步锁的封装
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-5
 * @website www.xiangwangfeng.com
 */
#pragma once

#include "global_defs.h"
#include "standard_header.h"

NAMESPACE_BEGIN(Util)

class Lock
{
public:
	Lock()	{	InitializeCriticalSection(&_cs);	}
	~Lock()	{	DeleteCriticalSection(&_cs);	}
public:
	void	enter()	{	EnterCriticalSection(&_cs);	}
	void	exit()	{	LeaveCriticalSection(&_cs);	}
private:
	CRITICAL_SECTION	_cs;
};


class ScopedLock
{
public:
	ScopedLock(Lock& lock): _lock(lock) {lock.enter();}
	~ScopedLock() {_lock.exit();}
private:
	Lock& _lock;
};

NAMESPACE_END(Util)