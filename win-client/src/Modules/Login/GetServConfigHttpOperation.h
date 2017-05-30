 /*******************************************************************************
 *  @file      PHPConectOperation.h 2014\9\17 19:56:59 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef PHPCONECTOPERATION_E51819EF_B832_486D_A1D0_B9873C45FC4E_H__
#define PHPCONECTOPERATION_E51819EF_B832_486D_A1D0_B9873C45FC4E_H__

#include "Modules/IHttpPoolModule.h"
#include <string>
/******************************************************************************/
enum
{
	GETSERV_CONFIT_SUCC = 0,
	GETSERV_CONFIT_FAIL,
};

class GetServConfigParam
{
public:
	UInt8		result = GETSERV_CONFIT_FAIL;
};

/**
 * The class <code>PHPConectOperation</code> 
 *
 */
class GetServConfigHttpOperation : public module::IHttpOperation
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	GetServConfigHttpOperation(module::IOperationDelegate callback, GetServConfigParam& param);
    /**
     * Destructor
     */
	virtual  ~GetServConfigHttpOperation();
    //@}
public:
	virtual void processOpertion();
	virtual void release();

private:
	GetServConfigParam			m_param;
};
/******************************************************************************/
#endif// PHPCONECTOPERATION_E51819EF_B832_486D_A1D0_B9873C45FC4E_H__