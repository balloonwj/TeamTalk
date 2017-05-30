/******************************************************************************* 
 *  @file      LoginModule_Impl.cpp 2014\7\17 19:51:47 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#include "stdafx.h"

#include "LoginModule_Impl.h"
#include "LoginDialog.h"
#include "ReloginManager.h"
#include "ProtocolBuffer/IM.Login.pb.h"
#include "ProtocolBuffer/IM.Buddy.pb.h"
#include "ProtocolBuffer/IM.Group.pb.h"
#include "Modules/ITcpClientModule.h"
#include "Modules/ISysConfigModule.h"
#include "Modules/IMiscModule.h"
#include "utility/utilCommonAPI.h"
#include "utility/Multilingual.h"
#include "utility/utilStrCodingAPI.h"
#include "network/ImCore.h"
#include "network/TTPBHeader.h"
/******************************************************************************/

namespace module
{
	ILoginModule* getLoginModule()
	{
		static LoginModule_Impl module;
		return &module;
	}
}
// -----------------------------------------------------------------------------
//  LoginModule_Impl: Public, Constructor

LoginModule_Impl::LoginModule_Impl()
:m_pReloginManager(0)
,m_bIsOfflineByMyself(FALSE)
{

}

// -----------------------------------------------------------------------------
//  LoginModule_Impl: Public, Destructor

LoginModule_Impl::~LoginModule_Impl()
{
	delete m_pReloginManager;
	m_pReloginManager = 0;
}

BOOL LoginModule_Impl::showLoginDialog()
{
	BOOL bRet = FALSE;
	LoginDialog* pDialog = new LoginDialog();
	PTR_FALSE(pDialog);
	CString csTitle = util::getMultilingual()->getStringById(_T("STRID_LOGINDIALOG_BTN_LOGIN"));
	pDialog->Create(NULL, csTitle, UI_CLASSSTYLE_DIALOG, WS_EX_STATICEDGE | WS_EX_APPWINDOW, 0, 0, 0, 0);
	pDialog->CenterWindow();
	bRet = (IDOK == pDialog->ShowModal());

	return bRet;
}

void LoginModule_Impl::notifyLoginDone()
{
	imcore::IMLibCoreStartOperationWithLambda(
		[]
	{
		//获取部门信息
		UInt32 lastTime = module::getSysConfigModule()->getDepartmentInfoLatestUpdateTime();
		IM::Buddy::IMDepartmentReq imDepartmentReq;
		imDepartmentReq.set_user_id(module::getSysConfigModule()->userId());
		imDepartmentReq.set_latest_update_time(lastTime);
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_BUDDY_LIST
			, IM::BaseDefine::BuddyListCmdID::CID_BUDDY_LIST_DEPARTMENT_REQUEST
			, &imDepartmentReq);
		LOG__(APP, _T("IMDepartmentReq,latest update time :%d"), lastTime);

		//增量获取所有人信息
		lastTime = module::getSysConfigModule()->getUserInfoLatestUpdateTime();//获取最后一次更新人员信息的时间
		IM::Buddy::IMAllUserReq imAllUserReq;
		imAllUserReq.set_user_id(module::getSysConfigModule()->userId());
		imAllUserReq.set_latest_update_time(lastTime);
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_BUDDY_LIST
			, IM::BaseDefine::BuddyListCmdID::CID_BUDDY_LIST_ALL_USER_REQUEST
			,&imAllUserReq);
		LOG__(APP, _T("IMAllUserReq,latest update time :%d"), lastTime);

		//增量获取群列表
		IM::Group::IMNormalGroupListReq imNormalGroupListReq;
		imNormalGroupListReq.set_user_id(module::getSysConfigModule()->userId());
		module::getTcpClientModule()->sendPacket(IM::BaseDefine::ServiceID::SID_GROUP
			, IM::BaseDefine::GroupCmdID::CID_GROUP_NORMAL_LIST_REQUEST
			, &imNormalGroupListReq);
		LOG__(APP, _T("IMNormalGroupListReq"));
	});
}
void LoginModule_Impl::onPacket(imcore::TTPBHeader& header, std::string& pbBody)
{
	switch (header.getCommandId())
	{
	case IM::BaseDefine::LoginCmdID::CID_LOGIN_KICK_USER:
		_kickUserResponse(pbBody);
		break;
	default:
		return;
	}
}
void LoginModule_Impl::_kickUserResponse(IN std::string& pbBody)
{
	IM::Login::IMKickUser imKickUser;
	if (!imKickUser.ParseFromString(pbBody))
	{
		LOG__(ERR, _T("ParseFromString failed,body:%s"), util::stringToCString(pbBody));
		return;
	}
	LOG__(APP, _T("IMKickUser kick_reason = %d"),imKickUser.kick_reason());
	if (IM::BaseDefine::KickReasonType::KICK_REASON_DUPLICATE_USER == imKickUser.kick_reason()
		|| IM::BaseDefine::KickReasonType::KICK_REASON_MOBILE_KICK == imKickUser.kick_reason())
	{
		module::getLoginModule()->asynNotifyObserver(module::KEY_LOGIN_KICKOUT, Int32(imKickUser.kick_reason()));
	}
}

void LoginModule_Impl::relogin(BOOL bForce)
{
	if (!m_pReloginManager)
	{
		m_pReloginManager = new ReloginManager;
	}
	if (bForce)
	{
		m_pReloginManager->forceRelogin();
	}
	else
	{
		m_pReloginManager->startReloginTimer(3);
	}
}

BOOL LoginModule_Impl::isOfflineByMyself()const
{
	return m_bIsOfflineByMyself;
}

void LoginModule_Impl::setOfflineByMyself(BOOL b)
{
	m_bIsOfflineByMyself = b;
}

/******************************************************************************/