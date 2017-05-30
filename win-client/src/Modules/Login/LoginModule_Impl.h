/*******************************************************************************
 *  @file      LoginModule_Impl.h 2014\7\17 19:51:50 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#ifndef LOGINMODULE_IMPL_9020B75A_241C_4250_94F5_66F0EC1C9DD9_H__
#define LOGINMODULE_IMPL_9020B75A_241C_4250_94F5_66F0EC1C9DD9_H__

#include "Modules/ILoginModule.h"
/******************************************************************************/
class ReloginManager;

/**
 * The class <code>LoginModule_Impl</code> 
 *
 */
class LoginModule_Impl final : public module::ILoginModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	LoginModule_Impl();
    /**
     * Destructor
     */
    virtual ~LoginModule_Impl();
    //@}
	virtual void onPacket(imcore::TTPBHeader& header, std::string& pbBody);
public:
	virtual BOOL showLoginDialog();
	virtual void notifyLoginDone();
	virtual void relogin(BOOL bForce);
	virtual BOOL isOfflineByMyself()const;
	virtual void setOfflineByMyself(BOOL b);


private:
	/**@name 服务器端拆包*/
	//@{
	void _kickUserResponse(IN std::string& pbBody);
	//@}

private:
	ReloginManager*				m_pReloginManager;
	BOOL						m_bIsOfflineByMyself;
};
/******************************************************************************/
#endif// LOGINMODULE_IMPL_9020B75A_241C_4250_94F5_66F0EC1C9DD9_H__
