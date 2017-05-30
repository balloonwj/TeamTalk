/******************************************************************************* 
 *  @file      ModuleObserver.cpp 2014\7\23 13:55:19 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/ModuleObserver.h"
#include "Modules/ModuleSubject.h"
#include <vector>
#include <algorithm>
/******************************************************************************/
NAMESPACE_BEGIN(module)

ModuleObserverCtx::ModuleObserverCtx(MKODelegate& hd, void* pObserObject)
: callback(hd)
, m_pObserverObject(pObserObject)
{

}


void MKOEvent_Impl::process()
{
	if (nullptr == m_pMko)
	{
		return;
	}
	std::vector<MKODelegate> lstMKOCallbacks;
	m_pMko->getIObserverHandlersByModuleId(lstMKOCallbacks);
	if (lstMKOCallbacks.empty())
		return;

	for (MKODelegate callback : lstMKOCallbacks)
	{
		try
		{
			callback(m_keyId, std::make_tuple(m_mkoString, m_mkoInt, m_pmkoShardVoid, m_pmkoVoid));
		}
		catch (const std::bad_function_call&)
		{
			LOG__(ERR,_T("bad function call-m_keyId:%d"),m_keyId);
		}
		catch (...)
		{
			LOG__(ERR, _T("unknown exception"));
		}
		
	}
}

void MKOEvent_Impl::release()
{
	delete this;
}

MKOEvent_Impl::MKOEvent_Impl(IN ModuleSubject* p)
: m_pMko(p)
, m_mkoInt(0)
, m_pmkoVoid(nullptr)
{

}

MKOEvent_Impl::~MKOEvent_Impl()
{
}

NAMESPACE_END(module)
/******************************************************************************/