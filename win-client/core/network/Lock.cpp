/*******************************************************************************
*  @file      ImCore.h 2014\09\10 13:28:49 $
*  @author    À¶ºü<lanhu@mogujie.com>
*  @brief
******************************************************************************/
#include "network/Lock.h"

CFastLock::CFastLock()
{
#ifdef _MSC_VER
	InitializeCriticalSection(&m_critical_section);
#else
	pthread_mutex_init(&m_mutex, NULL);
#endif
}

CFastLock::~CFastLock()
{
#ifdef _MSC_VER
	DeleteCriticalSection(&m_critical_section);
#else
	pthread_mutex_destroy(&m_mutex);
#endif
}

void CLock::lock()
{
#ifdef _MSC_VER
    EnterCriticalSection(&m_lock.m_critical_section);
#else
    pthread_mutex_lock(&m_lock);
#endif
}

void CLock::unlock()
{
#ifdef _MSC_VER
	LeaveCriticalSection(&m_lock.m_critical_section);
#else
	pthread_mutex_unlock(&m_lock.m_mutex);
#endif
}

#ifndef _MSC_VER
bool CLock::try_lock()
{
    return pthread_mutex_trylock(&m_lock.m_mutex) == 0;
}
#endif

CAutoLock::CAutoLock(CLock* pLock)
{
    m_pLock = pLock;
    if(NULL != m_pLock)
        m_pLock->lock();
}

CAutoLock::~CAutoLock()
{
    if(NULL != m_pLock)
        m_pLock->unlock();
}