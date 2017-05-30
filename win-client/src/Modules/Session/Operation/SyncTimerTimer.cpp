/******************************************************************************* 
 *  @file      SyncTimerTimer.cpp 2013\9\6 14:49:09 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "SyncTimerTimer.h"
#include "Modules/ITcpClientModule.h"
#include "ProtocolBuffer/IM.Message.pb.h"
#include "network/ImCore.h"

/******************************************************************************/

// -----------------------------------------------------------------------------
//  SyncTimerTimer: Public, Constructor

SyncTimeTimer::SyncTimeTimer()
:m_timeCount(0)
,m_serverTime(0)
{
    m_serverTime = (UInt32)time(0);
}
void SyncTimeTimer::process()
{
    ++m_serverTime;
    ++m_timeCount;
    if(m_timeCount >= 600)
    {
        m_timeCount = 0;
		imcore::IMLibCoreStartOperationWithLambda(
			[]()
		{
			IM::Message::IMClientTimeReq imClientTimeReq;
			module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_MSG
				,IM::BaseDefine::MessageCmdID::CID_MSG_TIME_REQUEST
				, &imClientTimeReq);
		});
    }
}

void SyncTimeTimer::release()
{
    delete this;
}

/******************************************************************************/
