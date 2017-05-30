//
//  MTUserModule.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTGroupModule.h"
#import "MTGroupEntity.h"
#import "DDFixedGroupAPI.h"
#import "DDGroupInfoAPI.h"
#import "DDClientState.h"
#import "MTDatabaseUtil.h"
#import "DDReceiveGroupMemberChangedAPI.h"
#import "MTSessionModule.h"
#import "SpellLibrary.h"
#import "MTUserModule.h"
typedef void(^MTGroupInfoCompletion)(BOOL success);
typedef void(^HandleGroupMemberChange)();

@interface MTGroupModule(PrivateAPI)

- (void)p_loadRemoteGroup;
- (void)p_loadLocalGroup;
- (void)p_saveGroupData;
- (void)p_updateGroupWithGroupVersionInfo:(NSMutableArray*)needUpdateGroupList completion:(MTGroupInfoCompletion)completion;

- (void)p_registerAPI;

@end

@implementation MTGroupModule{
    NSMutableDictionary* _allGroup;
    
}

+ (MTGroupModule*)shareInsatnce
{
    static MTGroupModule* g_groupModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_groupModule = [[MTGroupModule alloc] init];
    });
    return g_groupModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self registObserveClientState];
        _allGroup = [[NSMutableDictionary alloc]init];
        [self p_registerAPI];
    }
    return self;
}

-(NSArray *)getAllOriginEntity{
    return [NSArray arrayWithArray:[_allGroup allValues]];
}

- (void)getLocalOrginEntity
{
    DDLog(@"拉取本地群信息");
    NSArray* allGroup = [[MTDatabaseUtil instance] queryGroups];
    [self addMaintainOriginEntities:allGroup];
}

- (void)addMaintainOriginEntities:(NSArray*)originEntities{
    for (MTGroupEntity* groupEntity in originEntities) {
        [_allGroup setObject:groupEntity forKey:groupEntity.ID];
        [[SpellLibrary instance] addSpellForObject:groupEntity];
    }
}

- (DDOriginEntity*)getOriginEntityWithOriginID:(NSString*)originID{
    DDOriginEntity *entity =[_allGroup objectForKey:originID];
    return entity;
}

- (void)getOriginEntityWithOriginIDsFromRemoteCompletion:(NSArray*)originIDs completion:(DDGetOriginsInfoCompletion)completion{
    
    NSString* reqUserId = [DDClientState shareInstance].userID;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setObject:reqUserId forKey:@"reqUserId"];
    NSMutableArray* groupVersionList = [[NSMutableArray alloc] init];
    for(NSString *originId in originIDs){
        NSDictionary *originDictionary = [NSDictionary dictionaryWithObjectsAndKeys:originId,@"groupId",0,@"version", nil];
        [groupVersionList addObject:originDictionary];
    }
    [param setObject:groupVersionList forKey:@"groupVersionList"];
    DDGroupInfoAPI *api = [[DDGroupInfoAPI alloc] init];
    [api requestWithObject:param Completion:^(id response, NSError *error) {
        if (!error) {
            NSMutableArray* groupInfos = [response objectForKey:@"groupList"];
            [self addMaintainOriginEntities:groupInfos];
            [[MTDatabaseUtil instance] insertGroups:groupInfos];
            completion(groupInfos,error);
        }else{
            DDLog(@"erro:%@",[error domain]);
        }
    }];
}

- (void)removeOriginForIDs:(NSArray*)originIDs{
    [_allGroup removeObjectsForKeys:originIDs];
}

- (void)updateTempGroupInfoFromSessions:(NSArray*)groupIDs
{
    NSMutableArray* info = [[NSMutableArray alloc] init];
    [groupIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTGroupEntity* group = (MTGroupEntity*)[self getOriginEntityWithOriginID:obj];
        if (group)
        {
            NSDictionary* groupInfo = @{@"version" : @(group.groupVersion),@"groupId" : obj};
            [info addObject:groupInfo];
        }
        else
        {
            NSDictionary* groupInfo = @{@"version" : @(0),@"groupId" : obj};
            [info addObject:groupInfo];
        }
    }];
    if ([info count] > 0)
    {
        [self p_updateGroupWithGroupVersionInfo:info completion:^(BOOL success) {
            [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteSessionGroupDataReady;
        }];
    }
    else
    {
        [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteSessionGroupDataReady;
    }
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH]) {
        DDClientState *clientState = (DDClientState *)object;
        switch (clientState.userState) {
            case DDUserOnline:      //上线,可以获取所有的群.
                [self p_loadLocalGroup];
                [self p_loadRemoteGroup];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark - PrivateAPI

- (void)p_registerAPI
{
    DDReceiveGroupMemberChangedAPI* receiveGroupMemberChangedAPI = [[DDReceiveGroupMemberChangedAPI alloc] init];
    [receiveGroupMemberChangedAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if (!error)
        {
            NSString* groupID = object[@"groupID"];
            NSArray* userList = object[@"userIDs"];
            
            HandleGroupMemberChange handleGroupMemberChange = ^{
                MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
                if (!group)
                {
                    if ([userList containsObject:[DDClientState shareInstance].userID]) {
                        [[MTGroupModule shareInsatnce] getOriginEntityWithOriginIDsFromRemoteCompletion:@[groupID] completion:^(NSArray *origins, NSError *error) {
                            if (!error)
                            {
                                MTGroupEntity* group = origins[0];
                                MTSessionEntity* session = [[MTSessionModule shareInstance] addSessionFromOriginEntity:group saveToDB:YES];
                                //[session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
                                [session updateUpdateTime:0];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
                                [[MTGroupModule shareInsatnce] addMaintainOriginEntities:@[group]];
                                [[MTDatabaseUtil instance] insertGroups:@[group]];
                            }
                        }];
                    }
                }
                else
                {
                    if ([userList containsObject:[DDClientState shareInstance].userID])
                    {
                        group.groupUserIds = [[NSMutableArray alloc] initWithArray:userList];
                        [[MTDatabaseUtil instance] insertGroups:@[group]];
                    }
                    else
                    {
                        //删除会话
                        NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:groupID sessionType:SessionTypeSessionTypeGroup];
                        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
                        [[MTSessionModule shareInstance] removeSessions:@[session]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
                        if ([[MTSessionModule shareInstance].currentChatingSessionID isEqualToString:sessionID])
                        {
                            NSString* firstSessionID = [[MTSessionModule shareInstance] sessions][0];
                            [[DDMainWindowController instance] openSessionChatWithSessionID:firstSessionID];
                        }
                    }
                }

            };
            
            NSMutableArray* unknowUsers = [[NSMutableArray alloc] init];
            for (NSString* userID in userList)
            {
                if (![[MTUserModule shareInstance] getOriginEntityWithOriginID:userID])
                {
                    [unknowUsers addObject:userID];
                }
            }
            if ([unknowUsers count] > 0 && [userList containsObject:[DDClientState shareInstance].userID])
            {
                [[MTUserModule shareInstance] getOriginEntityWithOriginIDsFromRemoteCompletion:unknowUsers completion:^(NSArray *origins, NSError *error) {
                    handleGroupMemberChange();
                }];
            }
            else
            {
                handleGroupMemberChange();
            }
            
        }
    }];
}

- (void)p_loadLocalGroup
{
    NSArray* allGroup = [[MTDatabaseUtil instance] queryGroups];
    [self addMaintainOriginEntities:allGroup];
    [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDLocalGroupDataReady;
}

- (void)p_saveGroupData
{
    NSArray* allGroup = [_allGroup allKeys];
    [[MTDatabaseUtil instance] insertGroups:allGroup];
}

- (void)p_loadRemoteGroup{
    
    DDFixedGroupAPI *api = [[DDFixedGroupAPI alloc] init];
    NSString* reqUserId = [DDClientState shareInstance].userID;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setObject:reqUserId forKey:@"reqUserId"];
    [api requestWithObject:param Completion:^(id response, NSError *error) {
        if (!error) {
            NSMutableArray* groupInfos = [response objectForKey:@"groupVersionList"];
            NSInteger groupInfosCnt = [groupInfos count];
            NSMutableArray* needUpdateGroupList = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i<groupInfosCnt; i++) {
                NSMutableDictionary* groupInfo = [groupInfos objectAtIndex:i];
                NSInteger groupServerVersion = [[groupInfo objectForKey:@"version"] integerValue];
                NSString* groupId = [groupInfo objectForKey:@"groupId"];
                MTGroupEntity* groupEntity = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupId];
                NSInteger localVersion = groupEntity.groupVersion;
                if (localVersion != groupServerVersion || localVersion == 0) {
                    [groupInfo setObject:@(localVersion) forKey:@"version"];
                    [needUpdateGroupList addObject:groupInfo];
                }
            }
            if ([needUpdateGroupList count] > 0)
            {
                [self p_updateGroupWithGroupVersionInfo:(NSMutableArray*)needUpdateGroupList completion:^(BOOL success) {
                    if (success)
                    {
                        [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteFixGroupDataReady;
                    }
                }];
            }
            else
            {
                [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteFixGroupDataReady;
            }
        }else{
            DDLog(@"error:%@",[error domain]);
        }
    }];
    
}

- (void)p_updateGroupWithGroupVersionInfo:(NSMutableArray*)needUpdateGroupList completion:(MTGroupInfoCompletion)completion{
    NSString* reqUserId = [DDClientState shareInstance].userID;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setObject:reqUserId forKey:@"reqUserId"];
    [param setObject:needUpdateGroupList forKey:@"groupVersionList"];
    DDGroupInfoAPI *api = [[DDGroupInfoAPI alloc] init];
    [api requestWithObject:param Completion:^(id response, NSError *error) {
        if (!error) {
            NSMutableArray* groupInfos = [response objectForKey:@"groupList"];
            [self addMaintainOriginEntities:groupInfos];
            [[MTDatabaseUtil instance] insertGroups:groupInfos];
            completion(YES);
        }else{
            completion(NO);
        }
    }];
}
@end
