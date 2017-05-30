//
//  DDDatabaseUtil.h
//  Duoduo
//
//  Created by zuoye on 14-3-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void(^LoadFileMessageCompletion)(NSArray* files);
typedef void(^InsertFileMessageCompletion)(NSError* error);
typedef void(^LoadAllSessionCompletion)(NSArray* sessions,NSError* error);
typedef void(^LoadMessageInSessionCompletion)(NSArray* messages,NSError* error);
typedef void(^MessageCountCompletion)(NSInteger count);
typedef void(^SearchMessageContent)(NSArray* result);
typedef void(^DeleteSessionCompletion)(BOOL success);
typedef void(^SaveAllSessionCompletion)(BOOL success);
typedef void(^DBLoadRecentContactsCompletion)(NSArray* recentContacts,NSError* error);
@class MessageEntity;

@interface DDDatabaseUtil : NSObject

//在数据库上的操作
@property (nonatomic,readonly)dispatch_queue_t databaseMessageQueue;


+ (instancetype)instance;

@end

@interface DDDatabaseUtil(Quary)

/**
 *  在|databaseMessageQueue|执行查询操作
 *
 *  @param sessionId 会话ID
 *  @param msgOffset message偏移量，在界面上已经显示的消息数量
 *  @param msgCount  获取的消息数量
 *  @param success   获取成功之后调用的block
 *  @param failure   获取失败之后调用的block
 */
- (void)loadMessageBySessionId:(NSString*)sessionId
                     msgOffset:(uint32_t)msgOffset
                      msgCount:(uint32_t)msgCount
                       success:(void(^)(NSArray* messages))success
                       failure:(void(^)(NSString* errorDescripe))failure;


// 获取sessionId对应的数据
- (NSArray *)getUserInfoBySessionId:(NSString*)sessionId;

/**
 *  在|databaseMessageQueue|执行查询操作
 *  获取文件历史
 *
 *  @param completion 完成获取文件历史
 */
- (void)loadFileMessageCompletion:(LoadFileMessageCompletion)completion;


/**
 *  在|databaseMessageQueue|执行查询操作，获取所有的有历史记录的会话
 *
 *  @param completion 完成获取所有会话
 */
- (void)loadAllSessionCompletion:(LoadAllSessionCompletion)completion;


/**
 *  在|databaseMessageQueue|执行查询操作，分页获取聊天记录
 *
 *  @param sessionID  会话ID
 *  @param pagecount  每页消息数
 *  @param page       页数
 *  @param completion 完成获取
 */
- (void)loadMessageForSessionID:(NSString*)sessionID pageCount:(int)pagecount page:(NSInteger)page completion:(LoadMessageInSessionCompletion)completion;


/**
 *  在|databaseMessageQueue|执行查询操作，分页获取聊天记录
 *
 *  @param sessionID  会话ID
 *  @param completion 完成block
 */
- (void)getMessagesCountForSessionID:(NSString*)sessionID completion:(MessageCountCompletion)completion;

/**
 *  在|databaseMessageQueue|执行查询操作，获取包含搜索内容的sesssionID
 *
 *  @param searchContent 搜索内容
 *  @param completion    完成搜索
 */
- (void)searchMessageContent:(NSString*)searchContent completion:(SearchMessageContent)completion;
@end

@interface DDDatabaseUtil(Insert)

/**
 *  单条插入message,需要用户必须在线，避免插入离线时阅读的消息
 *
 *  @param message 消息
 *  @param success 插入成功
 *  @param failure 插入失败
 */
- (void)insertMessage:(MessageEntity*)message
              success:(void(^)())success
              failure:(void(^)(NSString* errorDescripe))failure;


/**
 *  批量插入message，需要用户必须在线，避免插入离线时阅读的消息
 *
 *  @param messages message集合
 *  @param success 插入成功
 *  @param failure 插入失败
 */
- (void)insertMessages:(NSArray*)messages
               success:(void(^)())success
               failure:(void(^)(NSString* errorDescripe))failure;

/**
 *  批量插入文件消息，在文件传输成功之后进行插入
 *
 *  @param fileObjects 待插入的文件
 *  @param completion  插入完成之后的操作
 */
- (void)insertFileMessages:(NSArray*)fileObjects
                completion:(InsertFileMessageCompletion)completion;

@end

@interface DDDatabaseUtil(Delete)

/**
 *  删除相应会话的所有消息
 *
 *  @param sessionID  会话
 *  @param completion 完成删除
 */
- (void)deleteMesagesForSession:(NSString*)sessionID completion:(DeleteSessionCompletion)completion;

@end

@interface DDDatabaseUtil(RecentSession)

- (void)updateRecentUsers:(NSArray*)objsects completion:(SaveAllSessionCompletion)completion;

- (void)loadRecentUsersCompletion:(DBLoadRecentContactsCompletion)completion;

@end