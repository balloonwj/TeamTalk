/******************************************************************************* 
 *  @file      HttpPoolModule_Impl.cpp 2014\7\25 11:20:58 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief	   http operation thread pool 
 ******************************************************************************/

#include "stdafx.h"
#include "HttpPoolModule_Impl.h"

/******************************************************************************/
namespace module
{
	module::IHttpPoolModule* getHttpPoolModule()
	{
		static HttpPoolModule_Impl module;
		return &module;
	}
}

namespace
{
	HttpPoolModule_Impl* m_pInstance = 0;
	const UInt8   MAX_THEAD_COUNT = 1;
}
// -----------------------------------------------------------------------------
//  HttpPoolModule_Impl: Public, Constructor

HttpPoolModule_Impl::HttpPoolModule_Impl()
{
	m_vecHttpThread.reserve(MAX_THEAD_COUNT);
	m_hSemaphore = ::CreateSemaphore(NULL, 0, LONG_MAX, NULL);
	m_pInstance = this;
}

// -----------------------------------------------------------------------------
//  HttpPoolModule_Impl: Public, Destructor

HttpPoolModule_Impl::~HttpPoolModule_Impl()
{

}

void HttpPoolModule_Impl::pushHttpOperation(module::IHttpOperation* pOperaion, BOOL bHighPriority /*= FALSE*/)
{
	if (NULL == pOperaion)
	{
		return;
	}

	CAutoLock lock(&m_mtxLock);
	if (bHighPriority)
		m_lstHttpOpers.push_front(pOperaion);
	else
		m_lstHttpOpers.push_back(pOperaion);
	_launchThread();
	::ReleaseSemaphore(m_hSemaphore, 1, NULL);

	return;
}

void HttpPoolModule_Impl::shutdown()
{
	_cancelAllOperations();

	for (TTHttpThread* pThread : m_vecHttpThread)
	{
		pThread->m_bContinue = FALSE;
		::ReleaseSemaphore(m_hSemaphore, 1, NULL);
	}

	for (TTHttpThread* pThread : m_vecHttpThread)
	{
		pThread->shutdown();
		delete pThread;
		pThread = 0;
	}

	return;
}

BOOL HttpPoolModule_Impl::_launchThread()
{
	if ((int)m_vecHttpThread.size() >= MAX_THEAD_COUNT)
	{
		return TRUE;
	}

	TTHttpThread* pThread = new TTHttpThread();
	PTR_FALSE(pThread);
	if (!pThread->create())
	{
		return FALSE;
	}
	Sleep(300);

	m_vecHttpThread.push_back(pThread);

	return TRUE;
}

void HttpPoolModule_Impl::_cancelAllOperations()
{
	CAutoLock lock(&m_mtxLock);
	for (module::IHttpOperation* pOper : m_lstHttpOpers)
	{
		try
		{
			pOper->release();
		}
		catch (...)
		{
			LOG__(ERR, _T("cancel operation unknown exception"));
		}
	}
	m_lstHttpOpers.clear();
}

/******************************************************************************/

TTHttpThread::TTHttpThread()
:m_bContinue(TRUE)
{

}

void TTHttpThread::shutdown()
{
	if (!wait(2000))
		destory();
}

UInt32 TTHttpThread::process()
{
	module::IHttpOperation * pHttpOper = NULL;
	HttpPoolModule_Impl *pPool = m_pInstance;
	while (m_bContinue)
	{
		if (WAIT_OBJECT_0 != ::WaitForSingleObject(pPool->m_hSemaphore, INFINITE))
		{
			break;
		}

		if (!m_bContinue)
		{
			break;
		}

		{
			CAutoLock lock(&(pPool->m_mtxLock));
			if (pPool->m_lstHttpOpers.empty())
				pHttpOper = NULL;
			else
			{
				pHttpOper = pPool->m_lstHttpOpers.front();
				pPool->m_lstHttpOpers.pop_front();
			}
		}

		try
		{
			if (m_bContinue && pHttpOper)
			{
				pHttpOper->process();
				pHttpOper->release();
			}
		}
		catch (...)
		{
			LOG__(ERR, _T("TTHttpThread: Failed to execute opertaion(0x%p)"), pHttpOper);
		}
	}

	return 0;
}
