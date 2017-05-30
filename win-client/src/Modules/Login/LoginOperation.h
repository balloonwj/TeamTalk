/*******************************************************************************
 *  @file      LoginOperation.h 2014\7\30 15:32:25 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef LOGINOPERATION_9610A313_DC31_429E_B9E9_09A34ABA8063_H__
#define LOGINOPERATION_9610A313_DC31_429E_B9E9_09A34ABA8063_H__

#include "Modules/IModuleInterface.h"
#include "ProtocolBuffer/im.Login.pb.h"
/******************************************************************************/
enum
{
	LOGIN_FAIL = -1,            //µÇÂ½Ê§°Ü
	LOGIN_OK = 0,               //µÇÂ½³É¹¦
};

struct LoginParam
{
public:
	Int8            result = LOGIN_FAIL;
	UInt8			server_result = IM::BaseDefine::REFUSE_REASON_NONE;
	UInt8           mySelectedStatus = IM::BaseDefine::USER_STATUS_ONLINE;
	UInt32          serverTime = 0;
	CString			csUserName;
	CString			errInfo;
	std::string		password;
};

/**
 * The class <code>LoginOperation</code> 
 *
 */
class LoginOperation : public module::ICallbackOpertaion
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	LoginOperation(module::IOperationDelegate callback, LoginParam& param);
    /**
     * Destructor
     */
    virtual ~LoginOperation();
    //@}

public:
	virtual void processOpertion();
	virtual void release();

private:
	LoginParam			m_loginParam;
};
/******************************************************************************/
#endif// LOGINOPERATION_9610A313_DC31_429E_B9E9_09A34ABA8063_H__
