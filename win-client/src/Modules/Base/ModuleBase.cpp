/******************************************************************************* 
 *  @file      ModuleBase.cpp 2014\12\16 14:16:02 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/ModuleSubject.h"
#include "Modules/ModuleBase.h"
/******************************************************************************/
NAMESPACE_BEGIN(module)

// -----------------------------------------------------------------------------
//  ModuleBase: Public, Constructor

ModuleBase::ModuleBase()
:m_pModuleSubject(0)
{
	m_pModuleSubject = new ModuleSubject();
}

// -----------------------------------------------------------------------------
//  ModuleBase: Public, Destructor

ModuleBase::~ModuleBase()
{
	delete m_pModuleSubject;
	m_pModuleSubject = 0;
}

void ModuleBase::addObserver(IN void* pObserObject, IN MKODelegate handle)
{
	m_pModuleSubject->addObserver(pObserObject, handle);
}

void ModuleBase::removeObserver(IN void* pObserObject)
{
	m_pModuleSubject->removeObserver(pObserObject);
}

void ModuleBase::asynNotifyObserver(IN const std::string& keyId)
{
	m_pModuleSubject->asynNotifyObserver(keyId);
}

void ModuleBase::asynNotifyObserver(IN const std::string& keyId, IN std::string& mkoString)
{
	m_pModuleSubject->asynNotifyObserver(keyId,mkoString);
}

void ModuleBase::asynNotifyObserver(IN const std::string& keyId, IN Int32 mkoInt)
{
	m_pModuleSubject->asynNotifyObserver(keyId, mkoInt);
}

void ModuleBase::asynNotifyObserver(IN const std::string& keyId, IN void* pmkoVoid)
{
	m_pModuleSubject->asynNotifyObserver(keyId, pmkoVoid);
}

void ModuleBase::asynNotifyObserver(IN const std::string& keyId, IN std::shared_ptr<void> pmkoShardVoid)
{
	m_pModuleSubject->asynNotifyObserver(keyId, pmkoShardVoid);
}

NAMESPACE_END(module)
/******************************************************************************/