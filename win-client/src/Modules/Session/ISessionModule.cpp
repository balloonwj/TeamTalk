/******************************************************************************* 
 *  @file      ISessionModule.cpp 2015\1\8 9:16:08 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/ISessionModule.h"
#include "Modules/IUserListModule.h"
#include "Modules/IGroupListModule.h"
/******************************************************************************/
NAMESPACE_BEGIN(module)
SessionEntity::SessionEntity()
:updatedTime(0)
, sessionType(module::SESSION_ERRORTYPE)
{

}
std::string SessionEntity::getAvatarPath()
{
	if (module::SESSION_USERTYPE == sessionType)
	{
		module::UserInfoEntity user;
		if (module::getUserListModule()->getUserInfoBySId(sessionID, user))
			return user.getAvatarPath();

	}
	else if (module::SESSION_GROUPTYPE == sessionType)
	{
		module::GroupInfoEntity group;
		if (module::getGroupListModule()->getGroupInfoBySId(sessionID, group))
		{
			return group.getAvatarPath();
		}
	}
	return std::string("");
}

UInt8 SessionEntity::getOnlineState()
{
	if (module::SESSION_USERTYPE == sessionType)
	{
		module::UserInfoEntity user;
		if (module::getUserListModule()->getUserInfoBySId(sessionID, user))
			return user.onlineState;

	}
	else if (module::SESSION_GROUPTYPE == sessionType)
	{
		return IM::BaseDefine::USER_STATUS_ONLINE;//群永远在线的
	}

	return 0;
}

CString SessionEntity::getName()
{
	if (SESSION_USERTYPE == sessionType)
	{
		module::UserInfoEntity user;
		if (module::getUserListModule()->getUserInfoBySId(sessionID, user))
		{
			return user.getRealName();
		}
	}
	else if (SESSION_GROUPTYPE == sessionType)
	{
		module::GroupInfoEntity group;
		if (module::getGroupListModule()->getGroupInfoBySId(sessionID, group))
		{
			return group.csName;
		}
	}
	return _T("");
}
void SessionEntity::setUpdatedTimeByServerTime()
{
	if (SESSION_USERTYPE == sessionType)
	{
		module::UserInfoEntity userInfo;
		if (module::getUserListModule()->getUserInfoBySId(sessionID, userInfo))
		{
			updatedTime = userInfo.updated;
		}
	}
	else if (SESSION_GROUPTYPE == sessionType)
	{
		module::GroupInfoEntity groupInfo;
		if (module::getGroupListModule()->getGroupInfoBySId(sessionID, groupInfo))
		{
			updatedTime = groupInfo.groupUpdated;
		}
	}
	return;
}

std::string SessionEntity::getOriginSessionId()
{
	return module::getGroupListModule()->getOriginalSId(sessionID);
}
UInt32 SessionEntity::getOriginIntegerSessionId()
{
	return util::stringToInt32(getOriginSessionId());
}
NAMESPACE_END(module)
/******************************************************************************/