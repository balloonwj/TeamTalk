/******************************************************************************* 
 *  @file      Subject.cpp 2014\12\16 15:33:12 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/ModuleSubject.h"
#include "Modules/ModuleObserver.h"
#include "Modules/UIEventManager.h"
#include "utility/utilCommonAPI.h"
#include <algorithm>
/******************************************************************************/
NAMESPACE_BEGIN(module)

// -----------------------------------------------------------------------------
//  Subject: Public, Constructor

ModuleSubject::ModuleSubject()
{

}

// -----------------------------------------------------------------------------
//  Subject: Public, Destructor

ModuleSubject::~ModuleSubject()
{
	try
	{
		_removeAllObservers();
	}
	catch (...)
	{
		LOG__(ERR, _T("MKObserver: throw unknown exception"));
		assert(FALSE);
	}
}

void ModuleSubject::addObserver(IN void* pObserObject, IN MKODelegate handle)
{
	if (isObserverExist(pObserObject))
		return;
	ModuleObserverCtx* pMkoCtx = new ModuleObserverCtx(handle, pObserObject);
	{
		CAutoLock lock(&m_lockObserver);
		m_vecObservers.push_back(pMkoCtx);
	}
}

void ModuleSubject::removeObserver(IN void* pObserObject)
{
	std::vector<ModuleObserverCtx*> vecRemove;
	CAutoLock lock(&m_lockObserver);
	auto iter = std::remove_if(m_vecObservers.begin(), m_vecObservers.end(), 
		[=](ModuleObserverCtx* pCtxItem)
	{
		bool b = (pObserObject == pCtxItem->m_pObserverObject);
		if (b)
		{
			delete pCtxItem;
			pCtxItem = 0;
		}
		return b;
	}
	);
	if (iter != m_vecObservers.end())
	{
		m_vecObservers.erase(iter,m_vecObservers.end());
	}
}

void ModuleSubject::_removeAllObservers()
{
	CAutoLock lock(&m_lockObserver);
	for (ModuleObserverCtx* pCtx : m_vecObservers)
	{
		delete pCtx;
		pCtx = 0;
	}
	m_vecObservers.clear();
}

void ModuleSubject::asynNotifyObserver(IN const std::string& keyId)
{
	MKOEvent_Impl* pEvent = new MKOEvent_Impl(this);
	_asynNotifyObserver(keyId, pEvent);
}

void ModuleSubject::asynNotifyObserver(IN const std::string& keyId, IN std::string& mkoString)
{
	MKOEvent_Impl* pEvent = new MKOEvent_Impl(this);
	pEvent->m_mkoString = mkoString;
	_asynNotifyObserver(keyId, pEvent);
}

void ModuleSubject::asynNotifyObserver(IN const std::string& keyId, IN Int32 mkoInt)
{
	MKOEvent_Impl* pEvent = new MKOEvent_Impl(this);
	pEvent->m_mkoInt = mkoInt;
	_asynNotifyObserver(keyId, pEvent);
}

void ModuleSubject::asynNotifyObserver(IN const std::string& keyId, IN void* pmkoVoid)
{
	MKOEvent_Impl* pEvent = new MKOEvent_Impl(this);
	pEvent->m_pmkoVoid = pmkoVoid;
	_asynNotifyObserver(keyId, pEvent);
}

void ModuleSubject::asynNotifyObserver(IN const std::string& keyId, IN std::shared_ptr<void> pmkoShardVoid)
{
	MKOEvent_Impl* pEvent = new MKOEvent_Impl(this);
	pEvent->m_pmkoShardVoid = pmkoShardVoid;
	_asynNotifyObserver(keyId, pEvent);
}

BOOL ModuleSubject::isObserverExist(IN const void* pObserObject)
{
	CAutoLock lock(&m_lockObserver);
	auto iterObserver = std::find_if(m_vecObservers.begin(), m_vecObservers.end(),
		[=](ModuleObserverCtx* pMKOCtx)
	{
		return(pObserObject == pMKOCtx->m_pObserverObject);
	}
	);
	return (iterObserver != m_vecObservers.end());
}

void ModuleSubject::_asynNotifyObserver(IN const std::string& keyId, IN MKOEvent_Impl* pEvent)
{
	pEvent->m_keyId = keyId;
	module::getEventManager()->asynFireUIEvent(pEvent);
}

void ModuleSubject::getIObserverHandlersByModuleId(OUT std::vector<MKODelegate>& vecMKOCallbacks)
{
	CAutoLock lock(&m_lockObserver);
	for (ModuleObserverCtx* pContext : m_vecObservers)
	{
		vecMKOCallbacks.push_back(pContext->callback);
	}
}

NAMESPACE_END(module)
/******************************************************************************/