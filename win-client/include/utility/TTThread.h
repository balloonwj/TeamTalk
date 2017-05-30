/*******************************************************************************
 *  @file      TTThread.h 2014\7\1 16:04:05 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   windows线程处理的包装
 ******************************************************************************/

#ifndef TTTHREAD_27D478B1_0BAD_4015_A6E5_8AF2DA7739BF_H__
#define TTTHREAD_27D478B1_0BAD_4015_A6E5_8AF2DA7739BF_H__

#include "GlobalDefine.h"
#include "utilityDll.h"
/******************************************************************************/
NAMESPACE_BEGIN(util)

/**
 * The class <code>TTThread</code> 
 *
 */
class UTILITY_CLASS TTThread
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    TTThread();
    /**
     * Destructor
     */
    ~TTThread();
    //@}

public:
	BOOL create();
	void destory();
	BOOL wait(DWORD dwWaitTime);
	inline DWORD getThreadId() { return m_dwThreadID; }

protected:
	virtual UInt32 process();

private:
	static UInt32 __stdcall _threadProc(void *lpParam);

private:
	HANDLE		m_hThread;
	DWORD		m_dwThreadID;
};

NAMESPACE_END(util)
/******************************************************************************/
#endif// TTTHREAD_27D478B1_0BAD_4015_A6E5_8AF2DA7739BF_H__
