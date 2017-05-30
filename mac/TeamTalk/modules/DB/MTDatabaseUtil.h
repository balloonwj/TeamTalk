//
//  MTDatabaseUtil.h
//  Duoduo
//
//  Created by wj on 15/1/19.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@class MTMessageEntity;

@class MTGroupEntity,MTSessionEntity,MTUserEntity;

@class MTSysConfigEntity;
@interface MTDatabaseUtil : NSObject

@property (nonatomic,readonly) dispatch_queue_t databaseQueue;

+ (id)instance;
- (void)openCurrentUserDB;

@end

@interface MTDatabaseUtil(Message)

/**
 *  去本地拉取历史消息
 *
 *  @param sessionID 会话ID
 *  @param messageID 消息ID
 *  @param msgCount  偏移量
 *
 *  @return 消息
 */
- (NSArray*)queryMessageForSessionID:(NSString*)sessionID messageID:(NSUInteger)messageID messageCount:(NSUInteger)msgCount;

/**
 *  执行查询操作，获取指定消息之后的消息
 *
 *  @param sessionID 会话ID
 *  @param message   指定的消息
 *
 *  @return 消息数据
 */
- (NSArray*)queryMessageForSessionID:(NSString*)sessionID afterMessage:(MTMessageEntity*)message;

/**
 *  在|databaseMessageQueue|执行查询操作，获取最后一条消息
 *
 *  @param sessionID  sessionID
 *  @param completion 完成获取最新的消息
 */
- (MTMessageEntity*)getLastestMessageForSessionID:(NSString*)sessionID;

/**
 *  在|databaseMessageQueue|执行查询操作，获取本地消息
 *
 *  @param messageID  messageID
 *  @param completion 完成获取最新的消息
 */
- (MTMessageEntity*)getMessageForMessageID:(NSUInteger)messageID andSessionID:(NSString*)sessionID;

/**
 *  获取指定会话的消息数
 *
 *  @param sessionID 会话ID
 *
 *  @return 消息数
 */
- (NSUInteger)getMessagesCountForSessionID:(NSString*)sessionID;

/**
 *  批量插入message，需要用户必须在线，避免插入离线时阅读的消息
 *
 *  @param messages 待插入的消息
 *
 *  @return Result
 */
- (BOOL)insertMessages:(NSArray*)messages;

/**
 *  删除相应会话的所有消息
 *
 *  @param sessionID 会话
 *
 *  @return Result
 */
- (BOOL)deleteMessagesForSession:(NSString*)sessionID;

/**
 *  删除某条消息
 *
 *  @param messageID 消息对应的ID
 *
 *  @return Result
 */
- (BOOL)deleteMessagesForMessageID:(NSUInteger)messageID;

/**
 *  更新数据库中的某条消息
 *
 *  @param message 更新后的消息
 *
 *  @return 完成更新
 */
- (BOOL)updateMessageForMessage:(MTMessageEntity*)message;

/**
 *  获取最后一条消息的数据
 *
 *  @return 最后一条消息的数据，key是sessionID，Value是消息实体
 */
- (NSDictionary*)getLastestMessage;
@end

@interface MTDatabaseUtil(Users)

/**
 *  加载本地数据库的用户列表
 *
 *  @return 用户列表
 */
- (NSArray*)queryUsers;

/**
 *  更新本地数据库的用户信息
 *
 *  @param users Result
 */
- (BOOL)updateUsers:(NSArray*)users;

/**
 *  更新本地数据库某个用户的信息
 *
 *  @param user 某个用户
 *
 *  @return Result
 */
- (BOOL)updateContact:(MTUserEntity*)user;

/**
 *  插入本地数据库的用户信息
 *
 *  @param users 用户数组
 *
 *  @return Result
 */
- (BOOL)insertUsers:(NSArray*)users;

@end

@interface MTDatabaseUtil(Group)

/**
 *  加载本地数据库的群列表
 *
 *  @return 群列表
 */
- (NSArray*)queryGroups;

/**
 *  更新本地数据库的群信息
 *
 *  @param users Result
 */
- (BOOL)updateGroups:(NSArray*)groups;

/**
 *  插入本地数据库的用户信息
 *
 *  @param users 用户数组
 *
 *  @return Result
 */
- (BOOL)insertGroups:(NSArray*)groups;

@end

@interface MTDatabaseUtil(Session)

/**
 *  加载本地数据库的最近联系人列表
 *
 *  @return 联系人列表
 */
- (NSArray*)querySessions;

/**
 *  更新本地数据库的最近联系人信息
 *
 *  @param users Result
 */
- (BOOL)updateSessions:(NSArray*)sessions;

/**
 *  插入本地数据库的最近联系人信息
 *
 *  @param users 最近联系人数组
 *
 *  @return Result
 */
- (BOOL)insertSessions:(NSArray*)sessions;

/**
 *  删除本地会话
 *
 *  @param sessionID 会话ID
 *
 *  @return TRUE|FALSE
 */
- (BOOL)deleteSession:(NSString*)sessionID;
@end

@interface MTDatabaseUtil(SysConfig)

/**
 *  插入本地数据库的最近联系人信息
 *
 *  @param users 最近联系人数组
 *
 *  @return Result
 */
- (NSArray*)querySysConfig;

/**
 *  更新本地配置信息
 *
 *  @param sysConfig 配置实体
 *
 *  @return TRUE|FALSE
 */
- (BOOL)updateSysConfig:(MTSysConfigEntity *)sysConfig;

/**
 *  插入本地配置信息
 *
 *  @param SysConfig 配置实体
 *
 *  @return TRUE|FALSE
 */
- (BOOL)insertSysConfig:(MTSysConfigEntity *)SysConfig;
@end

@interface MTDatabaseUtil(Department)


- (NSArray*)queryDepartments;

- (BOOL)updateDepartments:(NSArray*)departments;

@end
