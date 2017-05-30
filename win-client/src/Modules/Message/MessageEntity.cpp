/******************************************************************************* 
 *  @file      MessageEntity.cpp 2014\7\25 22:59:44 $
 *  @author    ´ó·ð<dafo@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/MessageEntity.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/IGroupListModule.h"
#include <string>
/******************************************************************************/

MessageEntity::MessageEntity()
: msgType(0)
, msgStatusType(0)
, msgRenderType(0)
, msgAudioTime(0)
, msgTime(0)
, msgAudioReaded(0)
, msgSessionType(MESSAGETYPE_FROM_ERROR)
, msgId(0)
{

}

BOOL MessageEntity::getSenderInfo(OUT CString& senderName, OUT std::string& senderAvatartPath)
{
	return FALSE;
}

BOOL MessageEntity::isFromGroupMsg() const
{
	return MESSAGETYPE_FROM_GROUP == msgSessionType;
}

BOOL MessageEntity::isMySendMsg() const
{
	return (talkerSid == module::getSysConfigModule()->userID());
}

std::string MessageEntity::getOriginSessionId()
{
	if (MESSAGETYPE_FROM_FRIEND == msgSessionType)
	{
		return sessionId;
	}
	else if (MESSAGETYPE_FROM_GROUP == msgSessionType)
	{
		return module::getGroupListModule()->getOriginalSId(sessionId);
	}
	else
	{//error

	}
	return sessionId;
}

BOOL MessageEntity::isReaded() const
{
	return msgAudioReaded == 1;
}

BOOL MessageEntity::makeGroupSessionId()
{
	if (MESSAGETYPE_FROM_GROUP == msgSessionType)
	{
		sessionId = module::getGroupListModule()->makeGroupSId(sessionId);
		return TRUE;
	}
	return FALSE;
}

/******************************************************************************/