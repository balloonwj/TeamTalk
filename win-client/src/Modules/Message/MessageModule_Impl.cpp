/******************************************************************************* 
 *  @file      HistoryMsgModule_Impl.cpp 2014\8\3 11:14:33 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "ProtocolBuffer/IM.Message.pb.h"
#include "MessageModule_Impl.h"
#include "utility/utilStrCodingAPI.h"
#include "Modules/IMiscModule.h"
#include "Modules/IDatabaseModule.h"
#include "Modules/ISessionModule.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/ITcpClientModule.h"
#include "ReceiveMsgManage.h"
#include "SendMsgManage.h"
#include "network/ImCore.h"
#include "network/TTPBHeader.h"

/******************************************************************************/
namespace module
{
	IMessageModule* getMessageModule()
	{
		static MessageModule_Impl module;
		return &module;
	}
}

// -----------------------------------------------------------------------------
//  HistoryMsgModule_Impl: Public, Constructor

MessageModule_Impl::MessageModule_Impl()
{
}

// -----------------------------------------------------------------------------
//  HistoryMsgModule_Impl: Public, Destructor

MessageModule_Impl::~MessageModule_Impl()
{
}

void MessageModule_Impl::removeMessageBySId(const std::string& sId)
{
	ReceiveMsgManage::getInstance()->removeMessageBySId(sId);
}

BOOL MessageModule_Impl::pushMessageBySId(const std::string& sId, MessageEntity& msg)
{
	return ReceiveMsgManage::getInstance()->pushMessageBySId(sId, msg);
}

BOOL MessageModule_Impl::getHistoryMessage(IN const std::string& sId, IN UInt32 nMsgCount
										 , IN BOOL scrollBottom, OUT std::vector<MessageEntity>& msgList)
{
	//step 0 get message id from cache
	module::SessionEntity sessEntity;
	if (!module::getSessionModule()->getSessionEntityBySId(sId, sessEntity))
	{
		LOGA__(ERR,"getSessionEntityBySId failed,sessionId:%s",util::stringToCString(sId));
		return FALSE;
	}
	UInt32 topMsgId = _getSessionTopMsgId(sId);
	if (0 == topMsgId)
	{
		topMsgId = sessEntity.latestmsgId;
	}

	//step 1 query history message from local db
	std::vector<MessageEntity> msgListTemp;
	module::getDatabaseModule()->sqlGetHistoryMessage(sId, topMsgId, nMsgCount, msgListTemp);

	//step 2 compare the topMsgId to latest local db msgId and check which is sequential
	if (!msgListTemp.empty())
	{
		//todo 还有优化的余地，取出的比msgCount+1的数量，看是否连续的。
		MessageEntity& latestMsgEntity = msgListTemp.front();
		MessageEntity& firstMsgEntity = msgListTemp.back();
		if ((topMsgId == latestMsgEntity.msgId) && ((firstMsgEntity.msgId + nMsgCount - 1) == latestMsgEntity.msgId))
		{
			msgList = msgListTemp;
			setSessionTopMsgId(sId, firstMsgEntity.msgId-1);
			return TRUE;
		}
	}

	//final fetch history message from server db
	imcore::IMLibCoreStartOperationWithLambda(
		[=]()mutable
	{
		LOG__(APP, _T("IMGetMsgListReq history message ,sessionId = %s,sessionName=%s,last msgId = %d,Count = %d")
			, util::stringToCString(sessEntity.sessionID)
			,sessEntity.getName()
			,topMsgId, nMsgCount);
		IM::Message::IMGetMsgListReq imGetMsgListReq;
		imGetMsgListReq.set_user_id(module::getSysConfigModule()->userId());
		imGetMsgListReq.set_session_type((IM::BaseDefine::SessionType)sessEntity.sessionType);
		imGetMsgListReq.set_session_id(sessEntity.getOriginIntegerSessionId());
		imGetMsgListReq.set_msg_id_begin(topMsgId);//服务端是包含当前的那一条的
		imGetMsgListReq.set_msg_cnt(nMsgCount);

		UInt16 reserved = (TRUE == scrollBottom) ? imcore::RESERVED_TYPE_HISTORY_SCROLLBOTTOM_MESSAGE : imcore::RESERVED_TYPE_HISTORY_MESSAGE;
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::SID_MSG
			, IM::BaseDefine::CID_MSG_LIST_REQUEST, reserved
			, &imGetMsgListReq);
	}
	);
	return FALSE;
}

void MessageModule_Impl::setSessionTopMsgId(const std::string& sId, UInt32 msgId)
{
	CAutoLock lock(&m_lock);
	m_mapSessionTopMsgId[sId] = msgId;
}

UInt32 MessageModule_Impl::_getSessionTopMsgId(const std::string& sId)
{
	CAutoLock lock(&m_lock);
	auto iterMsgId = m_mapSessionTopMsgId.find(sId);
	UInt32 topMsgId = 0;
	if (iterMsgId != m_mapSessionTopMsgId.end())
	{
		topMsgId = iterMsgId->second;
	}

	return topMsgId;
}

void MessageModule_Impl::removeAllMessage()
{
	ReceiveMsgManage::getInstance()->removeAllMessage();
}

UInt32 MessageModule_Impl::getTotalUnReadMsgCount(void)
{
	return	ReceiveMsgManage::getInstance()->getTotalUnReadMsgCount();
}

/******************************************************************************/