/*
 * GroupChat.h
 *
 *  Created on: 2014-1-3
 *      Author: ziteng@mogujie.com
 */

#ifndef GROUPCHAT_H_
#define GROUPCHAT_H_

#include "ImPduBase.h" 

typedef set<uint32_t> group_member_t;
typedef hash_map<uint32_t, group_member_t*> group_map_t;

class CMsgConn;

class CGroupChat
{
public:
	virtual ~CGroupChat() {}

	static CGroupChat* GetInstance();

    void HandleClientGroupNormalRequest(CImPdu* pPdu, CMsgConn* pFromConn);
    void HandleGroupNormalResponse(CImPdu* pPdu);
    
    void HandleClientGroupInfoRequest(CImPdu* pPdu, CMsgConn* pFromConn);
    void HandleGroupInfoResponse(CImPdu* pPdu);

	void HandleGroupMessage(CImPdu* pPdu);
    void HandleGroupMessageBroadcast(CImPdu* pPdu);
    
	void HandleClientGroupCreateRequest(CImPdu* pPdu, CMsgConn* pFromConn);
	void HandleGroupCreateResponse(CImPdu* pPdu);
    
	void HandleClientGroupChangeMemberRequest(CImPdu* pPdu, CMsgConn* pFromConn);
	void HandleGroupChangeMemberResponse(CImPdu* pPdu);
	void HandleGroupChangeMemberBroadcast(CImPdu* pPdu);

    void HandleClientGroupShieldGroupRequest(CImPdu* pPdu,
        CMsgConn* pFromConn);
    
    void HandleGroupShieldGroupResponse(CImPdu* pPdu);
    void HandleGroupGetShieldByGroupResponse(CImPdu* pPdu);
private:
	CGroupChat() {}	// for singleton;

	void _SendPduToUser(CImPdu* pPdu, uint32_t user_id, CMsgConn* pReqConn = NULL);
private:

	static CGroupChat* s_group_chat_instance;

	group_map_t m_group_map;
};


#endif /* GROUPCHAT_H_ */
