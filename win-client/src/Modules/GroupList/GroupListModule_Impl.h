/*******************************************************************************
 *  @file      GroupListModule_Impl.h 2014\8\6 15:30:37 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef GROUPLISTMODULE_IMPL_A4D4E682_0D42_4CF1_BF4B_B05E2F62C248_H__
#define GROUPLISTMODULE_IMPL_A4D4E682_0D42_4CF1_BF4B_B05E2F62C248_H__

#include "Modules/IGroupListModule.h"
#include "network/Lock.h"
/******************************************************************************/

/**
 * The class <code>GroupListModule_Impl</code> 
 *
 */
class CImPdu;
class GroupListModule_Impl final : public module::IGroupListModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    GroupListModule_Impl() = default;
    /**
     * Destructor
     */
    virtual ~GroupListModule_Impl() = default;
    //@}
	virtual void release();
	virtual void onPacket(imcore::TTPBHeader& header, std::string& pbBody);

public:
	virtual BOOL startup();

	virtual void getAllGroupListInfo(OUT module::GroupInfoMap& Groups);
	virtual BOOL getGroupInfoBySId(IN const std::string& sID, OUT module::GroupInfoEntity& groupInfo);
	virtual BOOL deleteGroupInfoById(IN const std::string& sGroupId);

	virtual BOOL popAddedMemberVecBySId(IN const std::string& sID, OUT module::UserInfoEntityVec& AddedMemberVec);
	virtual BOOL popRemovedMemberVecBySId(IN const std::string& sID, OUT module::UserInfoEntityVec& RemovedMemberVec);

	virtual CString getDefaultAvatartPath();

	virtual void tcpGetGroupInfo(IN const std::string& groupId);
	virtual void tcpGetGroupsInfo(IN const module::GroupVec& VecGroupId);//获取新群的信息
	virtual void tcpShieldGroup(IN const std::string& groupId, IN UInt32 shieldStatus);//设置群的推送不推送

	virtual void GetSearchGroupNameListByShortName(IN const CString& sShortName, OUT	module::GroupVec & gidList);
	virtual void onCreateDiscussionGrpDialog(const std::string& currentSessionId);
	virtual void onChangeDiscussionGrpMemberDialog(const std::string& currentSessionId);

	virtual std::string makeGroupSId(const std::string& sid);
	virtual std::string getOriginalSId(const std::string& sid);
private:
	/**@name 服务器端拆包*/
	//@{
	void _groupNormalListResponse(IN std::string& body);
	void _groupInfoResponse(IN std::string& body);
	void _groupCreateDiscussGroupResponse(IN std::string& body);
	void _groupChangedGroupMembersResponse(IN std::string& body);
	void _groupShieldResponse(IN std::string& body);
	void _groupChangeMemberNotify(IN std::string& body);
	//@}

	void _creatAndSaveSessionToDB(IN module::GroupInfoEntity& groupInfo);
	void _downloadAllGroupAvatarImg();
	void onCallbackOperation(std::shared_ptr<void> param);

	void _safePushBack(IN const std::string& Id,OUT std::list<std::string>& IdList);
private:
	CLock					m_lock;

	module::GroupInfoMap                m_mapGroups;       //每个群的详细信息

	std::map<std::string, module::UserInfoEntityVec> m_mapAddedMember;
	std::map<std::string, module::UserInfoEntityVec> m_mapRemovedMember;
};
/******************************************************************************/
#endif// GROUPLISTMODULE_IMPL_a4d4e682-0d42-4cf1-bf4b-b05e2f62c248_H__
