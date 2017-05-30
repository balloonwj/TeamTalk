/*******************************************************************************
 *  @file      IEvent.h 2014\7\18 15:04:19 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#ifndef IEVENT_83A4713C_930E_426A_98F5_8BB8747994D3_H__
#define IEVENT_83A4713C_930E_426A_98F5_8BB8747994D3_H__

#include "GlobalDefine.h"
#include "utility/utilCommonAPI.h"
/******************************************************************************/
namespace imcore
{
	struct Exception;
}
NAMESPACE_BEGIN(module)

/**
 * The class <code>IEvent</code> 
 *
 */
struct IEvent
{
public:
	virtual void process() = 0;
	virtual void onException(imcore::Exception* e)
	{
		LOG__(ERR, _T("IEvent exception,%d"));
		assert(FALSE);
	}
	virtual void release() = 0;
};

/**
* The class <code>Timer的Event，目前只是当做tag</code>
*
*/
struct ITimerEvent : public IEvent
{};

NAMESPACE_END(module)
/******************************************************************************/
#endif// IEVENT_83A4713C_930E_426A_98F5_8BB8747994D3_H__
