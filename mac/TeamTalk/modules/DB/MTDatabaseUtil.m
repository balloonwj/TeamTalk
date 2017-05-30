//
//  MTDatabaseUtil.m
//  Duoduo
//
//  Created by wj on 15/1/19.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTDatabaseUtil.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "MTSessionEntity.h"
#import "MTGroupEntity.h"
#import "MTMessageEntity.h"
#import "MTMessageModule.h"
#import "MTSysConfigEntity.h"
#import "MTSessionModule.h"
#import "MTDepartmentEntity.h"

#define DB_FILE_NAME                    @"TeamTalk.sqlite"
#define TABLE_USER                      @"Users"
#define TABLE_GROUP                     @"Groups"
#define TABLE_MESSAGE                   @"Message"
#define TABLE_RECENT_SESSION            @"RecentSession"
#define TABLE_FILE_TRANSFER             @"FileTransferHistory"
#define TABLE_SYS_CONFIG                @"SysConfig"
#define TABLE_DEPARTMENT                @"Department"

//用户表
#define SQL_CREATE_USER         [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, userId TEXT NOT NULL UNIQUE, name TEXT DEFAULT NULL, avatar TEXT DEFAULT NULL, departmentID INTEGER DEFAULT 0, email TEXT DEFAULT NULL, gender TEXT DEFAULT NULL, realName TEXT DEFAULT NULL, domain TEXT DEFAULT NULL, telephone TEXT DEFAULT NULL, status INTEGER DEFAULT 0)",TABLE_USER]

//群表
#define SQL_CREATE_GROUP        [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, groupId TEXT NOT NULL UNIQUE, name TEXT DEFAULT NULL, announcement TEXT DEFAULT NULL, avatar TEXT DEFAULT NULL, creatorId TEXT DEFAULT NULL, groupType INTEGER DEFAULT 2, version INTEGER DEFAULT 0, lastUpdateTime INTEGER DEFAULT 0, shieldStatus INTEGER DEFAULT 0, memberlist TEXT NOT NULL)",TABLE_GROUP]

//消息表
#define SQL_CREATE_MESSAGE              [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (msgId INTEGER NOT NULL, sessionId TEXT NOT NULL, fromUserId TEXT DEFAULT NULL, targetId TEXT DEFAULT NULL, content TEXT, messageType INTEGER DEFAULT 1 NOT NULL, state INTEGER DEFAULT 1 NOT NULL, msgtime INTEGER DEFAULT 0 NOT NULL,CONSTRAINT PK PRIMARY KEY (msgId,sessionId))",TABLE_MESSAGE]

//最近会话表
#define SQL_CREATE_RECENT_SESSION      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (originID TEXT NOT NULL, sessionType INTEGER DEFAULT 0, lastMsgId INTEGER DEFAULT 0,lastUpdateTime INTEGER DEFAULT 0, lastMsgData TEXT DEFAULT NULL, CONSTRAINT PK PRIMARY KEY (originID,sessionType))",TABLE_RECENT_SESSION]

//文件发送表
#define SQL_CREATE_FILE_TRANSFER      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY, taskId TEXT NOT NULL, fromId TEXT DEFAULT NULL, filename TEXT DEFAULT NULL, savepath TEXT NOT NULL, filesize INTEGER DEFAULT 0 NOT NULL, finishtime INTEGER DEFAULT 0 NOT NULL)",TABLE_FILE_TRANSFER]

//部门表
#define SQL_CREATE_DEPARTMET          [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY, Name TEXT NOT NULL, ParentID INTEGER DEFAULT 0, Priority INTEGER, State INTEGER,Resever1 INTEGER,Resever2 TEXT)",TABLE_DEPARTMENT]

//系统配置表
#define SQL_CREATE_SYS_CONFIG         [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, value INTEGER DEFAULT 0)",TABLE_SYS_CONFIG]

//表索引
#define SQL_CREATE_USER_INDEX        [NSString stringWithFormat:@"CREATE INDEX userId_idx on %@(userId)",TABLE_USER]
#define SQL_CREATE_GROUP_INDEX        [NSString stringWithFormat:@"CREATE INDEX groupId_idx on %@(groupId)",TABLE_GROUP]
#define SQL_CREATE_MESSAGE_INDEX        [NSString stringWithFormat:@"CREATE INDEX messageId_sessionId_idx on %@(msgId DESC,sessionId)",TABLE_MESSAGE]
#define SQL_CREATE_RECENT_SESSION_INDEX        [NSString stringWithFormat:@"CREATE INDEX sessionId_idx on %@(sessionId)",TABLE_RECENT_SESSION]

@interface MTDatabaseUtil(PrivateAPI)

- (BOOL)p_db:(FMDatabase*)database createTable:(NSString *)sql;

- (BOOL)p_db:(FMDatabase*)db insertMessages:(NSArray*)messages;

- (NSUInteger)p_getLastMessageIDForSessionID:(NSString*)sessionID;

@end

@implementation MTDatabaseUtil
{
    FMDatabaseQueue* _dataBaseQueue;
}
+ (instancetype)instance
{
    static MTDatabaseUtil* g_databaseUtil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_databaseUtil = [[MTDatabaseUtil alloc] init];
    });
    return g_databaseUtil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //初始化数据库
        if ([DDClientState shareInstance].userID)
        {
            [self openCurrentUserDB];
        }
        [[DDClientState shareInstance] addObserver:self forKeyPath:DD_USER_ID_KEYPATH options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)openCurrentUserDB
{
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:[MTDatabaseUtil dbFilePath]];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:TABLE_USER]) {
            [self p_db:db createTable:SQL_CREATE_USER];
        }
        if (![db tableExists:TABLE_GROUP])
        {
            [self p_db:db createTable:SQL_CREATE_GROUP];
        }
        if (![db tableExists:TABLE_MESSAGE])
        {
            [self p_db:db createTable:SQL_CREATE_MESSAGE];
        }
        if (![db tableExists:TABLE_RECENT_SESSION])
        {
            [self p_db:db createTable:SQL_CREATE_RECENT_SESSION];
        }
        if (![db tableExists:TABLE_SYS_CONFIG])
        {
            [self p_db:db createTable:SQL_CREATE_SYS_CONFIG];
        }
        if (![db tableExists:TABLE_DEPARTMENT])
        {
            [self p_db:db createTable:SQL_CREATE_DEPARTMET];
        }
        //文件这版先不做🐱
    }];
}

+(NSString *)dbFilePath
{
    NSString* userID = [DDClientState shareInstance].userID;
    
    NSString* directorPath = [[duoduo applicationSupportDirectory] stringByAppendingPathComponent:userID];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //判断用户的db是否存在，若不存在则创建相应的DB目录
    BOOL isDirector = NO;
    BOOL isExiting = [fileManager fileExistsAtPath:directorPath isDirectory:&isDirector];
    
    if (!(isExiting && isDirector))
    {
        BOOL createDirection = [fileManager createDirectoryAtPath:directorPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        if (!createDirection)
        {
            DDLog(@"创建%@’DB目录失败",userID);
        }
    }
    
    
    NSString *dbPath = [directorPath stringByAppendingPathComponent:DB_FILE_NAME];
    return dbPath;
}

#pragma mark PrivateAPI

- (BOOL)p_db:(FMDatabase*)db insertMessages:(NSArray*)messages
{
//    [db beginTransaction];
    __block BOOL isRollBack = NO;
//    @try {
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTMessageEntity* message = (MTMessageEntity*)obj;
            
            //msgId INTEGER NOT NULL, sessionId TEXT NOT NULL, fromUserId TEXT DEFAULT NULL, targetId TEXT DEFAULT NULL, content TEXT NOT NULL, messageType INTEGER DEFAULT 1 NOT NULL, state INTEGER DEFAULT 1 NOT NULL, msgtime INTEGER DEFAULT 0 NOT NULL,CONSTRAINT PK PRIMARY KEY (msgId,sessionId)
            
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (msgId, sessionId, fromUserId, targetId, content, messageType,state, msgtime) VALUES(?,?,?,?,?,?,?,?)",TABLE_MESSAGE];
            NSString* messageContent = [message getTextMessageContent];
            messageContent = messageContent ? messageContent : @" ";
            BOOL result = [db executeUpdate:sql,@(message.messageServerID), message.sessionID, message.senderID, message.targetID ,messageContent, @(message.messageType), @(message.sendState),@(message.messageTime)];
            if (!result)
            {
                isRollBack = YES;
                *stop = YES;
            }
        }];
    return !isRollBack;
//    }
//    @catch (NSException *exception) {
//        DDLog(@"%@",exception);
//    }
//    @finally {
//        if (isRollBack)
//        {
//            [db rollback];
//            return NO;
//        }
//        else
//        {
//            [db commit];
//            return YES;
//        }
//    }
}

-(BOOL)p_db:(FMDatabase*)database createTable:(NSString *)sql          //创建表
{
    [database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"%@",sql];
    return [database executeUpdate:tempSql];
}

- (NSUInteger)p_getLastMessageIDForSessionID:(NSString*)sessionID
{
    __block NSUInteger lastMessageID = 0;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sqlString = [NSString stringWithFormat:@"SELECT MAX(msgId) FROM %@ where sessionId=?",TABLE_MESSAGE];
        FMResultSet* result = [db executeQuery:sqlString,sessionID];
        while ([result next])
        {
            lastMessageID = [result intForColumnIndex:0];
        }
    }];
    return lastMessageID;
}

#pragma mark Message

- (MTMessageEntity*)messageFromResult:(FMResultSet*)resultSet
{
    NSInteger messageID = [resultSet intForColumn:@"msgId"];
    NSString* sessionID = [resultSet stringForColumn:@"sessionId"];
    uint8 messageType = [resultSet intForColumn:@"messageType"];
    NSString* fromUserId = [resultSet stringForColumn:@"fromUserId"];
    NSString* targetID = [resultSet stringForColumn:@"targetId"];
    NSString* content = [resultSet stringForColumn:@"content"];
    uint32 msgTime = [resultSet intForColumn:@"msgTime"];
    MTMessageSendState state = [resultSet intForColumn:@"state"];
    
    MTMessageEntity* messageEntity = [[MTMessageEntity alloc] initWithServerMessageID:messageID type:messageType messageTime:msgTime sessionID:sessionID senderID:fromUserId targetID:targetID content:content state:state];
    
    return messageEntity;    
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_ID_KEYPATH])
    {
        NSString* newValue = change[NSKeyValueChangeNewKey];
        NSString* oldValue = change[NSKeyValueChangeOldKey];
        if (![newValue isEqualToString:oldValue])
        {
            [self openCurrentUserDB];
        }
    }
}

#pragma mark Message

- (NSArray*)queryMessageForSessionID:(NSString*)sessionID messageID:(NSUInteger)messageID messageCount:(NSUInteger)msgCount
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where sessionId=? and msgId <= ? ORDER BY msgId DESC limit ?",TABLE_MESSAGE];
        FMResultSet* result = [db executeQuery:sqlString,sessionID,@(messageID),@(msgCount)];
        while ([result next])
        {
            MTMessageEntity* message = [self messageFromResult:result];
            [array addObject:message];
        }
    }];
    return array;
}

- (NSArray*)queryMessageForSessionID:(NSString*)sessionID afterMessage:(MTMessageEntity*)message
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        NSString* sqlString = [NSString stringWithFormat:@"select * from %@ where sessionId = ? AND msgId >= ? order by msgId DESC",TABLE_MESSAGE];
        NSInteger msgID = 1;
        FMResultSet* result = [db executeQuery:sqlString,sessionID,@(msgID)];
        while ([result next])
        {
            MTMessageEntity* message = [self messageFromResult:result];
            [array addObject:message];
        }
    }];
    return array;
}

- (MTMessageEntity*)getLastestMessageForSessionID:(NSString*)sessionID
{
    __block MTMessageEntity* message = nil;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where sessionId=? ORDER BY msgId DESC limit 1",TABLE_MESSAGE];
        
        FMResultSet* result = [db executeQuery:sqlString,sessionID];
        while ([result next])
        {
            message = [self messageFromResult:result];
            break;
        }
    }];
    return message;
}

- (MTMessageEntity*)getMessageForMessageID:(NSUInteger)messageID andSessionID:(NSString*)sessionID
{
    __block MTMessageEntity* message = nil;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where msgId=? and sessionID=? ORDER BY msgId DESC limit 1",TABLE_MESSAGE];
        
        FMResultSet* result = [db executeQuery:sqlString,@(messageID),sessionID];
        while ([result next])
        {
            message = [self messageFromResult:result];
            break;
        }
        [result close];
    }];
    return message;
}

- (NSUInteger)getMessagesCountForSessionID:(NSString*)sessionID
{
    int count = 0;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        NSString* sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ where sessionId=?",TABLE_MESSAGE];
        
        FMResultSet* result = [db executeQuery:sqlString,sessionID];
        int count = 0;
        while ([result next]) {
            count = [result intForColumnIndex:0];
        }
    }];
    return count;
}

- (BOOL)insertMessages:(NSArray*)messages
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        result = [self p_db:db insertMessages:messages];
    }];
    return result;
}

- (BOOL)deleteMessagesForSession:(NSString*)sessionID
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE sessionId = ?", TABLE_MESSAGE];
        result = [db executeUpdate:sql,sessionID];
    }];
    return result;
}

- (BOOL)deleteMessagesForMessageID:(NSUInteger)messageID
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE messageID = ?",TABLE_MESSAGE];
        result = [db executeUpdate:sql,@(messageID)];
    }];
    return result;
}

- (BOOL)updateMessageForMessage:(MTMessageEntity*)message
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"UPDATE %@ set sessionId = ? , fromUserId = ? , targetId = ?,  content = ? ,  msgTime = ? , messageType = ? ,state = ? where msgId = ?",TABLE_MESSAGE];
        NSString* messageContent = [message getTextMessageContent];
        result = [db executeUpdate:sql, message.sessionID, message.senderID, message.targetID, messageContent, @(message.messageTime),@(message.messageType),@(message.sendState),@(message.messageID)];
    }];
    return result;
}

- (NSDictionary*)getLastestMessage
{
    __block NSMutableDictionary* lastMessages = [[NSMutableDictionary alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where msgId IN(SELECT max(msgId) FROM %@ GROUP BY sessionId)",TABLE_MESSAGE,TABLE_MESSAGE];
        
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTMessageEntity* message = [self messageFromResult:result];
            NSString* sessionID = message.sessionID;
            [lastMessages setObject:message forKey:sessionID];
        }
    }];
    return lastMessages;
}

#pragma mark - Users
- (MTUserEntity*)userFromResult:(FMResultSet*)resultSet
{
    NSString* userID = [resultSet stringForColumn:@"userId"];
    if (!userID)
    {
        return nil;
    }
    NSString* name = [resultSet stringForColumn:@"name"];
    NSString* avatar = [resultSet stringForColumn:@"avatar"];
    NSInteger departmentID = [resultSet intForColumn:@"departmentID"];
    NSString* email = [resultSet stringForColumn:@"email"];
    NSInteger gender = [resultSet intForColumn:@"gender"];
    NSString* realName = [resultSet stringForColumn:@"realName"];
    NSString* userDomain = [resultSet stringForColumn:@"domain"];
    NSString* telephone = [resultSet stringForColumn:@"telephone"];
    NSInteger status = [resultSet intForColumn:@"status"];
    MTUserEntity* user = [[MTUserEntity alloc] initWithID:userID name:name avatar:avatar gender:gender department:departmentID email:email realName:realName userDomain:userDomain tel:telephone status:status];
    return user;
}

- (NSArray*)queryUsers
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        //加个1w限制，如果超了，那么🐱
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ limit 10000",TABLE_USER];
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTUserEntity* user = [self userFromResult:result];
            if (user)
            {
                [array addObject:user];
            }
        }
    }];
    return array;
}

- (BOOL)updateUsers:(NSArray*)users
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"update %@ set name = ? , avtar = ? , departmentID = ? , email = ? , gender = ? , realName = ?, domain = ? , telephone = ? , status = ? where userId = ?",TABLE_USER];
        result = [db executeUpdate:sql];
        [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTUserEntity* user = (MTUserEntity*)obj;
            BOOL result = [db executeUpdate:sql,user.name,user.avatar,@(user.department),user.email,@(user.gender),user.realName, user.userDomain, user.tel, @(user.status), user.ID];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}

- (BOOL)updateContact:(MTUserEntity*)user
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"update %@ set name = ? , avtar = ? , departmentID = ? , email = ? , gender = ? , realName = ?, domain = ? , telephone = ? , status = ? where userId = ?",TABLE_USER];
        result = [db executeUpdate:sql,user.name,user.avatar,@(user.department),user.email,@(user.gender),user.realName, user.userDomain, user.tel,@(user.status), user.ID];
    }];
    return result;
}

- (BOOL)insertUsers:(NSArray*)users
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTUserEntity* user = (MTUserEntity*)obj;
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (userId, name, avatar, departmentID, email, gender, realName, domain, telephone, status) VALUES(?,?,?,?,?,?,?,?,?,?)",TABLE_USER];
            BOOL result = [db executeUpdate:sql, user.ID, user.name,user.avatar,@(user.department),user.email,@(user.gender),user.realName, user.userDomain, user.tel, @(user.status)];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}


#pragma mark - Groups
- (MTGroupEntity*)groupFromResult:(FMResultSet*)resultSet
{
    NSString* groupID = [resultSet stringForColumn:@"groupId"];
    if (!groupID)
    {
        return nil;
    }
    NSString* name = [resultSet stringForColumn:@"name"];
    NSString* avatar = [resultSet stringForColumn:@"avatar"];
    //    NSString* announcement = [resultSet stringForColumn:@"announcement"];
    NSString* creatorId = [resultSet stringForColumn:@"creatorId"];
    NSInteger groupType = [resultSet intForColumn:@"groupType"];
    NSInteger version = [resultSet intForColumn:@"version"];
    //    NSInteger lastUpdateTime = [resultSet intForColumn:@"lastUpdateTime"];
    NSString* memberlist = [resultSet stringForColumn:@"memberlist"];
    NSInteger shieldStatus = [resultSet intForColumn:@"shieldStatus"];
    BOOL isShieldStatus = (shieldStatus != 0);
    NSArray* userIDs = nil;
    if (memberlist)
    {
        userIDs = [memberlist componentsSeparatedByString:@","];
    }
    NSMutableArray* userIds = [[NSMutableArray alloc] initWithArray:userIDs];
    MTGroupEntity* group = [[MTGroupEntity alloc] initWithGroupID:groupID groupType:groupType name:name avatar:avatar creatorId:creatorId shieldStatus:isShieldStatus groupUserIds:userIds version:version];
    return group;
}

/**
 *  加载本地数据库的群信息
 *
 *  @return 群信息列表
 */
- (NSArray*)queryGroups
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        //加个1w限制，如果超了，那么🐱
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ limit 10000",TABLE_GROUP];
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTGroupEntity* group = [self groupFromResult:result];
            if (group)
            {
                [array addObject:group];
            }
        }
    }];
    return array;
}

/**
 *  更新本地数据库的群信息
 *
 *  @param groups
 */
- (BOOL)updateGroups:(NSArray*)groups
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"update %@ set name=?, announcement=?, avatar=?, creatorId=?, groupType=?, version=?, shieldStatus=?, memberlist=? where groupId=? ",TABLE_GROUP];
        [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTGroupEntity* group = (MTGroupEntity*)obj;
            NSString* userIds = [group getMemberList];
            int shieldStatus = [[NSNumber numberWithBool:group.isShield] intValue];
            BOOL result = [db executeUpdate:sql, group.name, @"", group.avatar, group.groupCreatorId, group.groupType, group.groupVersion, shieldStatus, userIds, group.ID];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}

- (BOOL)insertGroups:(NSArray *)groups
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTGroupEntity* group = (MTGroupEntity*)obj;
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (groupId, name, announcement, avatar, creatorId, groupType, version, shieldStatus, memberlist) VALUES(?,?,?,?,?,?,?,?,?)",TABLE_GROUP];
            NSString* userIds = [group getMemberList];
            int shieldStatus = [[NSNumber numberWithBool:group.isShield] intValue];
            BOOL result = [db executeUpdate:sql, group.ID, group.name, @"", group.avatar, group.groupCreatorId, @(group.groupType), @(group.groupVersion), @(shieldStatus), userIds];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}
//sessionId TEXT NOT NULL UNIQUE, sessionType INTEGER DEFAULT 0, updatedTime INTEGER DEFAULT 0, lastMsgId INTEGER DEFAULT 0, lastMsgData TEXT DEFAULT NULL
#pragma mark - Sessions
- (MTSessionEntity*)sessionFromResult:(FMResultSet*)resultSet
{
    NSString* originID = [resultSet stringForColumn:@"originID"];
    
    
    if (!originID)
    {
        return nil;
    }
    uint32 sessionType = [resultSet intForColumn:@"sessionType"];
    NSUInteger updateTime =[resultSet intForColumn:@"lastUpdateTime"];
    MTSessionEntity* recentSession = [[MTSessionEntity alloc] initWithOriginID:originID type:sessionType];
    recentSession.timeInterval = updateTime;
    recentSession.lastMsgID = [resultSet intForColumn:@"lastMsgId"];
    recentSession.lastMsg = [resultSet stringForColumn:@"lastMsgData"];
    return recentSession;
}

/**
 *  加载本地数据库的群信息
 *
 *  @return 群信息列表
 */
- (NSArray*)querySessions
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        //originID TEXT NOT NULL, sessionType INTEGER DEFAULT 0, lastMsgId INTEGER DEFAULT 0,lastUpdateTime INTEGER DEFAULT 0, lastMsgData TEXT DEFAULT NULL
        
        //加个1w限制，如果超了，那么🐱
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ limit 10000",TABLE_RECENT_SESSION];
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTSessionEntity* recentSession = [self sessionFromResult:result];
            if (recentSession)
            {
                [array addObject:recentSession];
            }
        }
        [result close];
    }];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTSessionEntity* session = (MTSessionEntity*)obj;
        if (session.lastMsgID == 0)
        {
            NSUInteger localLastMsgID = [self p_getLastMessageIDForSessionID:session.sessionID];
            session.lastMsgID = localLastMsgID;
        }
    }];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTSessionEntity* session = (MTSessionEntity*)obj;
        MTMessageEntity* message = [self getMessageForMessageID:session.lastMsgID andSessionID:session.sessionID];
        if (message)
        {
            session.timeInterval = message.messageTime;
            if (session.lastMsgID < message.messageServerID)
            {
                session.lastMsgID = message.messageServerID;
            }
        }
    }];
    return array;
}

/**
 *  更新本地数据库的群信息
 *
 *  @param groups
 */
- (BOOL)updateSessions:(NSArray*)sessions
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"update %@ set lastUpdateTime=?, lastMsgId=? where originID=? AND sessionType = ?",TABLE_RECENT_SESSION];
        [sessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTSessionEntity* session = (MTSessionEntity*)obj;
            NSInteger msgID = [[MTMessageModule shareInstance] getLastMessageIDForSessionID:session.sessionID];
            BOOL result = [db executeUpdate:sql, @(session.timeInterval),@(msgID),session.originID, @(session.sessionType)];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}

- (BOOL)insertSessions:(NSArray *)sessions
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [sessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTSessionEntity* session = (MTSessionEntity*)obj;
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (originID, sessionType, lastMsgId,lastUpdateTime,lastMsgData) VALUES(?,?,?,?,?)",TABLE_RECENT_SESSION];
            
            NSInteger lastMsgId = [[MTMessageModule shareInstance] getLastMessageIDForSessionID:session.sessionID];
            if (lastMsgId == 0)
            {
                DDLog(@"asdasdf");
            }
            BOOL result = [db executeUpdate:sql, session.originID, @(session.sessionType), @(lastMsgId), @([session timeInterval]),session.lastMsg];
            if (!result)
            {
                *stop = YES;
            }
        }];
    }];
    return result;
}

- (BOOL)deleteSession:(NSString*)sessionID
{
    __block BOOL result = NO;
    MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE originID = ? AND sessionType = ?", TABLE_RECENT_SESSION];
        result = [db executeUpdate:sql,sessionEntity.originID,@(sessionEntity.sessionType)];
    }];
    return result;
}

#pragma mark SysConfig

- (MTSysConfigEntity*)sysConfigFromResult:(FMResultSet*)resultSet
{
    MTSysConfigEntity* sysConfigEntity = [[MTSysConfigEntity alloc] init];
    NSString* sysConfigName = [resultSet stringForColumn:@"name"];
    sysConfigEntity.sysConfigName = sysConfigName;
    NSInteger sysConfigValue = [resultSet intForColumn:@"value"];
    sysConfigEntity.sysConfigValue = sysConfigValue;
    return sysConfigEntity;
}

- (NSArray*)querySysConfig
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ limit 10000",TABLE_SYS_CONFIG];
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTSysConfigEntity* sysConfig = [self sysConfigFromResult:result];
            if (sysConfig)
            {
                [array addObject:sysConfig];
            }
        }
    }];
    return array;
}

- (BOOL)updateSysConfig:(MTSysConfigEntity *)sysConfig
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"update %@ set value =? where name =? ",TABLE_SYS_CONFIG];
        result = [db executeUpdate:sql, @(sysConfig.sysConfigValue), sysConfig.sysConfigName];
    }];
    return result;
}

- (BOOL)insertSysConfig:(MTSysConfigEntity *)SysConfig
{
    __block BOOL result = NO;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (name, value) VALUES(?,?)",TABLE_SYS_CONFIG];
        result = [db executeUpdate:sql, SysConfig.sysConfigName, @(SysConfig.sysConfigValue)];
    }];
    return result;
}

#pragma mark -
#pragma mark Department
- (MTDepartmentEntity*)departmentEntityFromResult:(FMResultSet*)result
{
    //ID INTEGER PRIMARY KEY, Name TEXT NOT NULL, ParentID INTEGER DEFAULT 0, Priority INTEGER, State INTEGER,Resever1 INTEGER,Resever2 TEXT
    NSInteger ID = [result intForColumn:@"ID"];
    NSString* name = [result stringForColumn:@"Name"];
    NSInteger parentID = [result intForColumn:@"ParentID"];
    NSInteger priority = [result intForColumn:@"Priority"];
    DepartmentStatusType state = [result intForColumn:@"State"];
    
    MTDepartmentEntity* department = [[MTDepartmentEntity alloc] initWithID:ID name:name parentID:parentID priority:priority state:state];
    return department;
}

- (NSArray*)queryDepartments
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_DEPARTMENT];
        FMResultSet* result = [db executeQuery:sqlString];
        while ([result next])
        {
            MTDepartmentEntity* department = [self departmentEntityFromResult:result];
            if (department)
            {
                [array addObject:department];
            }
        }
    }];
    return array;
}

- (BOOL)updateDepartments:(NSArray *)departments
{
    //ID INTEGER PRIMARY KEY, Name TEXT NOT NULL, ParentID INTEGER DEFAULT 0, Priority INTEGER, State INTEGER,Resever1 INTEGER,Resever2 TEXT
    __block BOOL success = YES;
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [departments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTDepartmentEntity* departmentEntity = (MTDepartmentEntity*)obj;
            NSString* sqlString = [NSString stringWithFormat:@"REPLACE INTO %@ (ID,Name,ParentID,Priority,State,Reserver1,Reserver2) VALUES(?,?,?,?,?,?,?)",TABLE_DEPARTMENT];
            BOOL result = [db executeUpdate:sqlString,@(departmentEntity.ID),departmentEntity.name,@(departmentEntity.parentID),@(departmentEntity.priority),@(departmentEntity.state),@(0),@""];
            if (!result)
            {
                success = NO;
                NSLog(@"更新部门失败");
                log4Error(@"更新部门失败");
            }
        }];
    }];
    return success;
}
@end
