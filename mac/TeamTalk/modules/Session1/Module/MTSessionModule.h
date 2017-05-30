//
//  MTSessionModule.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDRootModule.h"
#import "MTSessionEntity.h"
typedef void(^DDShieldSessionCompletion)(BOOL result);
typedef void(^DDDeleteSessionCompletion)(BOOL result);
typedef void(^MTGetSessionLastMsgIDCompletion)();

@interface MTSessionModule : DDRootModule

+ (instancetype)shareInstance;

@property (nonatomic,retain)NSString* currentChatingSessionID;

/**
 *  添加Sessions
 *
 *  @param sessions 待加入的session,如果本地没有这个session，则会自动保存在数据库
 */
- (void)addSessions:(NSArray*)sessions saveToDB:(BOOL)save;

/**
 *  删除Sessions
 *
 *  @param sessions 待删除的session
 */
- (void)removeSessions:(NSArray*)sessions;

/**
 *  对所有的Session排序
 */
- (void)sortSessions;

/**
 *  更新一个Session 的updateTime
 *
 *  @param sessionID   sessionID
 *  @param sessionTime sessionTime
 */
- (void)updateSession:(NSString*)sessionID UpdateTime:(NSUInteger)sessionTime;

/**
 *  Session Count
 *
 *  @return sessionCount
 */
- (NSInteger)sessionCount;

/**
 *  获取所有的Session IDs
 *
 *  @return 所有的Session IDs
 */
- (NSArray*)sessions;

/**
 *  根据SessionID获取Session
 *
 *  @param sessionID sessionID
 *
 *  @return Session
 */
- (MTSessionEntity*)getSessionBySessionID:(NSString*)sessionID;

/**
 *  从原始实体类加载Session到Module
 *
 *  @param entity 原始实体类
 */
- (MTSessionEntity*)addSessionFromOriginEntity:(id)entity saveToDB:(BOOL)save;

/**
 *  获取Session的索引位置
 *
 *  @param sessionID sessionID
 *
 *  @return 索引
 */
- (NSUInteger)indexForSessionID:(NSString*)sessionID;

/**
 *  移动SessionID到顶部
 *
 *  @param sessionID sessionID
 */
- (void)moveSessionIDToTop:(NSString*)sessionID;

/**
 *  取消置顶.
 */
-(void)cancelTopSession:(NSString *)sessionID;

/**
 *  屏蔽或者取消屏蔽Session
 *
 *  @param sessionID  指定的SessionID
 *  @param shield     屏蔽操作
 *  @param completion 完成屏蔽所调用的操作
 */
- (void)shieldSessionID:(NSString*)sessionID shield:(BOOL)shield completion:(DDShieldSessionCompletion)completion;

/**
 *  删除SessionID（远端删除，非本地）
 *
 *  @param originID   指定的SessionID
 *  @param completion 完成删除
 */
- (void)deleteSessionID:(NSString*)originID sessionType:(SessionType)type completion:(DDDeleteSessionCompletion)completion;

/**
 *  根据sessionID删除本地session
 */
-(void)deleteSessionForSessionID:(NSString *)sessionID;

/**
 *  SessionID 是否存在在维护列表中
 *
 *  @param sessionID sessionID
 *
 *  @return 是否存在
 */
- (BOOL)sessionIDExist:(NSString*)sessionID;

/**
 *  发送Session已读确认
 *
 *  @param sessionID sessionID
 */
- (void)sendSessionReadACK:(NSString*)sessionID;

/**
 *  清除所有的Sessions
 */
- (void)clearAllSessions;

//------------------------------------------------------------------
/**
 * 获取某种会话类型的的会话数量
 *
 *  @param sessionType 会话类型
 *
 *  @return 会话数
 */
- (NSInteger)sessionCountForSessionType:(SessionType)sessionType;

/**
 *  针对某个会话类型进行排序
 *
 *  @param sessionType 会话类型
 */
- (void)sortSessionsForSessionType:(SessionType)sessionType;

/**
 *  获取某个会话类型的会话
 *
 *  @param sessionType 会话类型
 *
 *  @return 会话
 */
- (NSArray*)sessionsForSessionType:(SessionType)sessionType;

/**
 *  清空某个会话类型的所有会话
 *
 *  @param sessionType 会话类型
 */
- (void)clearAllSessionsForSessionType:(SessionType)sessionType;


-(NSArray *)getTopSessionIDs;

-(NSArray *)getShieldSessionIDs;

@end
