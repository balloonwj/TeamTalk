/******************************************************************************* 
 *  @file      UIEventManager.cpp 2014\7\18 15:09:03 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/IEvent.h"
#include "utility/utilStrCodingAPI.h"
#include "utility/utilCommonAPI.h"
#include "network/Exception.h"
#include "Modules/UIEventManager.h"
#include <algorithm>
#include <memory>
/******************************************************************************/
NAMESPACE_BEGIN(module)

namespace
{
	#define UI_TIMER_ID					WM_USER + 1004
	#define UI_EVENT_MSG				WM_USER + 1005

	static const wchar_t uiEventWndClass[] = L"uiEventManager_class";
}

namespace
{
	template<class base>
	class LambdaEvent : public base
	{
	public:
		LambdaEvent(std::function<void()> eventRun)
			:m_eventRun(eventRun)
		{
		}

		virtual void process()
		{
			m_eventRun();
		}

		virtual void release()
		{
			delete this;
		}

	private:
		std::function<void()> m_eventRun;
	};
}

UIEventManager::UIEventManager()
:m_hWnd(0)
{
}

UIEventManager::~UIEventManager()
{
	//捕捉可能抛出的未知异常
	try
	{
		shutdown();
	}
	catch (...)
	{
		LOG__(ERR, _T("shutdown throw unknown exception"));
		assert(FALSE);
	}
}

void UIEventManager::shutdown()
{
	if (0 !=m_hWnd)
	{
		_removeEvents();
		::KillTimer(m_hWnd, UI_TIMER_ID);
		::DestroyWindow(m_hWnd);
		::UnregisterClassW(uiEventWndClass, ::GetModuleHandle(NULL));
		m_hWnd = 0;
	}
}

BOOL UIEventManager::_registerClass()
{
	WNDCLASSEXW wc = { 0 };
	wc.cbSize = sizeof(wc);
	wc.lpfnWndProc = _WindowProc;
	wc.hInstance = ::GetModuleHandle(0);
	wc.lpszClassName = uiEventWndClass;
	ATOM ret = ::RegisterClassExW(&wc);
	ASSERT(ret != NULL);
	if (NULL == ret || ::GetLastError() == ERROR_CLASS_ALREADY_EXISTS)
		return FALSE;

	return TRUE;
}

LRESULT _stdcall UIEventManager::_WindowProc(HWND hWnd
											, UINT message
											, WPARAM wparam
											, LPARAM lparam)
{
	switch (message)
	{
	case UI_EVENT_MSG:
		reinterpret_cast<UIEventManager*>(wparam)->_processEvent(reinterpret_cast<IEvent*>(lparam), TRUE);
		break;
	case WM_TIMER:
		reinterpret_cast<UIEventManager*>(wparam)->_processTimer();
		break;
	default:
		break;
	}
	return ::DefWindowProc(hWnd, message, wparam, lparam);
}

imcore::IMCoreErrorCode UIEventManager::startup()
{
	IMCoreErrorCode errCode = IMCORE_OK;

	if (0 != m_hWnd)
		return IMCORE_OK;
	else
	{
		if (!_registerClass())
			return IMCORE_INVALID_HWND_ERROR;
		m_hWnd = ::CreateWindowW(uiEventWndClass, _T("uiEvnetManager_window"),
			0, 0, 0, 0, 0, HWND_MESSAGE, 0, GetModuleHandle(0), 0);
		if (m_hWnd)
		{
			::SetTimer(m_hWnd, reinterpret_cast<UINT_PTR>(this), 1000, NULL);
		}
	}

	if (FALSE == ::IsWindow(m_hWnd))
		errCode = IMCORE_INVALID_HWND_ERROR;

	return errCode;
}

void UIEventManager::_removeEvents()
{
	CAutoLock lock(&m_lock);
	for (auto &pTimer : m_lstTimers)
	{
		if (pTimer.pTimerEvent)
		{
			pTimer.pTimerEvent->release();
		}
	}
	m_lstTimers.clear();
}

void UIEventManager::_processEvent(IEvent* pEvent, BOOL bRelease)
{
	assert(pEvent);
	if (0 == pEvent)
		return;

	try
	{
		pEvent->process();
		if (bRelease)
			pEvent->release();
	}
	catch (imcore::Exception *e)
	{
		LOG__(ERR, _T("event run exception"));
		pEvent->onException(e);
		if (bRelease)
			pEvent->release();
		if (e)
		{
			LOG__(ERR, _T("event run exception:%s"), util::stringToCString(e->m_msg));
			assert(FALSE);
		}
	}
	catch (...)
	{
		LOG__(ERR, _T("operation run exception,unknown reason"));
		if (bRelease)
			pEvent->release();
		assert(FALSE);
	}
}

module::IMCoreErrorCode UIEventManager::asynFireUIEvent(IN const IEvent* const pEvent)
{
	assert(m_hWnd);
	assert(pEvent);
	if (0 == m_hWnd || 0 == pEvent)
		return IMCORE_ARGUMENT_ERROR;

	if (FALSE == ::PostMessage(m_hWnd, UI_EVENT_MSG, reinterpret_cast<WPARAM>(this), reinterpret_cast<WPARAM>(pEvent)))
		return IMCORE_WORK_POSTMESSAGE_ERROR;

	return IMCORE_OK;
}

imcore::IMCoreErrorCode UIEventManager::asynFireUIEventWithLambda(std::function<void()> eventRun)
{
	assert(m_hWnd);
	if (0 == m_hWnd)
		return IMCORE_ARGUMENT_ERROR;

	//注：todo...这里再应用退出时,可能会引起内存泄露，因为释放是靠windows消息队列来的
	LambdaEvent<IEvent>* pLambdaEvent = new LambdaEvent<IEvent>(eventRun);
	return asynFireUIEvent(pLambdaEvent);
}

imcore::IMCoreErrorCode UIEventManager::scheduleTimerWithLambda(IN UInt32 delay
																,IN BOOL bRepeat
																,IN std::function<void()> timerRun
																,OUT ITimerEvent** ppTimer)
{
	LambdaEvent<ITimerEvent>* pLambdaEvent = new LambdaEvent<ITimerEvent>(timerRun);
	imcore::IMCoreErrorCode errCode = scheduleTimer(pLambdaEvent, delay, bRepeat);
	*ppTimer = pLambdaEvent;
	if (IMCORE_OK != errCode)
	{
		delete pLambdaEvent;
		pLambdaEvent = nullptr;
		*ppTimer = 0;
	}
	return errCode;
}

imcore::IMCoreErrorCode UIEventManager::scheduleTimer(IN ITimerEvent* pTimerEvent
													 , IN UInt32 delay
													 , IN BOOL bRepeat)
{
	assert(pTimerEvent);
	if (0 == pTimerEvent)
	{
		return IMCORE_ARGUMENT_ERROR;
	}
	if (0 == delay)
	{
		asynFireUIEvent(pTimerEvent);
	}
	{
		CAutoLock lock(&m_lock);
		TTTimer ctx;
		ctx.bRepeat = bRepeat;
		ctx.nDelay = delay;
		ctx.pTimerEvent = pTimerEvent;

		for (TTTimer& timer : m_lstTimers)
		{
			if (timer.pTimerEvent == pTimerEvent)
			{
				timer = ctx;
				return IMCORE_OK;
			}
		}
		m_lstTimers.push_back(ctx);
	}

	return IMCORE_OK;
}

void UIEventManager::_processTimer()
{
	CAutoLock lock(&m_lock);
	for (auto iter = m_lstTimers.begin(); iter != m_lstTimers.end();)
	{
		TTTimer& ctx = *iter;
		if (++ctx.nElapse < ctx.nDelay)
		{
			++iter;
			continue;
		}
		if (!ctx.bRepeat)
		{
			TTTimer ctxBak = *iter;
			iter = m_lstTimers.erase(iter);
			_processEvent(ctxBak.pTimerEvent, TRUE);
		}
		else
		{
			if (0 == (ctx.nElapse % ctx.nDelay))
			{
				_processEvent(ctx.pTimerEvent, FALSE);
				++iter;
				ctx.nElapse = 0;
				continue;
			}
		}
	}
}

imcore::IMCoreErrorCode UIEventManager::killTimer(IN ITimerEvent* pTimerEvent)
{
	CAutoLock lock(&m_lock);
	auto iter = std::remove_if(m_lstTimers.begin()
		, m_lstTimers.end()
		, [=](TTTimer& ttime)
	{
		return (pTimerEvent == ttime.pTimerEvent);
	}
	);
	if (iter != m_lstTimers.end())
	{
		m_lstTimers.erase(iter,m_lstTimers.end());
		delete pTimerEvent;
		pTimerEvent = 0;
		return IMCORE_OK;
	}

	return IMCORE_WORK_TIMER_INEXISTENCE_ERROR;
}

TTTimer::TTTimer() 
:nElapse(0)
,nDelay(0)
,bRepeat(TRUE)
,pTimerEvent(0)
{

}

UIEventManager* getEventManager()
{
	static UIEventManager manager;
	return &manager;
}

NAMESPACE_END(module)
/******************************************************************************/