//
//  MTMessageModule.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDRootModule.h"
#import "MTMessageEntity.h"
#import "DDIntranetMessageEntity.h"
@class MTMessageEntity;

typedef void(^GetLastestMessageCompletion)(id message);
typedef void(^GetHistoryMessageCompletion)(NSArray* messages);
typedef void(^SendMessageCompletion)(MTMessageEntity* message,NSError* error);

#define DD_MESSAGE_MODULE_RECEIVE_MESSAGE               @"DDMessageModuleReceiveMessageNotification"

#define DD_MESSAGE_UNREAD_COUNT_KEY                     @"_unreadMessageCount"


@interface MTMessageModule : DDRootModule
+ (instancetype)shareInstance;
/**
 *  类方法，获取消息ID
 */
+ (NSUInteger)getMessageID;

/**
 *  获取会话最后一条消息的消息内容
 *
 *  @param sessionID 会话ID
 *
 *  @return 消息内容
 */
- (NSString*)getLastMessageContentForSessionID:(NSString*)sessionID;

/**
 *  获取会话最后一条消息的ID
 *
 *  @param sessionID 会话ID
 *
 *  @return 消息ID
 */
- (NSUInteger)getLastMessageIDForSessionID:(NSString*)sessionID;

/**
 *  最后一条消息数据中是否有对应sessionID的数据
 *
 *  @param sessionID 会话ID
 *
 *  @return 返回结果
 */
- (BOOL)lastestMessageIDExistInDataForSessionID:(NSString*)sessionID;

/**
 *  设置会话的最后一条消息，在获取最近联系人的时候需要设置一次，其他时间自动设置
 *
 *  @param messageContent 消息内容
 *  @param messageID      消息ID
 *  @param sessionID      会话ID
 */
- (void)setLasteMessageContent:(NSString*)messageContent messsageID:(NSUInteger)messageID forSessionID:(NSString*)sessionID;

/**
 *  清除某个SessionID对应的未读消息
 *
 *  @param sessionID sessionID
 */
- (void)clearUnreadMessagesForSessionID:(NSString*)sessionID;

/**
 *  获取所有的未读消息计数
 *
 *  @return 未读计数
 */
- (NSUInteger)getUnreadMessgeCount;

/**
 *  获取某个SessionIDE对应的未读消息计数
 *
 *  @param sessionID 会话ID
 *
 *  @return 未读消息计数
 */
- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID;

/**
 *  发送消息到服务器
 *
 *  @param message    待发送的消息
 *  @param sessionID  会话ID
 *  @param completion 消息发送完成
 */
- (MTMessageEntity*)sendMessage:(NSAttributedString*)message forSession:(NSString*)sessionID completion:(SendMessageCompletion)completion;

/**
 * 获取会话历史消息
 * @param  sessionID      会话ID
 * @param  offset         开始读取的偏移
 * @param  count          读取数量
 * @param  completion     完成回调
 * @return void
 */
- (void)getHistoryMessage:(NSString* )sessionID fromMessageID:(NSInteger)messageID count:(NSInteger)count Completion:(GetHistoryMessageCompletion)completion;

//----------------------------------------------------------------------------------------
#pragma -
#pragma mark - Draft 

/**
 *  获取指定session ID的草稿
 *
 *  @param sessionID 指定session ID
 *
 *  @return 富文本草稿
 */
- (NSAttributedString*)getDraftForSessionID:(NSString*)sessionID;

/**
 *  设置指定session ID的草稿
 *
 *  @param draft     草稿
 *  @param sessionID 指定sessionID
 */
- (void)setDraft:(NSAttributedString*)draft forSessionID:(NSString*)sessionID;

#pragma -
#pragma mark - Input History
/**
 *  添加历史发送文本
 *
 *  @param historyText 历史发送文本
 */
- (void)addInputHistory:(NSAttributedString*)historyText forSessionID:(NSString*)sessionID;

/**
 *  获取指定索引位置的历史文本
 *
 *  @param historyText 历史文本
 *  @param index       索引
 */
- (NSAttributedString*)getInputHistoryForSessionID:(NSString *)sessionID forIndex:(NSUInteger)index;

/**
 *  获取最后一个未读会话的sessionId;
 *
 *  @return sessionId
 */
-(NSString *)getLastUnreadSessionId;

@end
