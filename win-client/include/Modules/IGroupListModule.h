/*******************************************************************************
 *  @file      IGroupListModule.h 2014\8\6 15:29:01 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     群、讨论组相关模块
 ******************************************************************************/

#ifndef IGROUPLISTMODULE_3AD36DFC_4041_486A_A437_948E152517E8_H__
#define IGROUPLISTMODULE_3AD36DFC_4041_486A_A437_948E152517E8_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"
#include "Modules/IUserListModule.h"
#include "Modules/IModuleInterface.h"
#include "Modules/ModuleBase.h"
#include <list>
#include <string>
/******************************************************************************/
NAMESPACE_BEGIN(module)
const std::string MODULE_GROUPLIST_PREFIX = "grouplist";

//KEYID
const std::string KEY_GROUPLIST_UPDATE_GROUPLIST		= MODULE_GROUPLIST_PREFIX + "GroupList";		//UI更新固定群和讨论组
const std::string KEY_GROUPLIST_UPDATE_GROUPINFO_UPDATE	= MODULE_GROUPLIST_PREFIX + "GroupInfoUpdate";//更新了群信息（可能是固定群，也可能是讨论组）
const std::string KEY_GROUPLIST_UPDATE_CREATNEWGROUP	= MODULE_GROUPLIST_PREFIX + "CreateNewGroup";	//创建一个讨论组返回
const std::string KEY_GROUPLIST_UPDATE_MEMBER_CHANGED	= MODULE_GROUPLIST_PREFIX + "MembersChanged";	//成员变动
const std::string KEY_GROUPLIST_UPDATE_MYSELF_KICKED	= MODULE_GROUPLIST_PREFIX + "MySelfKicked";		//自己被踢出了群
const std::string KEY_GROUPLIST_UPDATE_SHIELD_SUCCEED   = MODULE_GROUPLIST_PREFIX + "GroupShieldSucceed";	//群屏蔽成功
class GroupInfoEntity
{
public:
	std::string			gId;					//群ID
	std::string			avatarUrl;
	std::string			avatarLocalPath;        //头像下载成功后的存储路径
	std::string			creatorId;				//群创建者Id
	CString				desc;					//群公告
	CString				csName;
	UInt32				type = 0;				//群类型：1，固定群 2,讨论组
	UInt32				groupUpdated = 0;		//最后一次更新消息时间
	UInt32				version = 0;			//群版本
	UInt32				shieldStatus = 0;		//群消息推送是否屏蔽 0: 不屏蔽 1: 屏蔽
	std::list<std::string>	groupMemeberList;

public:
	std::string getAvatarPath()
	{
		std::string path = avatarLocalPath;
		if (path.empty())
		{
			std::string sDataPath = util::cStringToString(module::getMiscModule()->getDefaultAvatar());
			if (1 == type)
			{
				path = sDataPath + "Groups.png";
			}
			else
			{
				path = sDataPath + "DiscussionGroups.png";
			}
		}
		else
		{
			std::string sDownPath = util::cStringToString(module::getMiscModule()->getDownloadDir());
			path = sDownPath + avatarLocalPath;
		}
		return path;
	}
};

typedef std::map<std::string, GroupInfoEntity>       GroupInfoMap;//群列表
typedef std::vector<std::string>					 GroupVec;//群列表ID,最近联系群
/**
 * The class <code>群、讨论组相关模块</code> 
 *
 */
class MODULE_API IGroupListModule : public module::ModuleBase
								  , public module::IPduPacketParse
{
public:
	/**
	* 获取所有群的信息，用于插入群列表
	*
	* @param   OUT module::GroupMap & Groups
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void getAllGroupListInfo(OUT module::GroupInfoMap& Groups) = 0;
	/**
	* 查询群信息
	*
	* @param   IN const std::string & sID
	* @param   OUT module::GroupInfoEntity & groupInfo
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	
	virtual BOOL getGroupInfoBySId(IN const std::string& sID, OUT module::GroupInfoEntity& groupInfo) = 0;

	virtual BOOL deleteGroupInfoById(IN const std::string& sGroupId) = 0;
	/**
	* 获取群新增人员
	*
	* @param   IN const std::string & sID
	* @param   OUT module::VecUserInfoEntity & AddedMemberVec
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	virtual BOOL popAddedMemberVecBySId(IN const std::string& sID, OUT module::UserInfoEntityVec& AddedMemberVec) = 0;
	/**
	* 获取群刚踢掉的人员
	*
	* @param   IN const std::string & sID
	* @param   OUT module::VecUserInfoEntity & RemovedMemberVec
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	virtual BOOL popRemovedMemberVecBySId(IN const std::string& sID, OUT module::UserInfoEntityVec& RemovedMemberVec) = 0;

	/**
	* 获取默认的群头像信息
	*
	* @return  CString
	* @exception there is no any exception to throw.
	*/
	virtual CString getDefaultAvatartPath() = 0;
	/**
	* 获取新的群成员
	*
	* @param   IN const std::string & groupId
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void tcpGetGroupInfo(IN const std::string& groupId) = 0;//获取新群的信息
	virtual void tcpGetGroupsInfo(IN const module::GroupVec& VecGroupId) = 0;//获取新群的信息
	virtual void tcpShieldGroup(IN const std::string& groupId, IN UInt32 shieldStatus) = 0;//设置群的推送不推送
	virtual void onCreateDiscussionGrpDialog(const std::string& currentSessionId) = 0;
	virtual void onChangeDiscussionGrpMemberDialog(const std::string& currentSessionId) = 0;

	virtual void GetSearchGroupNameListByShortName(IN const CString& sShortName, OUT module::GroupVec & gidList) = 0;

	virtual std::string makeGroupSId(const std::string& sid) = 0;
	virtual std::string getOriginalSId(const std::string& sid) = 0;
	virtual BOOL startup() = 0;
};

MODULE_API IGroupListModule* getGroupListModule();

NAMESPACE_END(module)
/******************************************************************************/
#endif// IGROUPLISTMODULE_3AD36DFC_4041_486A_A437_948E152517E8_H__
