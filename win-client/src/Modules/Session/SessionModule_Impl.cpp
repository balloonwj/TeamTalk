/******************************************************************************* 
 *  @file      SessionModule_Impl.cpp 2014\12\31 11:41:09 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/
#include "stdafx.h"
#include "ProtocolBuffer/IM.Message.pb.h"
#include "SessionModule_Impl.h"
#include "Operation/SyncTimerTimer.h"
#include "Modules/ITcpClientModule.h"
#include "Modules/UI/MainListLayout.h"
#include "Modules/UI/UIRecentSessionList.h"
#include "Modules/UI/UIGroupsTreelist.h"
#include "Modules/UI/UIEAUserTreelist.h"
#include "Modules/IUserListModule.h"
#include "Modules/IDatabaseModule.h"
#include "Modules/IMessageModule.h"
#include "Modules/IGroupListModule.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/UI//SearchLayout.h"
#include "Modules/MessageEntity.h"
#include "../Message/SendMsgManage.h"
#include "../Message/ReceiveMsgManage.h"
#include "utility/Multilingual.h"
#include "Session/SessionManager.h"
#include "network/ImCore.h"
#include "network/TTPBHeader.h"

/******************************************************************************/
namespace module
{
	module::ISessionModule* getSessionModule()
	{
		static SessionModule_Impl module;
		return &module;
	}
}

// -----------------------------------------------------------------------------
//  SessionModule_Impl: Public, Constructor

SessionModule_Impl::SessionModule_Impl()
:m_pSyncTimer(nullptr)
{

}

void SessionModule_Impl::onPacket(imcore::TTPBHeader& header, std::string& pbBody)
{
	if (IM::BaseDefine::ServiceID::SID_MSG == header.getModuleId())
	{
		switch (header.getCommandId())
		{
		case IM::BaseDefine::MessageCmdID::CID_MSG_DATA:
			_sessionMsgData(pbBody);
			break;
		case IM::BaseDefine::MessageCmdID::CID_MSG_DATA_ACK:
			_sessionMsgACK(header.getSeqNumber(),pbBody);
			break;
		case IM::BaseDefine::MessageCmdID::CID_MSG_TIME_RESPONSE:
			_sessionMsgTimeResponse(pbBody);
			break;
		case IM::BaseDefine::MessageCmdID::CID_MSG_UNREAD_CNT_RESPONSE:
			_sessionMsgUnreadCntResponse(pbBody);
			break;
		case IM::BaseDefine::MessageCmdID::CID_MSG_LIST_RESPONSE:
			if (imcore::RESERVER_TYPE_UNREADER_MESSAGE == header.getSeqNumber())
			{
				_sessionUnReadMsgListResponse(pbBody);
			}
			else
			{
				_sessionHistoryMsgListResponse(header.getSeqNumber(), pbBody);
			}
			break;
		case IM::BaseDefine::MessageCmdID::CID_MSG_READ_NOTIFY:
			_sessionMsgReadNotify(pbBody);
			break;
		default:
			LOG__(ERR, _T("SID_MSG,Unknow commandID:%d"), header.getCommandId());
			break;
		}
	}
}

DuiLib::CControlUI* SessionModule_Impl::createMainDialogControl(
	IN LPCTSTR pstrClass,IN DuiLib::CPaintManagerUI& paintManager)
{
	if (_tcsicmp(pstrClass, _T("ListLayout")) == 0)
	{
		return new MainListLayout();
	}
	if (0 == _tcsicmp(pstrClass, _T("SearchLayout")))
	{
		return new SearchLayout();
	}
	if (_tcsicmp(pstrClass, _T("FriendList")) == 0)
	{
		return new CEAUserTreelistUI(paintManager);
	}
	else if (_tcsicmp(pstrClass, _T("GroupList")) == 0)
	{
		return new CGroupsTreelistUI(paintManager);
	}
	else if (_tcsicmp(pstrClass, _T("SessionList")) == 0)
	{
		return new CUIRecentSessionList(paintManager);
	}
	return nullptr;
}

BOOL SessionModule_Impl::_banGroupMSG(IN MessageEntity msg)
{
	if (msg.msgRenderType == MESSAGE_RENDERTYPE_SYSTEMTIPS)
	{
		return FALSE;
	}
	if (!(IM::BaseDefine::MsgType::MSG_TYPE_GROUP_TEXT == msg.msgType
		|| IM::BaseDefine::MsgType::MSG_TYPE_GROUP_AUDIO == msg.msgType))//非群消息无屏蔽
	{
		return FALSE;
	}
	module::GroupInfoEntity groupInfo;
	if (!module::getGroupListModule()->getGroupInfoBySId(msg.sessionId, groupInfo))
	{
		LOG__(ERR, _T("Can't find the sid:%s"),util::stringToCString(msg.sessionId));
		return FALSE;
	}
	if (groupInfo.shieldStatus)
	{
		//发已读确认，通知服务器，该群消息已读
		imcore::IMLibCoreStartOperationWithLambda(
			[=]()mutable
		{
			IM::Message::IMMsgDataReadAck imMsgDataReadAck;
			imMsgDataReadAck.set_user_id(module::getSysConfigModule()->userId());
			std::string sid = msg.getOriginSessionId();
			imMsgDataReadAck.set_session_id(util::stringToInt32(sid));
			imMsgDataReadAck.set_msg_id(msg.msgId);
			imMsgDataReadAck.set_session_type(IM::BaseDefine::SessionType::SESSION_TYPE_GROUP);
			module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_MSG
				, IM::BaseDefine::MessageCmdID::CID_MSG_READ_ACK
				, &imMsgDataReadAck);
		}
		);
		return TRUE;
	}
	return FALSE;
}
BOOL SessionModule_Impl::_prase2LocalMsg(OUT MessageEntity& msg)
{
	if (IM::BaseDefine::MsgType::MSG_TYPE_SINGLE_AUDIO == msg.msgType)
	{
		//实时个人消息需要多端同步
		if (MESSAGE_TYPE_RUNTIME == msg.msgStatusType
			&& msg.talkerSid != module::getSysConfigModule()->userID())
			msg.sessionId = msg.talkerSid;

		msg.msgRenderType = MESSAGE_RENDERTYPE_AUDIO;
		msg.msgSessionType = MESSAGETYPE_FROM_FRIEND;
		std::string fileName;
		AudioMessageMananger::getInstance()->makeAppAudioSid(msg.msgId, msg.sessionId, fileName);
		AudioMessageMananger::getInstance()->saveAudioDataToFile((UCHAR*)(msg.content.c_str()), msg.content.length(), fileName);
		AudioMessageMananger::getInstance()->getAudioMsgLenth((UCHAR*)(msg.content.c_str()), msg.content.length(), msg.msgAudioTime);
		//std::string msgEncrypt;
		//ENCRYPT_MSG(fileName, msgEncrypt);
		//msg.content = msgEncrypt;
		msg.content = fileName;
	}
	else if (IM::BaseDefine::MsgType::MSG_TYPE_SINGLE_TEXT == msg.msgType)//个人消息
	{
		//实时个人消息需要多端同步
		if (MESSAGE_TYPE_RUNTIME == msg.msgStatusType
			&& msg.talkerSid != module::getSysConfigModule()->userID())
			msg.sessionId = msg.talkerSid;

		msg.msgSessionType = MESSAGETYPE_FROM_FRIEND;
		msg.msgRenderType = MESSAGE_RENDERTYPE_TEXT;
	}
	else if (IM::BaseDefine::MsgType::MSG_TYPE_GROUP_TEXT == msg.msgType)//群消息
	{
		msg.msgRenderType = MESSAGE_RENDERTYPE_TEXT;
		msg.msgSessionType = MESSAGETYPE_FROM_GROUP;
		msg.makeGroupSessionId();
	}
	else if (MSG_TYPE_AUDIO_GROUP == msg.msgType)
	{
		msg.msgSessionType = MESSAGETYPE_FROM_GROUP;
		msg.msgRenderType = MESSAGE_RENDERTYPE_AUDIO;
		msg.makeGroupSessionId();

		std::string fileName;
		AudioMessageMananger::getInstance()->makeAppAudioSid(msg.msgId, msg.sessionId, fileName);
		AudioMessageMananger::getInstance()->saveAudioDataToFile((UCHAR*)(msg.content.c_str()), msg.content.length(), fileName);
		AudioMessageMananger::getInstance()->getAudioMsgLenth((UCHAR*)(msg.content.c_str()), msg.content.length(), msg.msgAudioTime);
		//std::string msgEncrypt;
		//ENCRYPT_MSG(fileName, msgEncrypt);
		//msg.content = msgEncrypt;
		msg.content = fileName;
	}
	else
	{
		ASSERT(FALSE);
		LOG__(ERR, _T("Don't support this msgtype:%d"), msg.msgType);
		return FALSE;
	}
	return TRUE;
}
void SessionModule_Impl::_sessionMsgData(IN std::string& pbBody)
{
	IM::Message::IMMsgData imMsgData;
	if (!imMsgData.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed:%s"), util::stringToCString(pbBody));
		return;
	}
	MessageEntity msg;
	msg.msgTime = imMsgData.create_time();
	msg.talkerSid = util::uint32ToString(imMsgData.from_user_id());
	msg.sessionId = util::uint32ToString(imMsgData.to_session_id());
	msg.msgStatusType = MESSAGE_TYPE_RUNTIME;
	msg.msgType = imMsgData.msg_type();
	msg.msgId = imMsgData.msg_id();
	msg.content = imMsgData.msg_data();

	_prase2LocalMsg(msg);//解析成本地的消息

	if (ReceiveMsgManage::getInstance()->checkIsReduplicatedMsg(msg, imMsgData.msg_id()))
	{
		LOG__(ERR, _T("checkIsReduplicatedMsg,消息重复"));
		return;
	}

	if (ReceiveMsgManage::getInstance()->pushMessageBySId(msg.sessionId, msg))
	{
		updateSessionEntityByMsg(msg);
		_checkMsgFromStranger(msg);
		if (_banGroupMSG(msg))
		{
			MessageEntity Popmsg;
			ReceiveMsgManage::getInstance()->popMessageBySId(msg.sessionId, Popmsg);
		}
		else
			module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_NEWMESSAGE, msg.sessionId);

		//通知服务器收到该消息
		if (MESSAGETYPE_FROM_FRIEND == msg.msgSessionType)//只有个人消息要发已收确认,群消息是不发已收确认的
		{
			imcore::IMLibCoreStartOperationWithLambda(
				[=]()
			{
				MessageEntity sendingmsgTemp = msg;
				std::string OriginSessionId = sendingmsgTemp.getOriginSessionId();

				IM::Message::IMMsgDataAck imMsgDataAck;
				UInt32 mySid = util::stringToInt32(module::getSysConfigModule()->userID());
				imMsgDataAck.set_user_id(mySid);
				UInt32 sessionId = util::stringToInt32(OriginSessionId);
				imMsgDataAck.set_session_id(sessionId);
				imMsgDataAck.set_session_type(IM::BaseDefine::SessionType::SESSION_TYPE_SINGLE);
				imMsgDataAck.set_msg_id(msg.msgId);
				module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_MSG
					, IM::BaseDefine::MessageCmdID::CID_MSG_DATA_ACK
					, &imMsgDataAck);
			});
		}
	}
}
void SessionModule_Impl::_sessionUnReadMsgListResponse(IN std::string& pbBody)
{
	IM::Message::IMGetMsgListRsp imGetMsgListRsp;
	if (!imGetMsgListRsp.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	MessageEntity msg;
	msg.msgStatusType = MESSAGE_TYPE_OFFLINE;
	const UInt32 msgCnt = imGetMsgListRsp.msg_list_size();
	LOG__(APP, _T("IMGetMsgListRsp msgCnt：%d,sessionId =%s"), msgCnt, util::int32ToCString(imGetMsgListRsp.session_id()));
	for (UInt32 i = msgCnt; i > 0; --i)
	{
		const IM::BaseDefine::MsgInfo& msgInfo = imGetMsgListRsp.msg_list(i - 1);
		msg.msgTime = msgInfo.create_time();
		msg.talkerSid = util::uint32ToString(msgInfo.from_session_id());//说话的人
		msg.sessionId = util::uint32ToString(imGetMsgListRsp.session_id());//会话ID
		msg.msgType = msgInfo.msg_type();
		msg.msgId = msgInfo.msg_id();
		msg.content = msgInfo.msg_data();
		int nsize = msg.content.length();
		_prase2LocalMsg(msg);
		if (i == imGetMsgListRsp.msg_list_size())//第一条消息
		{
			//module::getMessageModule()->removeMessageBySId(msg.sessionId);
			_checkMsgFromStranger(msg);//第一次插入消息记录前，先去确认下是否要创建用户列表	
		}
		if (1 == i)//最后一条消息
		{
			updateSessionEntityByMsg(msg);//更新会话	
		}
		if (MESSAGETYPE_FROM_FRIEND == msg.msgSessionType)
		{
			module::getMessageModule()->pushMessageBySId(msg.sessionId, msg);
		}
		else if (MESSAGETYPE_FROM_GROUP == msg.msgSessionType)
		{
			if (!_banGroupMSG(msg))
			{
				module::getMessageModule()->pushMessageBySId(msg.sessionId, msg);
			}
		}
	}
	if (0 != msgCnt)
		module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_NEWMESSAGE, msg.sessionId);
}

void SessionModule_Impl::_sessionHistoryMsgListResponse(IN UInt16 reserved, IN std::string& pbBody)
{
	IM::Message::IMGetMsgListRsp imGetMsgListRsp;
	if (!imGetMsgListRsp.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	const UInt32 msgCnt = imGetMsgListRsp.msg_list_size();
	LOG__(APP, _T("IMGetMsgListRsp log begin,sessionid：%d,last msgId:%d,msg count:%d,sessionType:%d")
		, imGetMsgListRsp.session_id(), imGetMsgListRsp.msg_id_begin(),msgCnt,imGetMsgListRsp.session_type());
	std::string sId = util::uint32ToString(imGetMsgListRsp.session_id());
	if (IM::BaseDefine::SESSION_TYPE_GROUP == imGetMsgListRsp.session_type())
	{
		sId = module::getGroupListModule()->makeGroupSId(sId);
	}
	if (msgCnt <= 0 )
	{
		LOG__(ERR, _T("IMGetMsgListRsp msgCnt:%d <= 0"),msgCnt);
		return;//返回消息数为0,不返回可能会导致UI刷新crash。
	}
	MessageEntity msg;
	for (UInt32 i = 0; i < msgCnt; ++i)
	{
		const IM::BaseDefine::MsgInfo& msgInfo = imGetMsgListRsp.msg_list(i);
		msg.msgStatusType = MESSAGE_TYPE_HISTORY;
		msg.msgTime = msgInfo.create_time();
		msg.talkerSid = util::uint32ToString(msgInfo.from_session_id());//说话的人
		msg.sessionId = util::uint32ToString(imGetMsgListRsp.session_id());//会话ID
		msg.msgType = msgInfo.msg_type();
		msg.msgId = msgInfo.msg_id();
		msg.content = msgInfo.msg_data();
		_prase2LocalMsg(msg);

		if (i == (msgCnt-1))
		{
			LOG__(APP, _T("IMGetMsgListRsp log end,first msgId:%d"), msg.msgId);
		}

		if (MESSAGE_RENDERTYPE_AUDIO == msg.msgRenderType)
		{
			msg.msgAudioReaded = 1;//语音历史消息默认都置为已读
		}

		module::getMessageModule()->pushMessageBySId(msg.sessionId, msg);
	}
	std::tuple<std::string, UInt16>* pTuple = new std::tuple<std::string, UInt16>;
	*pTuple = std::tie(sId, reserved);
	module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_HISTORY_MESSAGE, std::shared_ptr<void>(pTuple));
}

void SessionModule_Impl::_sessionMsgACK(IN const UInt16 seqNo, IN std::string& pbBody)
{
	IM::Message::IMMsgDataAck imMsgDataAck;
	if (!imMsgDataAck.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	//发送消息成功，删除本地超时机制
	SendMsgManage::getInstance()->popUpSendingMsgByAck(seqNo,imMsgDataAck.msg_id());
}

BOOL SessionModule_Impl::_checkMsgFromStranger(IN MessageEntity& msg)
{
	if (MESSAGETYPE_FROM_FRIEND == msg.msgSessionType)
	{
		module::UserInfoEntity info;
		if (!module::getUserListModule()->getUserInfoBySId(msg.sessionId, info))
		{
			
			//这个时候需要去请求下用户的好友信息
			CString csUId = util::stringToCString(msg.sessionId);
			LOG__(DEBG, _T("userinfo not exist,tcpGetUserFriendInfo now sId：%s"), csUId);
			module::getUserListModule()->tcpGetUserInfo(msg.sessionId);
			return FALSE;
		}
	}
	else if (MESSAGETYPE_FROM_GROUP == msg.msgSessionType)
	{
		module::GroupInfoEntity info;
		if (!module::getGroupListModule()->getGroupInfoBySId(msg.sessionId, info))
		{
			
			//这个时候需要去请求下群信息
			CString csUId = util::stringToCString(msg.sessionId);
			LOG__(DEBG, _T("groupinfo not exist,tcpGetGroupInfo now sId：%s"), csUId);
			module::getGroupListModule()->tcpGetGroupInfo(msg.getOriginSessionId());
			return FALSE;
		}
	}
	return TRUE;
}

void SessionModule_Impl::_sessionMsgTimeResponse(IN string& pbBody)
{
	IM::Message::IMClientTimeRsp imClientTimeRsp;
	if (!imClientTimeRsp.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	LOG__(APP, _T("IMClientTimeRsp,time = %d"), imClientTimeRsp.server_time());
	m_pSyncTimer->setTime(imClientTimeRsp.server_time());
}

void SessionModule_Impl::_sessionMsgUnreadCntResponse(IN string& pbBody)
{
	IM::Message::IMUnreadMsgCntRsp imUnreadMsgCntRsp;
	if (!imUnreadMsgCntRsp.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	const int nSize = imUnreadMsgCntRsp.unreadinfo_list_size();
	LOG__(APP, _T("IMUnreadMsgCntRsp,count = %d"), nSize);
	for (int i = 0; i < nSize; ++i)
	{
		const IM::BaseDefine::UnreadInfo& unReadInfo = imUnreadMsgCntRsp.unreadinfo_list(i);
		//直接开启获取具体离线消息的task
		imcore::IMLibCoreStartOperationWithLambda(
			[=]()
		{
			LOG__(APP, _T("IMGetMsgListReq unread message ,sessionid = %s,sessionType = %d")
				, util::int32ToCString(unReadInfo.session_id()), static_cast<UInt32>(unReadInfo.session_type()));
			IM::Message::IMGetMsgListReq imGetMsgListReq;
			imGetMsgListReq.set_user_id(module::getSysConfigModule()->userId());
			imGetMsgListReq.set_session_type(unReadInfo.session_type());
			imGetMsgListReq.set_session_id(unReadInfo.session_id());
			imGetMsgListReq.set_msg_id_begin(unReadInfo.latest_msg_id());

			UInt32 nUnReadCnt = unReadInfo.unread_cnt();
			if (nUnReadCnt >100)
			{//当未读消息大于100条,只读取最近的100条，否则会导致UI刷新问题
				LOG__(APP, _T("nUnReadCnt > 100, realCount = %d"),nUnReadCnt);
				nUnReadCnt = 100;
			}
			imGetMsgListReq.set_msg_cnt(nUnReadCnt);

			module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_MSG
				, IM::BaseDefine::MessageCmdID::CID_MSG_LIST_REQUEST,imcore::RESERVER_TYPE_UNREADER_MESSAGE
				, &imGetMsgListReq);
		}
		);
	}
}

void SessionModule_Impl::_sessionMsgReadNotify(IN string& pbBody)
{
	IM::Message::IMMsgDataReadNotify imMsgDataReadNotify;
	if (!imMsgDataReadNotify.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed：%s"), util::stringToCString(pbBody));
		return;
	}
	std::string sessionId = util::uint32ToString(imMsgDataReadNotify.session_id());
	if (IM::BaseDefine::SessionType::SESSION_TYPE_GROUP == imMsgDataReadNotify.session_type())
	{
		sessionId = module::getGroupListModule()->makeGroupSId(sessionId);
	}
	UInt32 maxMsgId = imMsgDataReadNotify.msg_id();
	LOG__(APP, _T("IMMsgDataReadNotify sessionid = %s,msgId = %d"), util::stringToCString(sessionId), maxMsgId);
	//这个session的小于msgId的消息全部被读取过了
	SessionMessage_List msgOffLineList,msgRunTimeList;
	ReceiveMsgManage::getInstance()->popMessagesBySId(sessionId, msgOffLineList, MESSAGE_TYPE_OFFLINE, maxMsgId);
	if (!msgOffLineList.empty())
	{
		//保存到历史消息中
		module::getDatabaseModule()->sqlBatchInsertMessage(msgOffLineList);
		updateSessionEntityByMsg(msgOffLineList.back());
	}
	ReceiveMsgManage::getInstance()->popMessagesBySId(sessionId, msgRunTimeList, MESSAGE_TYPE_RUNTIME, maxMsgId);
	if (!msgRunTimeList.empty())
	{
		//保存到历史消息中
		module::getDatabaseModule()->sqlBatchInsertMessage(msgRunTimeList);
		updateSessionEntityByMsg(msgRunTimeList.back());
	}

	module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_MESSGEREADED_NOTIFY, sessionId);
}

void SessionModule_Impl::setTime(UInt32 time)
{
	m_pSyncTimer->setTime(time);
}

UInt32 SessionModule_Impl::getTime() const
{
	return m_pSyncTimer->getTime();
}

void SessionModule_Impl::startSyncTimeTimer()
{
	if (!m_pSyncTimer)
	{
		m_pSyncTimer = new SyncTimeTimer();
		module::getEventManager()->scheduleTimer(m_pSyncTimer, 1, TRUE);
	}
}


BOOL SessionModule_Impl::getSessionEntityBySId(IN const std::string& sId, OUT module::SessionEntity& sessionEntity)
{
	module::SessionEntity* pSessionEntity = SessionEntityManager::getInstance()->getSessionEntityBySId(sId);
	if (nullptr != pSessionEntity)
	{
		sessionEntity = *pSessionEntity;
		return TRUE;
	}
	return FALSE;
}

void SessionModule_Impl::setSessionEntity(IN const module::SessionEntity& sessionInfo)
{
	SessionEntityManager::getInstance()->setSessionEntity(sessionInfo);
}

void SessionModule_Impl::getRecentSessionList(OUT std::vector<std::string>& vecRecentSession)
{
	SessionEntityManager::getInstance()->getRecentSessionList(vecRecentSession);
}

BOOL SessionModule_Impl::startup()
{
	return SessionEntityManager::getInstance()->loadSessionEntityFromDB();
}

void SessionModule_Impl::updateSessionEntityByMsg(IN const MessageEntity& msg)
{	
	module::SessionEntity sessionInfo;
	sessionInfo.sessionID = msg.sessionId;
	sessionInfo.sessionType = msg.msgSessionType;
	sessionInfo.updatedTime = msg.msgTime;
	sessionInfo.latestmsgId = msg.msgId;
	sessionInfo.latestMsgFromId = msg.talkerSid;
	if (MESSAGE_RENDERTYPE_AUDIO == msg.msgRenderType)
	{
		std::string sYuYing = util::cStringToString(
			util::getMultilingual()->getStringById(_T("STRID_SESSIONMODULE_RENDERTYPE_AUDIO")));
		std::string msgEncrypt;
		ENCRYPT_MSG(sYuYing, msgEncrypt);//最近会话需要加密
		sessionInfo.latestMsgContent = msgEncrypt;
	}
	else
	{
		CString strContent = util::stringToCString(msg.content);
		ReceiveMsgManage::getInstance()->parseContent(strContent, TRUE, 400);
		sessionInfo.latestMsgContent = util::cStringToString(strContent);
	}
	
	SessionEntityManager::getInstance()->setSessionEntity(sessionInfo);
	SessionEntityManager::getInstance()->setGlobalUpdatedTime(sessionInfo.updatedTime);
	module::getSessionModule()->asynNotifyObserver(module::KEY_SESSION_UPDATE_RECENTLY_SESSIONLIST, sessionInfo.sessionID);
	module::getDatabaseModule()->sqlInsertRecentSessionInfoEntity(sessionInfo);
}

UInt32 SessionModule_Impl::getGlobalUpdateTime() const
{
	return SessionEntityManager::getInstance()->getGlobalUpdateTime();
}

void SessionModule_Impl::setGlobalUpdateTime(IN const UInt32 updateTime) const
{
	SessionEntityManager::getInstance()->setGlobalUpdatedTime(updateTime);
}

void SessionModule_Impl::deleteSessionEntity(IN const std::string& sessionId)
{
	SessionEntityManager::getInstance()->removeSessionEntity(sessionId);
	module::getDatabaseModule()->sqlDeleteRecentSessionInfoEntity(sessionId);
}

/******************************************************************************/