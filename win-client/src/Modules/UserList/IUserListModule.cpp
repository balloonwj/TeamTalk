/******************************************************************************* 
 *  @file      IUserListModule.cpp 2014\8\26 16:36:25 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "stdafx.h"
#include "Modules/IUserListModule.h"
#include "Modules/ITcpClientModule.h"

/******************************************************************************/
NAMESPACE_BEGIN(module)
CString UserInfoEntity::getRealName()const
{
	if (!csNickName.IsEmpty())
	{
		return csNickName;
	}
	else if (!csName.IsEmpty())
	{
		return csName;
	}
	else
	{
		return util::stringToCString(sId);
	}
}

std::string UserInfoEntity::getAvatarPath()const
{
	//获取当前登录状态
	UInt8 netState = module::getTcpClientModule()->getTcpClientNetState();
	std::string path;
	if (module::TCPCLIENT_STATE_OK == netState 
		&& IM::BaseDefine::USER_STATUS_OFFLINE != onlineState)
	{
		path = avatarLocalPath;
		if (path.empty())
		{
			std::string sDataPath = util::cStringToString(module::getMiscModule()->getDefaultAvatar());
			path = sDataPath + "default.png";
		}
	}
	else
	{
		path = avatarGrayLocalPath;
		if (path.empty())
		{
			std::string sDataPath = util::cStringToString(module::getMiscModule()->getDefaultAvatar());
			path = sDataPath + "gray_default.png";
		}
	}
	return path;
}

std::string UserInfoEntity::getAvatarPathWithoutOnlineState()const
{
	std::string path = avatarLocalPath;
	if (path.empty())
	{
		std::string sDataPath = util::cStringToString(module::getMiscModule()->getDefaultAvatar());
		path = sDataPath + "default.png";
	}
	return path;
}

BOOL UserInfoEntity::isOnlne() const
{
	UInt8 netState = module::getTcpClientModule()->getTcpClientNetState();
	return (IM::BaseDefine::USER_STATUS_ONLINE == onlineState && module::TCPCLIENT_STATE_OK == netState) ? TRUE : FALSE;
}

NAMESPACE_END(module)
/******************************************************************************/