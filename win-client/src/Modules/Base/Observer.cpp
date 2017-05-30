/******************************************************************************* 
 *  @file      Observer.cpp 2014\7\23 13:55:19 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/Observer.h"
#include "ModuleSubject.h"
#include <vector>
#include <algorithm>
/******************************************************************************/
NAMESPACE_BEGIN(module)

MKOContext::MKOContext(UInt16 mId, MKOHandler& hd, void* pObserObject)
: moduleId(mId)
, keyId(0)
, handler(hd)
, m_pObserverObject(pObserObject)
{

}


void ObserverEvent_Impl::process()
{
	if (nullptr == m_pMko)
	{
		return;
	}
	std::vector<MKOHandler> lstObserverHandlers;
	m_pMko->getIObserverHandlersByModuleId(m_moduleId,lstObserverHandlers);
	if (lstObserverHandlers.empty())
	{
		return;
	}
	for (MKOHandler handler : lstObserverHandlers)
	{
		try
		{
			handler(m_keyId, std::make_tuple(m_mkoString, m_mkoInt, m_pmkoShardVoid, m_pmkoVoid));
		}
		catch (const std::bad_function_call&)
		{
			LOG__(ERR,_T("bad function call-m_moduleId:%d ,m_keyId:%d"),m_moduleId,m_keyId);
		}
		catch (...)
		{
			LOG__(ERR, _T("unknown exception"));
		}
		
	}
}

void ObserverEvent_Impl::release()
{
	delete this;
}

ObserverEvent_Impl::ObserverEvent_Impl(IN ModuleSubject* p)
: m_pMko(p)
, m_mkoInt(0)
, m_pmkoVoid(nullptr)
{

}

ObserverEvent_Impl::~ObserverEvent_Impl()
{
}

NAMESPACE_END(module)
/******************************************************************************/