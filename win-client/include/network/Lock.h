/*******************************************************************************
*  @file      ImCore.h 2014\09\10 13:28:49 $
*  @author    À¶ºü<lanhu@mogujie.com>
*  @brief     
******************************************************************************/

#ifndef __LOCK_H__
#define __LOCK_H__

#include "network/networkdll.h"
#include "network/ostype.h"

class NETWORK_DLL CFastLock
{
public:
	CFastLock();
	~CFastLock();

public:
#ifdef _MSC_VER
	CRITICAL_SECTION m_critical_section;
#else
	pthread_mutex_t m_mutex;
#endif
};


class NETWORK_DLL CLock
{
public:
    void lock();
    void unlock();
#ifndef _MSC_VER
    virtual bool try_lock();
#endif
private:
	CFastLock	m_lock;
};

class NETWORK_DLL CAutoLock
{
public:
    CAutoLock(CLock* pLock);
    virtual ~CAutoLock();
private:
    CLock* m_pLock;
};

#endif
