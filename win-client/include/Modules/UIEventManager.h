/*******************************************************************************
 *  @file      UIEventManager.h 2014\7\18 15:09:00 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#ifndef UIEVENTMANAGER_7F7C0283_2B1D_4BB8_8052_ADBB35F055F3_H__
#define UIEVENTMANAGER_7F7C0283_2B1D_4BB8_8052_ADBB35F055F3_H__

#include "GlobalDefine.h"
#include "network/ErrorCode.h"
#include "network/Lock.h"
#include "ModuleDll.h"
#include <list>
#include <functional>
/******************************************************************************/
NAMESPACE_BEGIN(module)

using namespace imcore;
struct IEvent;
struct ITimerEvent;

struct TTTimer
{
	UInt64 nElapse;
	UInt32 nDelay;
	BOOL   bRepeat;
	ITimerEvent* pTimerEvent;

	TTTimer();
};

/**
 * The class <code>UIEventManager</code> 
 *
 */
class MODULE_CLASS UIEventManager final
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    UIEventManager();
    /**
     * Destructor
     */
    ~UIEventManager();
    //@}

public:
	IMCoreErrorCode startup();
	void            shutdown();
	IMCoreErrorCode asynFireUIEvent(IN const IEvent* const pEvent);
	IMCoreErrorCode	asynFireUIEventWithLambda(std::function<void()> eventRun);
	IMCoreErrorCode scheduleTimer(IN ITimerEvent* pTimerEvent, IN UInt32 delay, IN BOOL bRepeat);
	IMCoreErrorCode scheduleTimerWithLambda(IN UInt32 delay, IN BOOL bRepeat
										  , IN std::function<void()> timerRun
										  , OUT ITimerEvent** ppTimer);
	IMCoreErrorCode  killTimer(IN ITimerEvent* pTimerEvent);

private:
	BOOL _registerClass();
	void _removeEvents();
	void _processTimer();
	void _processEvent(IEvent* pEvent, BOOL bRelease);
	static LRESULT _stdcall _WindowProc(HWND hWnd
		, UINT message
		, WPARAM wparam
		, LPARAM lparam);

private:
	UIEventManager& operator=(UIEventManager&);
	UIEventManager(const UIEventManager&);

private:
	HWND                    m_hWnd;
	CLock					m_lock;
	std::list<TTTimer>		m_lstTimers;
};

MODULE_API UIEventManager* getEventManager();

NAMESPACE_END(module)
/******************************************************************************/
#endif// UIEVENTMANAGER_7F7C0283_2B1D_4BB8_8052_ADBB35F055F3_H__
