//
//  MTLastMessageManager.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MTLastMessageManager : NSObject

/**
 *  加载初始化最后一条消息的数据
 */
- (void)initialLastMessageData;

/**
 *  设置会话的最后一条消息
 *
 *  @param messageContent 消息内容
 *  @param messageID      消息ID
 *  @param sessionID      会话ID
 */
- (void)setLastMessage:(NSString*)messageContent messageID:(NSUInteger)messageID forSessionID:(NSString*)sessionID;

/**
 *  获取会话的最后一条消息的内容
 *
 *  @param sessionID 会话ID
 *
 *  @return 消息内容
 */
- (NSString*)lastMessageContentForSessionID:(NSString*)sessionID;

/**
 *  获取会话的最后一条消息的ID
 *
 *  @param sessionID 会话ID
 *
 *  @return 消息ID
 */
- (NSUInteger)lastMessageIDForSessionID:(NSString*)sessionID;

/**
 *  sessionID 是否存在
 *
 *  @param sessionID 会话ID
 *
 *  @return 是否存在
 */
- (BOOL)sessionExistForSessionID:(NSString*)sessionID;

@end
