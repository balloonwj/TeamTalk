//  DDDatabaseUtil.m
//  Duoduo
//
//  Created by zuoye on 14-3-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDDatabaseUtil.h"
#import "MessageEntity.h"
#import "FileObject.h"
#import "MTUserModule.h"
#import "MTUserEntity.h"
#import "DDClientState.h"
#import "MTGroupEntity.h"
#define DB_FILE_NAME                    @"IMSession.db"
#define TABLE_MESSAGE                   @"message"
#define TABLE_FILEMESSAGE               @"fileMessage"
#define TABLE_RECENT_CONTACTS           @"recentContacts"
#define TABLE_RECENT_CONTACTS_VIEW      @"recentContactsView"

#define SQL_CREATE_MESSAGE              [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (sessionId text,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer)",TABLE_MESSAGE]
#define SQL_CREATE_MESSAGE_INDEX        [NSString stringWithFormat:@"CREATE INDEX sessionId on %@(sessionId)",TABLE_MESSAGE]

#define SQL_CREATE_FILEMESSAGE          [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fileName text PRIMARY KEY NOT NULL ,fromUserId text NOT NULL,toUserId text NOT NULL,fileSize integer, fileState integer, fileTime real NOT NULL, obligate1 text, obligate2 integer)",TABLE_FILEMESSAGE]

#define SQL_CREATE_RECENT_CONTACTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text PRIMARY KEY NOT NULL ,name text NOT NULL,updateTime real,type integer,content text,obligate1 text, obligate2 integer)",TABLE_RECENT_CONTACTS]

#define SQL_CREATE_RECENT_CONTACTS_VIEW [NSString stringWithFormat:@"CREATE VIEW %@ AS SELECT max(a.msgTime) updateTime, b.ID, b.name,b.content, b.type From %@ b left join %@ a on a.sessionId = b.ID group by b.ID",TABLE_RECENT_CONTACTS_VIEW,TABLE_RECENT_CONTACTS,TABLE_MESSAGE]
@implementation DDDatabaseUtil
{
    FMDatabase* _database;
}
+ (instancetype)instance
{
    static DDDatabaseUtil* g_databaseUtil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_databaseUtil = [[DDDatabaseUtil alloc] init];
    });
    return g_databaseUtil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //初始化数据库
        _database = [FMDatabase databaseWithPath:[DDDatabaseUtil dbFilePath]];
        if (![_database open])
        {
            DDLog(@"打开数据库失败");
            log4Error(@"打开数据库失败");
        }
        else
        {
            _databaseMessageQueue = dispatch_queue_create("com.mogujie.Duoduo.Database", NULL);
            //创建
            if (![_database tableExists:TABLE_MESSAGE])
            {
                [self createTable:SQL_CREATE_MESSAGE];
            }
            if (![_database tableExists:TABLE_FILEMESSAGE])
            {
                [self createTable:SQL_CREATE_FILEMESSAGE];
            }
            if (![_database tableExists:TABLE_RECENT_CONTACTS])
            {
                [self createTable:SQL_CREATE_RECENT_CONTACTS];
            }
            if (![_database tableExists:TABLE_RECENT_CONTACTS_VIEW])
            {
                [self createTable:SQL_CREATE_RECENT_CONTACTS_VIEW];
            }
            
        }
    }
    return self;
}

+(NSString *)dbFilePath
{
    NSString* myName = [[[MTUserModule shareInstance] myUserEntity]name];
    
    NSString* directorPath = [[duoduo applicationSupportDirectory] stringByAppendingPathComponent:myName];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //改用户的db是否存在，若不存在则创建相应的DB目录
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
            DDLog(@"创建%@’DB目录失败",myName);
        }
    }
    
    NSString *dbPath = [directorPath stringByAppendingPathComponent:DB_FILE_NAME];
    return @"/Users/scorpio/Library/Application Support/Duoduo 1.0/12pt5pe/IMSession.db";
//    return dbPath;
}

-(BOOL)createTable:(NSString *)sql          //创建表
{
    BOOL result = NO;
    [_database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"%@",sql];
    result = [_database executeUpdate:tempSql];
    [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
    return result;
}

- (MessageEntity*)messageFromResult:(FMResultSet*)resultSet
{    
    MessageEntity* messageEntity = [[MessageEntity alloc] init];
    
    NSString* sessionID = [resultSet stringForColumn:@"sessionId"];
    if (!sessionID)
    {
        return nil;
    }
    messageEntity.sessionId = sessionID;
    
    uint8 sessionType = [resultSet intForColumn:@"sessionType"];
    messageEntity.msgType = sessionType;
    
    NSString* fromUserId = [resultSet stringForColumn:@"fromUserId"];
    messageEntity.senderId = fromUserId;
    
    NSString* content = [resultSet stringForColumn:@"content"];
    messageEntity.msgContent = content;
    
    uint32 msgTime = [resultSet intForColumn:@"msgTime"];
    messageEntity.msgTime = msgTime;
    
    return messageEntity;
}

- (id)entityFromResult:(FMResultSet*)resultSet
{
    NSInteger type = [resultSet intForColumn:@"type"];
    if (type == 1)
    {
        /*
        UserEntity* user = [[UserEntity alloc] init];
        user.userId = [resultSet stringForColumn:@"ID"];
        user.name = [resultSet stringForColumn:@"name"];
        user.userUpdated = [resultSet intForColumn:@"updateTime"];
        NSString* content = [resultSet stringForColumn:@"content"];
        NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            NSDictionary* contentInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            int userRole = [contentInfo[@"userRole"] intValue];
//            user.userRole = userRole;
            NSString* avatar = contentInfo[@"avatar"];
            user.avatar = avatar;
        }
        return user;
         */
    }
    else if (type == 2)
    {
        //tt_3.0
        /*
        GroupEntity* group = [[GroupEntity alloc] init];
        group.groupId = [resultSet stringForColumn:@"ID"];
        group.name = [resultSet stringForColumn:@"name"];
//        group.groupUpdated = [resultSet intForColumn:@"updateTime"];
        NSString* content = [resultSet stringForColumn:@"content"];
        NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            NSDictionary* contentInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int groupType = [contentInfo[@"groupType"] intValue];
            group.groupType = groupType;
            NSArray* groupUSersIDs = contentInfo[@"groupUsersIDs"];
            group.groupUserIds = [NSMutableArray arrayWithArray:groupUSersIDs];
            NSString* groupCreatorID = contentInfo[@"groupCreatorID"];
            group.groupCreatorId = groupCreatorID;
        }
        return group;
         */
        return nil;
    }
    return nil;
}

//CREATE TABLE IF NOT EXISTS %@ (fileID integer,fromUserId text,toUserId text,fileSize integer, fileState integer, obligate1 text, obligate2 integer)
- (FileObject*)fileMessageFromResult:(FMResultSet*)resultSet
{
    FileObject* fileObject = [[FileObject alloc] init];
    
    NSString* fromUserID = [resultSet stringForColumn:@"fromUserId"];
    [fileObject setFromUserID:fromUserID];
    
    NSString* toUserID = [resultSet stringForColumn:@"toUserId"];
    [fileObject setToUserID:toUserID];
    
    NSInteger fileSize = [resultSet intForColumn:@"fileSize"];
    fileObject.fileSize = fileSize;
    
    NSInteger fileState = [resultSet intForColumn:@"fileState"];
    fileObject.fileState = fileState;
    
    NSString* filePath = [resultSet stringForColumn:@"fileName"];
    fileObject.filePath = filePath;
    
    return fileObject;
}

#pragma mark Quary
// 获取sessionId对应的数据
- (NSArray*)getUserInfoBySessionId:(NSString*)sessionId
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [_database setShouldCacheStatements:YES];
    array = [[NSMutableArray alloc] initWithCapacity:0];

    FMResultSet *resultSet = [_database executeQuery:@"SELECT * FROM recentContacts where ID=?",sessionId];
    while ([resultSet next]){
        NSString *recentName = [resultSet stringForColumn:@"name"];
        //    NSString *recentContent = [resultSet stringForColumn:@"content"];
        //    array[0] = recentName;
        //    array[1] = recentContent;
        return array;
    }
    return nil;
}




- (void)loadMessageBySessionId:(NSString*)sessionId
                     msgOffset:(uint32_t)msgOffset
                      msgCount:(uint32_t)msgCount
                       success:(void(^)(NSArray* messages))success
                       failure:(void(^)(NSString* errorDescripe))failure
{
    

    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([_database tableExists:@"message"]) {
            [_database setShouldCacheStatements:YES];
            array = [[NSMutableArray alloc] initWithCapacity:0];
            
            FMResultSet *resultSet = [_database executeQuery:@"SELECT * FROM message where sessionId=? ORDER BY msgTime DESC,rowid DESC limit ?,?",sessionId,[NSNumber numberWithInt:msgOffset],[NSNumber numberWithInt:msgCount]];
            
            while ([resultSet next])
            {
                MessageEntity* message = [self messageFromResult:resultSet];
                if(nil == message.msgContent || [message.msgContent isEqualToString:@""])
                    continue;
                [array addObject:message];
            }
            log4Info(@"------------------------------------------------------>123");
            dispatch_async(dispatch_get_main_queue(), ^{
                success(array);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(@"表布存在");
            });
        }
    });
}

- (NSMutableArray *)getMessageBySessionId:(NSString *)sessionId
                                msgOffset:(uint32_t)msgOffset
                                 msgCount:(uint32_t)msgCount
{
    //SELECT * FROM message where sessionId=6 limit 20,10;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @try {
        if ([_database tableExists:@"message"]) {
            [_database setShouldCacheStatements:YES];
            array = [[NSMutableArray alloc] initWithCapacity:0];
            
            FMResultSet *resultSet = [_database executeQuery:@"SELECT * FROM message where sessionId=? ORDER BY msgTime DESC,rowid DESC limit ?,?",sessionId,[NSNumber numberWithInt:msgOffset],[NSNumber numberWithInt:msgCount]];

            while ([resultSet next])
            {
                MessageEntity* message = [self messageFromResult:resultSet];
                [array addObject:message];
            }
        }
    }@finally {
        
    }
    return array;
}


- (void)loadFileMessageCompletion:(LoadFileMessageCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_FILEMESSAGE]) {
            [_database setShouldCacheStatements:YES];
            array = [[NSMutableArray alloc] init];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY fileTime DESC,rowid DESC",TABLE_FILEMESSAGE];
            
            FMResultSet *resultSet = [_database executeQuery:sqlString];
            
            while ([resultSet next])
            {
                FileObject* fileObject = [self fileMessageFromResult:resultSet];
                fileObject.fileSizeDesc = [FileObject getFileSizeDesc:fileObject.fileSize];
                NSFileManager* fileManager = [NSFileManager defaultManager];
                if(![fileManager fileExistsAtPath:[fileObject downLoadPath]])
                    continue;
                fileObject.filePath = [fileObject downLoadPath];
                [array addObject:fileObject];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array);
            });
        }
    });
}

- (void)loadAllSessionCompletion:(LoadAllSessionCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"select DISTINCT sessionId from %@",TABLE_MESSAGE];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                NSString* sessionID = [result stringForColumn:@"sessionId"];
                [array addObject:sessionID];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    });
}

- (void)loadMessageForSessionID:(NSString*)sessionID pageCount:(int)pagecount page:(NSInteger)page completion:(LoadMessageInSessionCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM message where sessionId=? ORDER BY msgTime ASC,rowid DESC limit ?,?"];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,[NSNumber numberWithInteger:page * pagecount],[NSNumber numberWithInteger:pagecount]];
            while ([result next])
            {
                MessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    });
}

- (void)getMessagesCountForSessionID:(NSString*)sessionID completion:(MessageCountCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ where sessionId=?",TABLE_MESSAGE];
            
            FMResultSet* result = [_database executeQuery:sqlString,sessionID];
            int count = 0;
            while ([result next])
            {
                count = [result intForColumnIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(count);
            });
        }
    });
}

- (void)searchMessageContent:(NSString*)searchContent completion:(SearchMessageContent)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray* sessionIDs = [NSMutableArray array];
        if ([_database tableExists:TABLE_MESSAGE])
        {
//            [_database setShouldCacheStatements:YES];
            
            NSString* sql = [NSString stringWithFormat:@"SELECT DISTINCT sessionId FROM %@ where content like '%%%@%%'",TABLE_MESSAGE,searchContent];
            FMResultSet* result = [_database executeQuery:sql];
            while ([result next])
            {
                NSString* sessionID = [result stringForColumnIndex:0];
                if (sessionID)
                {
                    [sessionIDs addObject:sessionID];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(sessionIDs);
        });
    });
}

- (void)loadRecentUsersCompletion:(DBLoadRecentContactsCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        @try {
//            if ([_database tableExists:TABLE_RECENT_CONTACTS_VIEW]) {
//                [_database setShouldCacheStatements:YES];
            NSString* sql = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_RECENT_CONTACTS_VIEW];
                FMResultSet *resultSet = [_database executeQuery:sql];
                
                while ([resultSet next])
                {
                    id object = [self entityFromResult:resultSet];
                    if (object)
                    {
                        [array addObject:object];
                    }
                }
//            }
        }@finally {
            completion(array,nil);
        }
    });
}

#pragma mark Insert
- (void)insertMessage:(MessageEntity*)message
              success:(void(^)())success
              failure:(void(^)(NSString* errorDescripe))failure
{
    StateMaintenanceManager* stateMaintenanceManager = [StateMaintenanceManager instance];
    if ([stateMaintenanceManager getMyOnlineState] == USER_STATUS_OFFLINE)
    {
        failure(@"用户已经离线了");
        return;
    }
    dispatch_async(self.databaseMessageQueue, ^{
        NSString* toUserID = nil;
        if (message.msgType == MESSAGE_TYPE_SINGLE)
        {
            NSString *myUserId = [[DDClientState shareInstance] userID];
            if ([message.senderId isEqualToString:myUserId])
            {
                toUserID = message.orginId;
            }
            else
            {
                toUserID = myUserId;
            }
        }
        else
        {
            toUserID = message.orginId;
        }
        NSString* beginTransc = @"BEGIN TRANSACTION";
        [_database executeUpdate:beginTransc];
        
        BOOL result = [_database executeUpdate:@"INSERT INTO message VALUES(?,?,?,?,?,?,?)",message.sessionId,message.senderId,toUserID,message.msgContent,[NSNumber numberWithInt:message.msgRenderType],[NSNumber numberWithLong:message.msgTime],[NSNumber numberWithInt:message.msgType]];
        if (result)
        {
            success();
        }
        else
        {
            DDLog(@"insert to database failure content:%@",message.msgContent);
            log4Error(@"insert to database failure content:%@",message.msgContent);
            failure(@"插入数据失败");
        }
        NSString* endTransc = @"COMMIT TRANSACTION";
        [_database executeUpdate:endTransc];
    });
}

- (void)insertMessages:(NSArray*)messages
               success:(void(^)())success
               failure:(void(^)(NSString* errorDescripe))failure
{
    dispatch_async(self.databaseMessageQueue, ^{
        [_database beginTransaction];

//        DDLog(@"-------------------------------->%lf",[[NSDate date] timeIntervalSince1970]);
        
        __block BOOL isRollBack = NO;
        @try {
            [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* toUserID = nil;
                MessageEntity* message = (MessageEntity*)obj;
                if (message.msgType == MESSAGE_TYPE_SINGLE)
                {
                    NSString *myUserId =[[DDClientState shareInstance] userID];
                    if ([message.senderId isEqualToString: myUserId])
                    {
                        toUserID = message.orginId;
                    }
                    else
                    {
                        toUserID = myUserId;
                    }
                }
                else
                {
                    toUserID = message.orginId;
                }
                BOOL result = [_database executeUpdate:@"INSERT INTO message VALUES(?,?,?,?,?,?,?)",message.sessionId,message.senderId,toUserID,message.msgContent,[NSNumber numberWithInt:message.msgRenderType],[NSNumber numberWithLong:message.msgTime],[NSNumber numberWithInt:message.msgType]];
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];

        }
        @catch (NSException *exception) {
            failure(@"插入数据失败");
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                log4Error(@"insert to database failure content");
                failure(@"插入数据失败");
                
            }
            else
            {
                [_database commit];
                success();
            }
        }
        
//        NSString* endTransc = @"COMMIT TRANSACTION";
//        [_database executeUpdate:endTransc];
//        DDLog(@"-------------------------------->%lf",[[NSDate date] timeIntervalSince1970]);
    });
}


- (void)insertFileMessages:(NSArray*)fileObjects
               completion:(InsertFileMessageCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [fileObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                FileObject* file = (FileObject*)obj;
                //fileID integer PRIMARY KEY NOT NULL ,fromUserId text NOT NULL,toUserId text NOT NULL,fileSize integer, fileState integer, fileTime real NOT NULL, obligate1 text, obligate2 integer
                NSString* SQL = [NSString stringWithFormat:@"INSERT INTO %@(fileName,fromUserId,toUserId,fileSize,fileState,fileTime) VALUES(?,?,?,?,?,?)",TABLE_FILEMESSAGE];
                NSString* fileName = [file downLoadPath];
                NSString* fromUserID = [file fromUserID];
                NSString* toUserID = [file toUserID];
                NSInteger fileSize = [file fileSize];
                NSInteger fileState = [file fileState];
                UInt32 time = [file fileTime];
                
                BOOL result = [_database executeUpdate:SQL,fileName,fromUserID,toUserID,[NSNumber numberWithInteger:fileSize],[NSNumber numberWithInteger:fileState],[NSNumber numberWithInteger:time]];

                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
            
        }
        @catch (NSException *exception) {
            NSError* error = [NSError errorWithDomain:@"插入数据失败" code:0 userInfo:nil];
            completion(error);
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                NSError* error = [NSError errorWithDomain:@"插入数据失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    });
}

#pragma mark Delete
- (void)deleteMesagesForSession:(NSString*)sessionID completion:(DeleteSessionCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        NSString* sql = @"DELETE FROM message WHERE sessionId = ?";
        BOOL result = [_database executeUpdate:sql,sessionID];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    });
}

#pragma mark Update
- (void)updateRecentUsers:(NSArray*)objsects completion:(SaveAllSessionCompletion)completion
{
    dispatch_async(self.databaseMessageQueue, ^{
        BOOL completioned = NO;
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@",TABLE_RECENT_CONTACTS];
        BOOL result = [_database executeUpdate:sql];
        if (result)
        {
            @try {
                [objsects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString* ID;
                    NSString* name;
                    int type;
                    NSString* content;
                    NSString* insertSql = [NSString stringWithFormat:@"INSERT INTO %@(ID,name,updateTime,type,content) VALUES(?,?,?,?,?)",TABLE_RECENT_CONTACTS];
                    if ([obj isKindOfClass:[MTUserEntity class]])
                    {
                        MTUserEntity* user = (MTUserEntity*)obj;
                        ID = user.ID;
                        name = user.name;
                        type = 1;
//                        int userRole = user.userRole;
                        NSString* avatar = user.avatar;
//                        NSDictionary* info = @{@"userRole":@(userRole),@"avatar":avatar};
                        NSDictionary* info = @{@"avatar":avatar};
                        NSData* data = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
                        content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        //ID text PRIMARY KEY NOT NULL ,name text NOT NULL,updateTime real,type integer,content text,obligate1 text, obligate2 integer
                        BOOL result = [_database executeUpdate:insertSql,ID,name,@(0),@(type),content];
                        if (!result)
                        {
                            DDLog(@"插入最近联系人失败");
                        }
                    }
                    else if ([obj isKindOfClass:[MTGroupEntity class]])
                    {
                        MTGroupEntity* group = (MTGroupEntity*)obj;
                        ID = group.groupCreatorId;
                        name = group.name;
                        type = 2;
                        int groupType = group.groupType;
                        NSArray* groupUserIDs = group.groupUserIds;
                        NSString* groupCreatorID = group.groupCreatorId;
                        NSDictionary* info = @{@"groupType":@(groupType),@"groupUsersIDs":groupUserIDs,@"groupCreatorID":groupCreatorID};
                        NSData* data = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
                        content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        BOOL result = [_database executeUpdate:insertSql,ID,name,@(0),@(type),content];
                        if (!result)
                        {
                            DDLog(@"插入最近联系人失败");
                        }
                    }
                }];
            }
            @catch (NSException *exception) {
                completioned = YES;
                completion(NO);
            }
            @finally {
                if (!completion)
                {
                    completion(YES);
                }
            }
        }
    });
}
@end
