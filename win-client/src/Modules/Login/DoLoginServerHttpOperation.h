/*******************************************************************************
 *  @file      DoLoginServerHttpOperation.h 2014\12\23 10:08:47 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef DOLOGINSERVERHTTPOPERATION_D4296DCE_0662_447D_9F79_B058C0B9FC6D_H__
#define DOLOGINSERVERHTTPOPERATION_D4296DCE_0662_447D_9F79_B058C0B9FC6D_H__

#include "Modules/IHttpPoolModule.h"
#include <string>
/******************************************************************************/
enum
{
	DOLOGIN_SUCC = 0,
	DOLOGIN_FAIL,
};

class DoLoginServerParam
{
public:
	UInt8		result = DOLOGIN_FAIL;
	CString		resMsg;
};

/**
 * The class <code>PHPConectOperation</code> 
 *
 */
class DoLoginServerHttpOperation : public module::IHttpOperation
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	DoLoginServerHttpOperation(IN module::IOperationDelegate callback,IN DoLoginServerParam& param);
    /**
     * Destructor
     */
	virtual  ~DoLoginServerHttpOperation() = default;
    //@}
public:
	virtual void processOpertion();
	virtual void release();

private:
	DoLoginServerParam			m_param;
};
/******************************************************************************/
#endif// DOLOGINSERVERHTTPOPERATION_D4296DCE_0662_447D_9F79_B058C0B9FC6D_H__