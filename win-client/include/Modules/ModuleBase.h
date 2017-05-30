/*******************************************************************************
 *  @file      ModuleBase.h 2014\12\16 14:15:59 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef MODULEBASE_A97FF157_CFAF_41B8_B21C_59ED6AA5A8ED_H__
#define MODULEBASE_A97FF157_CFAF_41B8_B21C_59ED6AA5A8ED_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"
#include "Modules/ModuleObserver.h"
/******************************************************************************/
NAMESPACE_BEGIN(module)

class ModuleSubject;
/**
 * The class <code>ModuleBase</code> 
 *
 */
class MODULE_CLASS ModuleBase
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    ModuleBase();
    /**
     * Destructor
     */
    ~ModuleBase();
    //@}

	/**@name Observer Pattern Implenment*/
	//@{
public:
	void addObserver(IN void* pObserObject, IN MKODelegate handle);
	void removeObserver(IN void* pObserObject);
	void asynNotifyObserver(IN const std::string& keyId);
	void asynNotifyObserver(IN const std::string& keyId, IN std::string& mkoString);
	void asynNotifyObserver(IN const std::string& keyId, IN Int32 mkoInt);
	void asynNotifyObserver(IN const std::string& keyId, IN void* pmkoVoid);
	void asynNotifyObserver(IN const std::string& keyId, IN std::shared_ptr<void> pmkoShardVoid);
	//@}

	/**@name reserve another functions*/
	//@{
public:
	//@}

private:
	ModuleSubject*			m_pModuleSubject;
};

NAMESPACE_END(module)
/******************************************************************************/
#endif// MODULEBASE_A97FF157_CFAF_41B8_B21C_59ED6AA5A8ED_H__
