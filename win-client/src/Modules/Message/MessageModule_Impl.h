/*******************************************************************************
 *  @file      HistoryMsgModule_Impl.h 2014\8\3 11:12:29 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef HISTORYMSGMODULE_IMPL_C28C3F8C_9A47_48DF_840B_BE394EAFFFEA_H__
#define HISTORYMSGMODULE_IMPL_C28C3F8C_9A47_48DF_840B_BE394EAFFFEA_H__
#include "network/Lock.h"
#include "Modules/IMessageModule.h"
#include <map>
/******************************************************************************/
class CppSQLite3DB;

/**
 * The class <code>HistoryMsgModule_Impl</code> 
 *
 */
class MessageModule_Impl final : public module::IMessageModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    MessageModule_Impl();
    /**
     * Destructor
     */
    virtual ~MessageModule_Impl();
    //@}

public:
	/**@name 历史消息相关*/
	//@{
	virtual BOOL getHistoryMessage(IN const std::string& sId, IN UInt32 nMsgCount
								 , IN BOOL scrollBottom, OUT std::vector<MessageEntity>& msgList);
	virtual void setSessionTopMsgId(const std::string& sId,UInt32 msgId);
	//@}

	/**@name 运行时消息相关*/
	//@{
	virtual void removeMessageBySId(const std::string& sId);//断线重连的情况下要清理消息 
	virtual void removeAllMessage();
	virtual BOOL pushMessageBySId(const std::string& sId, MessageEntity& msg);
	virtual UInt32 getTotalUnReadMsgCount(void);
	//@}

private:
	void _closeDB();
	void _msgToTrace(const MessageEntity& msg);
	UInt32 _getSessionTopMsgId(const std::string& sId);

private:
	CLock									m_lock;
	std::map<std::string, UInt32>			m_mapSessionTopMsgId;	//会话聊天面板第一条展现消息的msg_id
};
/******************************************************************************/
#endif// HISTORYMSGMODULE_IMPL_C28C3F8C_9A47_48DF_840B_BE394EAFFFEA_H__
