/*******************************************************************************
 *  @file      MessageEntity.h 2014\7\25 22:59:38 $
 *  @author    大佛<dafo@mogujie.com>
 *  @brief   
 ******************************************************************************/

#ifndef MESSAGEENTITY_35FE027F_F23D_4444_B013_9FCF04145DD6_H__
#define MESSAGEENTITY_35FE027F_F23D_4444_B013_9FCF04145DD6_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"

/******************************************************************************/

///////////////////////////消息类型跟服务器一致///////////////////////////////////////////////
enum MSG_TYPE_SERVER{
	MSG_TYPE_TEXT_P2P = 0x01,
	MSG_TYPE_AUDIO_P2P = 0x02,
	MSG_TYPE_TEXT_GROUP = 0x11,
	MSG_TYPE_AUDIO_GROUP = 0x12,
};

enum MSG_TYPE_RENDER//消息渲染类型--这个是给IE显示用的
{
	MESSAGE_RENDERTYPE_TEXT = 1,            //纯文本消息
	MESSAGE_RENDERTYPE_IMAGE = 2,               //纯图片
	MESSAGE_RENDERTYPE_SYSTEMTIPS = 4,          //系统提示
	MESSAGE_RENDERTYPE_FILETRANSFER = 5,        //文件提示
	MESSAGE_RENDERTYPE_AUDIO = 6,               //语音消息
};

enum MSG_TYPE_STATUS
{
	MESSAGE_TYPE_NONE = -1,
	MESSAGE_TYPE_RUNTIME = 0,               //运行时消息
	MESSAGE_TYPE_OFFLINE,                   //离线消息
	MESSAGE_TYPE_HISTORY,                   //历史消息
};
enum MSG_TYPE_FROM		//消息来源类型
{
	MESSAGETYPE_FROM_ERROR = 0,
	MESSAGETYPE_FROM_FRIEND,				//来自点对点的好友消息
	MESSAGETYPE_FROM_GROUP,					//来自群的消息
};

class MODULE_API MessageEntity
{
public:

    MessageEntity();
    ~MessageEntity() = default;

public:
	UInt8			msgType;            //消息类型		 1.文本消息；100.语音消息	MSG_TYPE_SERVER
	UInt8			msgStatusType;      //消息的状态类型 0 在线 1 离线、2 历史		MSG_TYPE_STATUS
	UInt8			msgRenderType;      //消息渲染类型								MSG_TYPE_RENDER
	UInt8			msgSessionType;		//消息来源		 1.个人消息；2.群消息
	UInt32          msgTime;            //消息收发时间
	std::string     content;            //消息内容
	std::string     imageId;            //图片ID
	std::string     talkerSid;          //消息的发送者
	std::string     sessionId;          //会话的ID
	UInt32		    msgId;				//msg ID

	//语音相关
	UInt8           msgAudioTime;       //语音消息时长
	UInt8           msgAudioReaded;     //已经播放过的语音

public:
	BOOL isMySendMsg()const;
	BOOL isFromGroupMsg()const;
	BOOL getSenderInfo(OUT CString& senderName, OUT std::string& senderAvatartPath);//获取发送者的名称和头像路径
	BOOL makeGroupSessionId();//当收到消息时候，如果是群消息要增加前缀 "group_"
	inline  BOOL isReaded()const; //for audio msg

public:
	//群功能
	std::string getOriginSessionId();
};
/******************************************************************************/
#endif// MESSAGEENTITY_35FE027F_F23D_4444_B013_9FCF04145DD6_H__
