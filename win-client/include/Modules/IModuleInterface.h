/*******************************************************************************
 *  @file      IModuleInterface.h 2014\12\18 13:37:56 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef IMODULEINTERFACE_26428D8B_4585_4660_95B3_94E8735700E9_H__
#define IMODULEINTERFACE_26428D8B_4585_4660_95B3_94E8735700E9_H__

#include "GlobalDefine.h"
#include "Modules/IEvent.h"
#include "Modules/UIEventManager.h"
#include "Modules/ModuleDll.h"
#include "network/Operation.h"
#include <functional>
#include <string>
/******************************************************************************/
namespace imcore
{
	class TTPBHeader;
}

NAMESPACE_BEGIN(module)

typedef std::function<void(std::shared_ptr<void>)> IOperationDelegate;

/**
* The class <code>操作回调事件，主要用于在任务执行过程中通知回调</code>
*
*/
class CallbackOperationEvent : public module::IEvent
{
public:
	CallbackOperationEvent(IOperationDelegate& callback, std::shared_ptr<void> param)
		:m_callback(callback)
		, m_param(param)
	{

	}
	virtual ~CallbackOperationEvent()
	{}

	virtual void process()
	{
		m_callback(m_param);
	}
	virtual void release(){ delete this; }

private:
	IOperationDelegate				m_callback;
	std::shared_ptr<void>			m_param;
};

/**
* The class <code>具有通知回调的异步操作</code>
*
*/
class MODULE_CLASS ICallbackOpertaion : public imcore::Operation
{
public:
	ICallbackOpertaion(IOperationDelegate& callback)
		:m_callback(callback)
	{
	}
	virtual ~ICallbackOpertaion() {}

protected:
	/**
	* 同步回调
	*
	* @param   std::shared_ptr<void> param
	* @return  void
	* @exception there is no any exception to throw.
	*/

	void syncCallback(std::shared_ptr<void> param)
	{
		m_callback(param);
	}
	/**
	* 异步回调，借助UIEvent
	*
	* @param   std::shared_ptr<void> param
	* @return  void
	* @exception there is no any exception to throw.
	*/

	void asyncCallback(std::shared_ptr<void> param)
	{
		CallbackOperationEvent* pEvent = new CallbackOperationEvent(m_callback, param);
		module::getEventManager()->asynFireUIEvent(pEvent);
	}

private:
	IOperationDelegate          m_callback;
};

/**
* The class <code>IPduPacketParse</code>
*
*/
struct IPduPacketParse
{
public:
	/**
	* 收到TcpClient网络包后的包解析回调接口
	*
	* @param   std::auto_ptr<CImPdu> pdu
	* @return  void
	* @exception there is no any exception to throw.
	*/

	virtual void onPacket(imcore::TTPBHeader& header, std::string& pbBody) = 0;
};

NAMESPACE_END(module)
/******************************************************************************/
#endif// IMODULEINTERFACE_26428d8b-4585-4660-95b3-94e8735700e9_H__
