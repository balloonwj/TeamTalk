package com.mogujie.tt.imservice.manager;


import com.google.protobuf.CodedInputStream;
import com.mogujie.tt.config.DBConstant;
import com.mogujie.tt.DB.DBInterface;
import com.mogujie.tt.DB.entity.GroupEntity;
import com.mogujie.tt.DB.entity.SessionEntity;
import com.mogujie.tt.DB.entity.UserEntity;
import com.mogujie.tt.imservice.callback.Packetlistener;
import com.mogujie.tt.imservice.event.GroupEvent;
import com.mogujie.tt.imservice.event.SessionEvent;
import com.mogujie.tt.protobuf.helper.EntityChangeEngine;
import com.mogujie.tt.protobuf.helper.ProtoBuf2JavaBean;
import com.mogujie.tt.protobuf.IMBaseDefine;
import com.mogujie.tt.protobuf.IMGroup;
import com.mogujie.tt.utils.IMUIHelper;
import com.mogujie.tt.utils.Logger;
import com.mogujie.tt.utils.pinyin.PinYin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import de.greenrobot.event.EventBus;


public class IMGroupManager extends IMManager {
    private Logger logger = Logger.getLogger(IMGroupManager.class);
    private static IMGroupManager inst = new IMGroupManager();
    public static IMGroupManager instance() {
        return inst;
    }

    // 依赖的服务管理
    private IMSocketManager imSocketManager = IMSocketManager.instance();
    private IMLoginManager imLoginManager=IMLoginManager.instance();
    private DBInterface dbInterface = DBInterface.instance();


    // todo Pinyin的处理
    //正式群,临时群都会有的，存在竞争 如果不同时请求的话
    private Map<Integer,GroupEntity> groupMap = new ConcurrentHashMap<>();
    // 群组状态
    private boolean isGroupReady = false;

    @Override
    public void doOnStart() {
        groupMap.clear();
    }

    public void onNormalLoginOk(){
        onLocalLoginOk();
        onLocalNetOk();
    }

    /**
     * 1. 加载本地信息
     * 2. 请求正规群信息 ， 与本地进行对比
     * 3. version groupId 请求
     * */
    public void onLocalLoginOk(){
        logger.i("group#loadFromDb");

        if(!EventBus.getDefault().isRegistered(inst)){
            EventBus.getDefault().registerSticky(inst);
        }

        // 加载本地group
        List<GroupEntity> localGroupInfoList = dbInterface.loadAllGroup();
        for(GroupEntity groupInfo:localGroupInfoList){
            groupMap.put(groupInfo.getPeerId(),groupInfo);
        }

        triggerEvent(new GroupEvent(GroupEvent.Event.GROUP_INFO_OK));
    }

    public void onLocalNetOk(){
        reqGetNormalGroupList();
    }

    @Override
    public void reset() {
        isGroupReady =false;
        groupMap.clear();
        EventBus.getDefault().unregister(inst);
    }

    public void onEvent(SessionEvent event){
        switch (event){
            case RECENT_SESSION_LIST_UPDATE:
                // groupMap 本地已经加载完毕之后才触发
                loadSessionGroupInfo();
                break;
        }
    }

    /**
     * 实现自身的事件驱动
     * @param event
     */
    public  synchronized void triggerEvent(GroupEvent event) {
        switch (event.getEvent()){
            case GROUP_INFO_OK:
                isGroupReady = true;
                break;
            case GROUP_INFO_UPDATED:
                isGroupReady = true;
                break;
        }
        EventBus.getDefault().postSticky(event);
    }

    /**---------------事件驱动end------------------------------*/

    /**
     * 1. 加载本地信息
     * 2. 从session中获取 群组信息，从本地中获取这些群组的version信息
     * 3. 合并上述的merge结果， version groupId 请求
     * */
    private void loadSessionGroupInfo(){
        logger.i("group#loadSessionGroupInfo");

        List<SessionEntity> sessionInfoList =   IMSessionManager.instance().getRecentSessionList();

        List<IMBaseDefine.GroupVersionInfo> needReqList = new ArrayList<>();
        for(SessionEntity sessionInfo:sessionInfoList){
            int version = 0;
            if(sessionInfo.getPeerType() == DBConstant.SESSION_TYPE_GROUP /**群组*/){
                if(groupMap.containsKey(sessionInfo.getPeerId())){
                    version = groupMap.get(sessionInfo.getPeerId()).getVersion();
                }

                IMBaseDefine.GroupVersionInfo versionInfo = IMBaseDefine.GroupVersionInfo.newBuilder()
                        .setVersion(version)
                        .setGroupId(sessionInfo.getPeerId())
                        .build();
                needReqList.add(versionInfo);
            }
        }
        // 事件触发的时候需要注意
        if(needReqList.size() >0){
            reqGetGroupDetailInfo(needReqList);
            return ;
        }
    }

    /**
     * 联系人页面正式群的请求
     * todo 正式群与临时群逻辑上的分开的，但是底层应该是想通的
     */
    private void reqGetNormalGroupList() {
        logger.i("group#reqGetNormalGroupList");
        int loginId = imLoginManager.getLoginId();
        IMGroup.IMNormalGroupListReq  normalGroupListReq = IMGroup.IMNormalGroupListReq.newBuilder()
                .setUserId(loginId)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_GROUP_VALUE;
        int cid = IMBaseDefine.GroupCmdID.CID_GROUP_NORMAL_LIST_REQUEST_VALUE;
        imSocketManager.sendRequest(normalGroupListReq,sid,cid);
        logger.i("group#send packet to server");
    }

    public void onRepNormalGroupList(IMGroup.IMNormalGroupListRsp normalGroupListRsp) {
        logger.i("group#onRepNormalGroupList");
        int groupSize = normalGroupListRsp.getGroupVersionListCount();
        logger.i("group#onRepNormalGroupList cnt:%d",groupSize);
        List<IMBaseDefine.GroupVersionInfo> versionInfoList =  normalGroupListRsp.getGroupVersionListList();

        /**对比DB中的version字段*/
        // 这块对比的可以抽离出来
        List<IMBaseDefine.GroupVersionInfo> needInfoList = new ArrayList<>();

        for(IMBaseDefine.GroupVersionInfo groupVersionInfo:versionInfoList ){
            int groupId =  groupVersionInfo.getGroupId();
            int version =  groupVersionInfo.getVersion();
            if(groupMap.containsKey(groupId) &&
                    groupMap.get(groupId).getVersion() ==version ){
                continue;
            }
            IMBaseDefine.GroupVersionInfo versionInfo = IMBaseDefine.GroupVersionInfo.newBuilder()
                    .setVersion(0)
                    .setGroupId(groupId)
                    .build();
            needInfoList.add(versionInfo);
        }

        // 事件触发的时候需要注意 todo
        if(needInfoList.size() >0){
            reqGetGroupDetailInfo(needInfoList);
        }
    }

    public void  reqGroupDetailInfo(int groupId){
        IMBaseDefine.GroupVersionInfo groupVersionInfo = IMBaseDefine.GroupVersionInfo.newBuilder()
                .setGroupId(groupId)
                .setVersion(0)
                .build();
        ArrayList<IMBaseDefine.GroupVersionInfo> list = new ArrayList<>();
        list.add(groupVersionInfo);
        reqGetGroupDetailInfo(list);
    }

    /**
     * 请求群组的详细信息
     */
    public void reqGetGroupDetailInfo(List<IMBaseDefine.GroupVersionInfo> versionInfoList){
        logger.i("group#reqGetGroupDetailInfo");
        if(versionInfoList == null || versionInfoList.size()<=0){
            logger.e("group#reqGetGroupDetailInfo# please check your params,cause by empty/null");
            return ;
        }
        int loginId = imLoginManager.getLoginId();
        IMGroup.IMGroupInfoListReq  groupInfoListReq = IMGroup.IMGroupInfoListReq.newBuilder()
                .setUserId(loginId)
                .addAllGroupVersionList(versionInfoList)
                .build();

        int sid = IMBaseDefine.ServiceID.SID_GROUP_VALUE;
        int cid = IMBaseDefine.GroupCmdID.CID_GROUP_INFO_REQUEST_VALUE;
        imSocketManager.sendRequest(groupInfoListReq,sid,cid);
    }


    public void onRepGroupDetailInfo(IMGroup.IMGroupInfoListRsp groupInfoListRsp){
        logger.i("group#onRepGroupDetailInfo");
        int groupSize = groupInfoListRsp.getGroupInfoListCount();
        int userId = groupInfoListRsp.getUserId();
        int loginId = imLoginManager.getLoginId();
        logger.i("group#onRepGroupDetailInfo cnt:%d",groupSize);
        if(groupSize <=0 || userId!=loginId){
            logger.i("group#onRepGroupDetailInfo size empty or userid[%d]≠ loginId[%d]",userId,loginId);
            return;
        }
        ArrayList<GroupEntity>  needDb = new ArrayList<>();
        for(IMBaseDefine.GroupInfo groupInfo:groupInfoListRsp.getGroupInfoListList()){
             // 群组的详细信息
             // 保存在DB中
             // GroupManager 中的变量
            GroupEntity groupEntity = ProtoBuf2JavaBean.getGroupEntity(groupInfo);
            groupMap.put(groupEntity.getPeerId(),groupEntity);
            needDb.add(groupEntity);
         }

        dbInterface.batchInsertOrUpdateGroup(needDb);
        triggerEvent(new GroupEvent(GroupEvent.Event.GROUP_INFO_UPDATED));
       }


    /**
     * 创建群
     * 默认是创建临时群，且客户端只能创建临时群
     */
    public void reqCreateTempGroup(String groupName, Set<Integer> memberList){

        logger.i("group#reqCreateTempGroup, tempGroupName = %s", groupName);

        int loginId = imLoginManager.getLoginId();

        IMGroup.IMGroupCreateReq groupCreateReq  = IMGroup.IMGroupCreateReq.newBuilder()
                .setUserId(loginId)
                .setGroupType(IMBaseDefine.GroupType.GROUP_TYPE_TMP)
                .setGroupName(groupName)
                .setGroupAvatar("")// todo 群头像 现在是四宫格
                .addAllMemberIdList(memberList)
                .build();

        int sid = IMBaseDefine.ServiceID.SID_GROUP_VALUE;
        int cid = IMBaseDefine.GroupCmdID.CID_GROUP_CREATE_REQUEST_VALUE;
        imSocketManager.sendRequest(groupCreateReq, sid, cid,new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMGroup.IMGroupCreateRsp groupCreateRsp  = IMGroup.IMGroupCreateRsp.parseFrom((CodedInputStream)response);
                    IMGroupManager.instance().onReqCreateTempGroup(groupCreateRsp);
                } catch (IOException e) {
                    logger.e("reqCreateTempGroup parse error");
                    triggerEvent(new GroupEvent(GroupEvent.Event.CREATE_GROUP_FAIL));
                }
            }

            @Override
            public void onFaild() {
              triggerEvent(new GroupEvent(GroupEvent.Event.CREATE_GROUP_FAIL));
            }

            @Override
            public void onTimeout() {
              triggerEvent(new GroupEvent(GroupEvent.Event.CREATE_GROUP_TIMEOUT));
            }
        });

    }

    public void onReqCreateTempGroup(IMGroup.IMGroupCreateRsp groupCreateRsp){
        logger.d("group#onReqCreateTempGroup");

        int resultCode = groupCreateRsp.getResultCode();
        if(0 != resultCode){
            logger.e("group#createGroup failed");
            triggerEvent(new GroupEvent(GroupEvent.Event.CREATE_GROUP_FAIL));
            return;
        }
        GroupEntity groupEntity = ProtoBuf2JavaBean.getGroupEntity(groupCreateRsp);
        // 更新DB 更新map
        groupMap.put(groupEntity.getPeerId(),groupEntity);

        IMSessionManager.instance().updateSession(groupEntity);
        dbInterface.insertOrUpdateGroup(groupEntity);
        triggerEvent(new GroupEvent(GroupEvent.Event.CREATE_GROUP_OK, groupEntity)); // 接收到之后修改UI
    }

    /**
     * 删除群成员
     * REMOVE_CHANGE_MEMBER_TYPE
     * 可能会触发头像的修改
     */
    public void reqRemoveGroupMember(int groupId,Set<Integer> removeMemberlist){
        reqChangeGroupMember(groupId,IMBaseDefine.GroupModifyType.GROUP_MODIFY_TYPE_DEL, removeMemberlist);
    }
    /**
     * 新增群成员
     * ADD_CHANGE_MEMBER_TYPE
     * 可能会触发头像的修改
     */
    public void reqAddGroupMember(int groupId,Set<Integer> addMemberlist){
        reqChangeGroupMember(groupId,IMBaseDefine.GroupModifyType.GROUP_MODIFY_TYPE_ADD, addMemberlist);
    }

    private void reqChangeGroupMember(int groupId,IMBaseDefine.GroupModifyType groupModifyType, Set<Integer> changeMemberlist) {
        logger.i("group#reqChangeGroupMember, changeGroupMemberType = %s", groupModifyType.toString());

        final int loginId = imLoginManager.getLoginId();
        IMGroup.IMGroupChangeMemberReq groupChangeMemberReq = IMGroup.IMGroupChangeMemberReq.newBuilder()
                .setUserId(loginId)
                .setChangeType(groupModifyType)
                .addAllMemberIdList(changeMemberlist)
                .setGroupId(groupId)
                .build();

        int sid = IMBaseDefine.ServiceID.SID_GROUP_VALUE;
        int cid = IMBaseDefine.GroupCmdID.CID_GROUP_CHANGE_MEMBER_REQUEST_VALUE;
        imSocketManager.sendRequest(groupChangeMemberReq, sid, cid,new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMGroup.IMGroupChangeMemberRsp groupChangeMemberRsp = IMGroup.IMGroupChangeMemberRsp.parseFrom((CodedInputStream)response);
                    IMGroupManager.instance().onReqChangeGroupMember(groupChangeMemberRsp);
                } catch (IOException e) {
                    logger.e("reqChangeGroupMember parse error!");
                    triggerEvent(new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_FAIL));
                }
            }

            @Override
            public void onFaild() {
                triggerEvent(new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_FAIL));
            }

            @Override
            public void onTimeout() {
                triggerEvent(new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_TIMEOUT));
            }
        });

    }

    public void onReqChangeGroupMember(IMGroup.IMGroupChangeMemberRsp groupChangeMemberRsp){
        int resultCode = groupChangeMemberRsp.getResultCode();
        if (0 != resultCode){
            triggerEvent(new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_FAIL));
            return;
        }

        int groupId = groupChangeMemberRsp.getGroupId();
        List<Integer> changeUserIdList = groupChangeMemberRsp.getChgUserIdListList();
        IMBaseDefine.GroupModifyType groupModifyType = groupChangeMemberRsp.getChangeType();


        GroupEntity groupEntityRet = groupMap.get(groupId);
        groupEntityRet.setlistGroupMemberIds(groupChangeMemberRsp.getCurUserIdListList());
        groupMap.put(groupId,groupEntityRet);
        dbInterface.insertOrUpdateGroup(groupEntityRet);


        GroupEvent groupEvent = new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_SUCCESS);
        groupEvent.setChangeList(changeUserIdList);
        groupEvent.setChangeType(ProtoBuf2JavaBean.getGroupChangeType(groupModifyType));
        groupEvent.setGroupEntity(groupEntityRet);
        triggerEvent(groupEvent);
    }

    /**
     * 屏蔽群消息
     * IMGroupShieldReq
     * 备注:应为屏蔽之后大部分操作依旧需要客户端做
     * */
    public void reqShieldGroup(final int groupId,final int shieldType){
        final GroupEntity entity =  groupMap.get(groupId);
        if(entity == null){
            logger.i("GroupEntity do not exist!");
            return;
        }
        final int loginId = IMLoginManager.instance().getLoginId();
        IMGroup.IMGroupShieldReq shieldReq = IMGroup.IMGroupShieldReq.newBuilder()
                .setShieldStatus(shieldType)
                .setGroupId(groupId)
                .setUserId(loginId)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_GROUP_VALUE;
        int cid = IMBaseDefine.GroupCmdID.CID_GROUP_SHIELD_GROUP_REQUEST_VALUE;
        imSocketManager.sendRequest(shieldReq,sid,cid,new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMGroup.IMGroupShieldRsp groupShieldRsp = IMGroup.IMGroupShieldRsp.parseFrom((CodedInputStream)response);
                    int resCode = groupShieldRsp.getResultCode();
                    if(resCode !=0){
                        triggerEvent(new GroupEvent(GroupEvent.Event.SHIELD_GROUP_FAIL));
                        return;
                    }
                    if(groupShieldRsp.getGroupId() != groupId || groupShieldRsp.getUserId()!=loginId){
                        return;
                    }
                    // 更新DB状态
                    entity.setStatus(shieldType);
                    dbInterface.insertOrUpdateGroup(entity);
                    // 更改未读计数状态
                    boolean isFor = shieldType == DBConstant.GROUP_STATUS_SHIELD;
                    IMUnreadMsgManager.instance().setForbidden(
                            EntityChangeEngine.getSessionKey(groupId,DBConstant.SESSION_TYPE_GROUP),isFor);
                    triggerEvent(new GroupEvent(GroupEvent.Event.SHIELD_GROUP_OK,entity));

                } catch (IOException e) {
                    logger.e("reqChangeGroupMember parse error!");
                    triggerEvent(new GroupEvent(GroupEvent.Event.SHIELD_GROUP_FAIL));
                }
            }
            @Override
            public void onFaild() {
                triggerEvent(new GroupEvent(GroupEvent.Event.SHIELD_GROUP_FAIL));
            }

            @Override
            public void onTimeout() {
                triggerEvent(new GroupEvent(GroupEvent.Event.SHIELD_GROUP_TIMEOUT));
            }
        });
    }


    /**
     * 收到群成员发生变更消息
     * 服务端主动发出
     * DB
     */
    public void receiveGroupChangeMemberNotify(IMGroup.IMGroupChangeMemberNotify notify){
       int groupId =  notify.getGroupId();
       int changeType = ProtoBuf2JavaBean.getGroupChangeType(notify.getChangeType());
       List<Integer> changeList =  notify.getChgUserIdListList();

       List<Integer> curMemberList = notify.getCurUserIdListList();
       if(groupMap.containsKey(groupId)){
           GroupEntity entity = groupMap.get(groupId);
           entity.setlistGroupMemberIds(curMemberList);
           dbInterface.insertOrUpdateGroup(entity);
           groupMap.put(groupId,entity);

           GroupEvent groupEvent = new GroupEvent(GroupEvent.Event.CHANGE_GROUP_MEMBER_SUCCESS);
           groupEvent.setChangeList(changeList);
           groupEvent.setChangeType(changeType);
           groupEvent.setGroupEntity(entity);
           triggerEvent(groupEvent);
       }else{
           //todo 没有就暂时不管了，只要聊过天都会显示在回话里面
       }
    }

	public List<GroupEntity> getNormalGroupList() {
		List<GroupEntity> normalGroupList = new ArrayList<>();
		for (Entry<Integer, GroupEntity> entry : groupMap.entrySet()) {
			GroupEntity group = entry.getValue();
			if (group == null) {
				continue;
			}
			if (group.getGroupType() == DBConstant.GROUP_TYPE_NORMAL) {
				normalGroupList.add(group);
			}
		}
		return normalGroupList;
	}

    // 该方法只有正式群
    // todo eric efficiency
    public  List<GroupEntity> getNormalGroupSortedList() {
        List<GroupEntity> groupList = getNormalGroupList();
        Collections.sort(groupList, new Comparator<GroupEntity>(){
            @Override
            public int compare(GroupEntity entity1, GroupEntity entity2) {
                if(entity1.getPinyinElement().pinyin==null)
                {
                    PinYin.getPinYin(entity1.getMainName(), entity1.getPinyinElement());
                }
                if(entity2.getPinyinElement().pinyin==null)
                {
                    PinYin.getPinYin(entity2.getMainName(),entity2.getPinyinElement());
                }
                return entity1.getPinyinElement().pinyin.compareToIgnoreCase(entity2.getPinyinElement().pinyin);
            }
        });

        return groupList;
    }

	public GroupEntity findGroup(int groupId) {
		logger.d("group#findGroup groupId:%s", groupId);
        if(groupMap.containsKey(groupId)){
            return groupMap.get(groupId);
        }
        return null;
	}

    public List<GroupEntity>  getSearchAllGroupList(String key){
        List<GroupEntity> searchList = new ArrayList<>();
        for(Map.Entry<Integer,GroupEntity> entry:groupMap.entrySet()){
            GroupEntity groupEntity = entry.getValue();
            if (IMUIHelper.handleGroupSearch(key, groupEntity)) {
                searchList.add(groupEntity);
            }
        }
        return searchList;
    }

	public List<UserEntity> getGroupMembers(int groupId) {
		logger.d("group#getGroupMembers groupId:%s", groupId);

		GroupEntity group = findGroup(groupId);
		if (group == null) {
			logger.e("group#no such group id:%s", groupId);
			return null;
		}
        Set<Integer> userList = group.getlistGroupMemberIds();
		ArrayList<UserEntity> memberList = new ArrayList<UserEntity>();
		for (Integer id : userList) {
			UserEntity contact = IMContactManager.instance().findContact(id);
			if (contact == null) {
				logger.e("group#no such contact id:%s", id);
				continue;
			}
			memberList.add(contact);
		}
		return memberList;
	}

    /**------set/get 的定义*/
    public Map<Integer, GroupEntity> getGroupMap() {
        return groupMap;
    }

    public boolean isGroupReady() {
        return isGroupReady;
    }
}
