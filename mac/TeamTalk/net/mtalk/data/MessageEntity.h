/************************************************************
 * @file         MessageEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       消息实体信息
 ************************************************************/

#import <Foundation/Foundation.h>

static NSString* const GROUP_PRE = @"group_";          //group id 前缀

enum
{
    MESSAGE_TYPE_SINGLE =1,                 //单个人会话消息
    MESSAGE_TYPE_GROUP  =2,                     //群聊消息
    MESSAGE_TYPE_TEMP_GROUP  =3,                     //临时群消息.
};

@interface MessageEntity : NSObject

@property(nonatomic,assign) uint8 msgType;              //消息类型
@property(nonatomic,assign) uint8 msgRenderType;        //历史遗留字段，废弃
@property(nonatomic,assign) uint32 msgTime;             //消息收发时间
@property(nonatomic,assign) uint32 seqNo;               //服务器的ack number
@property(nonatomic,strong) NSString* sessionId;        //会话id，单人聊天时即发送者的ID,群聊天时表示加前缀的groupid
@property(nonatomic,strong) NSString* senderId;         //发送者的Id,群聊天表示发送者id
@property(nonatomic,strong) NSString* msgContent;       //消息内容
@property(nonatomic,strong) NSString* attach;           //

@property(nonatomic,readonly,strong)NSString* orginId;  //由于groupId和userId会存在重复情况，这里获取其原始的userid或者

- (BOOL)isEqualToMessage:(MessageEntity*)object;

@end
