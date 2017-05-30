//
//  MTMessageEntity.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMessage.pb.h"

typedef NS_ENUM(NSUInteger, MTMessageType)
{
    MessageTypeNormal,
    MessageTypeVoice
};

typedef NS_ENUM(NSUInteger, MTMessageSendState)
{
    MessageSending,
    MessageSendSuccess,
    MessageSendFailure
};

@interface MTMessageEntity : NSObject

/**
 *  消息ID,本地自增长
 */
@property (nonatomic,assign)NSUInteger messageID;

/**
 *  消息ID，服务端自增长
 */
@property (nonatomic,assign)NSUInteger messageServerID;

/**
 *  消息类型
 */
@property (nonatomic,assign)MTMessageType messageType;

/**
 *  消息时间
 */
@property (nonatomic,assign)NSUInteger messageTime;

/**
 *  会话ID
 */
@property (nonatomic,retain)NSString* sessionID;

/**
 *  发送者ID
 */
@property (nonatomic,retain)NSString* senderID;

/**
 *  目标ID
 */
@property (nonatomic,retain)NSString* targetID;

/**
 *  消息内容
 */
@property (nonatomic,retain)id messageContent;

/**
 *  消息发送状态
 */
@property (nonatomic,assign)MTMessageSendState sendState;

/**
 *  消息实体初始化方法
 *
 *  @param messageID      消息ID
 *  @param messageType    消息类型
 *  @param messageTime    消息时间
 *  @param sessionID      会话ID
 *  @param senderID       发送者ID
 *  @param targetID       目标ID
 *  @param messageContent 消息内容
 *
 *  @return 消息实体
 */
- (instancetype)initWithServerMessageID:(NSUInteger)messageServerID
                             type:(MTMessageType)messageType
                      messageTime:(NSUInteger)messageTime
                        sessionID:(NSString*)sessionID
                         senderID:(NSString*)senderID
                         targetID:(NSString*)targetID
                          content:(id)messageContent
                            state:(MTMessageSendState)state;


/**
 *  这个初始化方法只在接收到消息的地方用，其他地方切记不能用
 *
 *  @param msgData pb中的消息数据包
 *
 *  @return 消息实体
 */
-(instancetype)initWithMessageData:(IMMsgData *)msgData;

- (instancetype)initWithMesssageInfo:(MsgInfo*)msgInfo withSessionID:(NSString*)sessionID;

- (NSString*)getTextMessageContent;

- (BOOL)hasImages;

- (NSString*)toJson;

- (NSArray*)imageURL;

@end
