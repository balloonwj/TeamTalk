/******************************************************************************* 
 *  @file      TTThread.cpp 2014\7\1 16:04:19 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   windows线程处理的包装
 ******************************************************************************/

#include "stdafx.h"
#include "utility/TTThread.h"

/******************************************************************************/
NAMESPACE_BEGIN(util)

// -----------------------------------------------------------------------------
//  TTThread: Public, Constructor

TTThread::TTThread()
:m_hThread(0)
{

}

// -----------------------------------------------------------------------------
//  TTThread: Public, Destructor

TTThread::~TTThread()
{
	if (m_hThread)
		::CloseHandle(m_hThread);
	m_hThread = 0;
}

BOOL TTThread::create()
{
	m_hThread = (HANDLE)_beginthreadex(0,0, _threadProc, this, 0, (unsigned*)&m_dwThreadID);

	if (m_hThread < (HANDLE)2)
	{
		m_hThread = 0;
		m_dwThreadID = 0;
	}

	return m_hThread >(HANDLE)1;
}

void TTThread::destory()
{
	if (m_hThread)
	{
		::TerminateThread(m_hThread, 0);
		WaitForSingleObject(m_hThread, 500);
		::CloseHandle(m_hThread);
		m_hThread = 0;
		m_dwThreadID = 0;
	}
}

BOOL TTThread::wait(DWORD dwWaitTime)
{
	if (m_hThread == 0)
		return TRUE;
	return (::WaitForSingleObject(m_hThread, dwWaitTime) != WAIT_TIMEOUT);
}

UInt32 TTThread::process()
{
	return 0;
}

UInt32 __stdcall TTThread::_threadProc(void *lpParam)
{
	TTThread* pThread = (TTThread*)lpParam;
	assert(pThread);
	if (pThread != 0)
	{
		pThread->process();
	}
	return 0;
}

NAMESPACE_END(util)
/******************************************************************************/