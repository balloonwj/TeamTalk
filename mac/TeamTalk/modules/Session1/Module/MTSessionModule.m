//
//  MTSessionModule.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTSessionModule.h"
#import "DDRecentConactsAPI.h"
#import "DDRecentContactsViewController.h"
#import "MTGroupModule.h"
#import "MTUserModule.h"
#import "MTDatabaseUtil.h"
#import "DDSetting.h"
#import "DDRemoveSessionAPI.h"
#import "MTMessageModule.h"
#import "DDSetting.h"
#import "DDMsgReadACKAPI.h"
@interface MTSessionModule(PrivateAPI)

- (void)p_loadLocalSessionData;
- (void)p_loadRemoteSessionData;
- (void)p_refreshLocalData:(NSArray*)sessions;
@end

@implementation MTSessionModule{
    NSMutableDictionary* _recentSessions;
    NSMutableArray *_recentlySessionIds;
}

+ (instancetype)shareInstance
{
    static MTSessionModule* g_sessionModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sessionModule = [[MTSessionModule alloc] init];
    });
    return g_sessionModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self registObserveClientState];
        [self registObserveDataReadyState];
        _recentSessions = [[NSMutableDictionary alloc] init];
        _recentlySessionIds = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
 
    if([keyPath isEqualToString:DD_DATA_STATE_KEYPATH]){
        DDDataState oldDataState = [change[@"old"] integerValue];
        DDDataState newDataState = [change[@"new"] integerValue];
        if ((!(oldDataState & DDLocalUserDataReady) || !(oldDataState & DDLocalGroupDataReady)) &&
            (newDataState & DDLocalUserDataReady) && (newDataState & DDLocalGroupDataReady))
        {
            //本地用户数据和群数据加载完成，加载本地session对话
            [self p_loadLocalSessionData];
        }
        else if ((!(oldDataState & DDRemoteUserDataReady)) && (newDataState & DDRemoteUserDataReady))
        {
            //加载后端session数据
            [self p_loadRemoteSessionData];
        }
    }
}

-(NSUInteger )getMaxTime
{
    NSArray *array =[_recentSessions allValues];
    NSUInteger maxTime = [[array valueForKeyPath:@"@max.timeInterval"] integerValue];
    if (maxTime) {
        return maxTime;
    }
    return 0;
}

#pragma mark - 

/**
 *  添加Sessions
 *
 *  @param sessions 待加入的session
 */
- (void)addSessions:(NSArray*)sessions saveToDB:(BOOL)save{
    for(MTSessionEntity *session in sessions){
        [_recentSessions setObject:session forKey:session.sessionID];
        if (![_recentlySessionIds containsObject:session.sessionID]) {
            [_recentlySessionIds addObject:session.sessionID];
        }
    }
    if (save)
    {
        [[MTDatabaseUtil instance] insertSessions:sessions];
    }
}


/**
 *  删除Sessions
 *
 *  @param sessions 待删除的session
 */
- (void)removeSessions:(NSArray*)sessions{
    for(MTSessionEntity *session in sessions){
        [_recentSessions removeObjectForKey:session.sessionID];
        [_recentlySessionIds removeObject:session.sessionID];
    }
}

/**
 *  对所有的Session排序
 */
- (void)sortSessions{
    
    
    @autoreleasepool {
        NSArray* topSessions = [[DDSetting instance] getTopSessionIDs];
        NSMutableArray* recentlySessionIds = [[NSMutableArray alloc] initWithArray:topSessions];
        if (!recentlySessionIds)        //包含topSession.
        {
            recentlySessionIds = [[NSMutableArray alloc] init];
        }
        [_recentlySessionIds removeObjectsInArray:recentlySessionIds];
        if([_recentlySessionIds count] > 1)
        {
            [_recentlySessionIds sortUsingComparator:
             ^NSComparisonResult(NSString* sId1, NSString* sId2)
             {
                 MTSessionEntity* session1 = [self getSessionBySessionID:sId1];
                 MTSessionEntity* session2 = [self getSessionBySessionID:sId2];
                 if(session1.timeInterval > session2.timeInterval)
                     return NSOrderedAscending;
                 else if(session1.timeInterval < session2.timeInterval)
                     return NSOrderedDescending;
                 else
                     return NSOrderedSame;
             }];
        }
        [recentlySessionIds addObjectsFromArray:_recentlySessionIds];
        _recentlySessionIds = recentlySessionIds;
    }
}

/**
 *  更新一个Session 的updateTime
 *
 *  @param sessionID   sessionID
 *  @param sessionTime sessionTime
 */
- (void)updateSession:(NSString*)sessionID UpdateTime:(NSUInteger)sessionTime{
    MTSessionEntity *sessionEntity = [_recentSessions objectForKey:sessionID];
    if(sessionEntity){
        [sessionEntity updateUpdateTime:sessionTime];
    }
}

/**
 *  Session Count
 *
 *  @return sessionCount
 */
- (NSInteger)sessionCount{
    return _recentSessions.count;
}

/**
 *  获取所有的Session IDs
 *
 *  @return 所有的Session IDs
 */
- (NSArray*)sessions{
    return [NSArray arrayWithArray:_recentlySessionIds];
}

/**
 *  根据SessionID获取Session
 *
 *  @param sessionID sessionID
 *
 *  @return Session
 */
- (MTSessionEntity*)getSessionBySessionID:(NSString*)sessionID{
    return [_recentSessions objectForKey:sessionID];
}

/**
 *  从原始实体类加载Session到Module
 *
 *  @param entity 原始实体类
 */
- (MTSessionEntity*)addSessionFromOriginEntity:(id)entity saveToDB:(BOOL)save{

    if ([entity isKindOfClass:[MTUserEntity class]])
    {
        MTUserEntity* user = (MTUserEntity*)entity;
        MTSessionEntity* session = [[MTSessionEntity alloc] initWithOriginID:user.ID type:SessionTypeSessionTypeSingle];
        [self addSessions:@[session] saveToDB:save];
        return session;
    }
    else if ([entity isKindOfClass:[MTGroupEntity class]])
    {
        MTGroupEntity* group = (MTGroupEntity*)entity;
        MTSessionEntity* session = [[MTSessionEntity alloc] initWithOriginID:group.ID type:SessionTypeSessionTypeGroup];
        [self addSessions:@[session] saveToDB:save];
        return session;
    }
    return nil;
}

/**
 *  获取Session的索引位置
 *
 *  @param sessionID sessionID
 *
 *  @return 索引
 */
- (NSUInteger)indexForSessionID:(NSString*)sessionID{
    return [_recentlySessionIds indexOfObject:sessionID];
}

/**
 *  移动SessionID到顶部
 *
 *  @param sessionID sessionID
 */
- (void)moveSessionIDToTop:(NSString*)sessionID{
  [[DDSetting instance] addTopSessionID:sessionID];
}

-(void)cancelTopSession:(NSString *)sessionID{
    [[DDSetting instance] removeTopSessionID:sessionID];
}

/**
 *  屏蔽或者取消屏蔽Session
 *
 *  @param sessionID  指定的SessionID
 *  @param shield     屏蔽操作
 *  @param completion 完成屏蔽所调用的操作
 */
- (void)shieldSessionID:(NSString*)sessionID shield:(BOOL)shield completion:(DDShieldSessionCompletion)completion{
    if (shield) {
        [[DDSetting instance] addShieldSessionID:sessionID];
    }else{
        [[DDSetting instance] removeShieldSessionID:sessionID];
    }

}

/**
 *  删除SessionID（远端删除，非本地）
 *
 *  @param sessionID  指定的SessionID
 *  @param completion 完成删除
 */
- (void)deleteSessionID:(NSString*)originID sessionType:(SessionType)type completion:(DDDeleteSessionCompletion)completion{
    
    DDRemoveSessionAPI *removeSessionAPI =[DDRemoveSessionAPI new];
    NSArray *array = [NSArray arrayWithObjects:originID,@(type), nil];
    [removeSessionAPI requestWithObject:array Completion:^(id response, NSError *error) {
        if (!error) {
           // NSMutableDictionary *dic =(NSMutableDictionary *)response;
           // UInt32 resultCode= (UInt32)[[dic objectForKey:@"resultCode"] integerValue];
            __weak MTSessionModule *module = self;
            NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:type];
            [[MTDatabaseUtil instance] deleteSession:sessionID];
            [module deleteSessionForSessionID:sessionID];
            completion(YES);
            

        }else{
            completion(NO);
        }
    }];

}

-(void)deleteSessionForSessionID:(NSString *)sessionID{
    [_recentSessions removeObjectForKey:sessionID];
    [_recentlySessionIds removeObject:sessionID];
}

/**
 *  SessionID 是否存在在维护列表中
 *
 *  @param sessionID sessionID
 *
 *  @return 是否存在
 */
- (BOOL)sessionIDExist:(NSString*)sessionID{
    return [_recentlySessionIds containsObject:sessionID];
}

/**
 *  发送Session已读确认
 *
 *  @param sessionID sessionID
 */
- (void)sendSessionReadACK:(NSString*)sessionID{
    DDMsgReadACKAPI* readACK = [[DDMsgReadACKAPI alloc] init];
    MTSessionEntity *session = [self getSessionBySessionID:sessionID];
    if(session){
        NSUInteger msgId = [[MTMessageModule shareInstance] getLastMessageIDForSessionID:sessionID];
        [readACK requestWithObject:@[session.originID,@(msgId),@(session.sessionType)] Completion:nil];
    }
}

/**
 *  清除所有的Sessions
 */
- (void)clearAllSessions{
    
}

//------------------------------------------------------------------
/**
 * 获取某种会话类型的的会话数量
 *
 *  @param sessionType 会话类型
 *
 *  @return 会话数
 */
- (NSInteger)sessionCountForSessionType:(SessionType)sessionType{
    return 0;
}

/**
 *  针对某个会话类型进行排序
 *
 *  @param sessionType 会话类型
 */
- (void)sortSessionsForSessionType:(SessionType)sessionType{
    
}

/**
 *  获取某个会话类型的会话
 *
 *  @param sessionType 会话类型
 *
 *  @return 会话
 */
- (NSArray*)sessionsForSessionType:(SessionType)sessionType{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (MTSessionEntity *entity in [_recentSessions allValues ]) {
        if ([entity sessionType]==sessionType) {
            [array addObject:entity];
        }
    }
    return array;
}

/**
 *  清空某个会话类型的所有会话
 *
 *  @param sessionType 会话类型
 */
- (void)clearAllSessionsForSessionType:(SessionType)sessionType{
    for (MTSessionEntity *entity in [_recentSessions allValues ]) {
        if ([entity sessionType]==sessionType) {
           // clear... tt_3.0
        }
    }
}

-(NSArray *)getTopSessionIDs{
    return [[DDSetting instance] getTopSessionIDs];
}

-(NSArray *)getShieldSessionIDs{
    return [[DDSetting instance] getShieldSessionIDs];
}

#pragma mark -
#pragma mark - PrivateAPI
- (void)p_loadLocalSessionData
{
    NSArray *localArray = [[MTDatabaseUtil instance] querySessions];
    if(localArray && [localArray count]>0){
        [self addSessions:localArray saveToDB:NO];
        [self sortSessions];
        [localArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTSessionEntity* session = (MTSessionEntity*)obj;
            [[MTMessageModule shareInstance] setLasteMessageContent:@"🐶" messsageID:session.lastMsgID forSessionID:session.sessionID];
        }];
        [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDLocalSessionDataReady;
    }else{
        [[DDSetting instance]restoreDefaultSetting];
        [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDLocalSessionDataReady;
    }
}

- (void)p_loadRemoteSessionData
{
    
    NSInteger localMaxTime = 0;
//    localMaxTime = localMaxTime > 60 ? localMaxTime - 60 : localMaxTime;
    DDRecentConactsAPI* contactsApi = [[DDRecentConactsAPI alloc] init];
    [contactsApi requestWithObject:@[@(localMaxTime)] Completion:^(id response, NSError *error) {
        if (!error && response && [response count]>0)
        {
            NSMutableArray* tempGroups = [[NSMutableArray alloc] init];
            [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MTSessionEntity* sessionEntity = (MTSessionEntity*)obj;
                if ([sessionEntity.name isEqualToString:@"虾条"])
                {
                    DDLog(@"asdas");
                }
                if (sessionEntity.sessionType == SessionTypeSessionTypeGroup)
                {
                    [tempGroups addObject:sessionEntity.originID];
                }
                [[MTMessageModule shareInstance]setLasteMessageContent:sessionEntity.lastMsg messsageID:sessionEntity.lastMsgID forSessionID:sessionEntity.sessionID];
            }];
            
            [[MTGroupModule shareInsatnce] updateTempGroupInfoFromSessions:tempGroups];
            
            [self addSessions:response saveToDB:YES];
            //排序
            [self sortSessions];
            
            //先看本地有没有数据
            [self p_refreshLocalData:response];
            
            [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteSessionDataReady;
        }
        else
        {
            [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteSessionDataReady;
        }
    }];

}

- (void)p_refreshLocalData:(NSArray*)sessions{
    
}
@end
