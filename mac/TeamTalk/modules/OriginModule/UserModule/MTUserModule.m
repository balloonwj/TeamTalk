//
//  MTUserModule.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTUserModule.h"
#import "DDAllUserAPI.h"
#import "MTUserEntity.h"
#import "MTDatabaseUtil.h"
#import "MTSysConfigModule.h"
#import "SpellLibrary.h"
#import "DDUserDetailInfoAPI.h"
@interface MTUserModule(PrivateAPI)

- (void)p_loadLocalUserData;
- (void)p_loadDepartmentData;

@end

@implementation MTUserModule
{
    NSMutableDictionary* _allUsers;
}
+ (MTUserModule*)shareInstance
{
    static MTUserModule* g_userModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_userModule = [[MTUserModule alloc] init];
    });
    return g_userModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self registObserveClientState];
        _allUsers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH]) {
        DDClientState *clientState = (DDClientState *)object;
        switch (clientState.userState) {
            case DDUserOnline:      //上线,可以获取所有的联系人.
                [self p_loadLocalUserData];
                [self allUserReq];
                break;
                
            default:
                break;
        }
    }
}

-(void)allUserReq{
    
    MTSysConfigEntity* sysConfigEntity = [[MTSysConfigModule shareInstance] getSysConfigEntity:MT_SYS_CONFIG_USER_LASTUPTIME];
    NSInteger latestUpdateTime = sysConfigEntity.sysConfigValue;
    DDAllUserAPI *api = [[DDAllUserAPI alloc] init];
    [api requestWithObject:@[@(latestUpdateTime)] Completion:^(id response, NSError *error) {
        if (!error) {
            NSInteger responseLastUpdateTime = [[response objectForKey:@"latestUpdateTime"] integerValue];
            
            if(latestUpdateTime==0|| latestUpdateTime!=responseLastUpdateTime){
                NSMutableArray *userArray = [response objectForKey:@"userlist"];
                [self addMaintainOriginEntities:userArray];
                [[MTDatabaseUtil instance] insertUsers:userArray];
                [[MTSysConfigModule shareInstance] addSysConfigEntitiesToDBAndMaintainWithsysConfigName:MT_SYS_CONFIG_USER_LASTUPTIME sysConfigValue:responseLastUpdateTime];
            }
            //通知UI更新.🐓            
            [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDRemoteUserDataReady;
        }else{
            
            DDLog(@"error:%@",[error domain]);
        }
    }];
    
}


-(MTUserEntity *)myUserEntity{
    NSString *myUserId = [[DDClientState shareInstance] userID];
    return (MTUserEntity *)[self getOriginEntityWithOriginID:myUserId];
}

#pragma protocol

-(NSArray *)getAllOriginEntity{
    return [NSArray arrayWithArray:[_allUsers allValues]];
}

-(NSArray *)getAllUserId{
    return  [NSArray arrayWithArray:[_allUsers allKeys]];
}
- (void)addMaintainOriginEntities:(NSArray*)originEntities{

    for (MTUserEntity *userEntity in originEntities) {
        [[SpellLibrary instance] addSpellForObject:userEntity];
        [_allUsers setObject:userEntity forKey:userEntity.ID];
    }
}
/**
 *  根据OriginID获取实体类
 *
 *  @param originID originID
 *
 *  @return 实体类
 */
- (DDOriginEntity*)getOriginEntityWithOriginID:(NSString*)originID{
    return [_allUsers objectForKey:originID];
}

/**
 *  在本地没有相应信息的时候调用此接口，从后端获取
 *
 *  @param originIDs  originIDs
 *  @param completion 完成获取
 */

- (void)getOriginEntityWithOriginIDsFromRemoteCompletion:(NSArray*)originIDs completion:(DDGetOriginsInfoCompletion)completion{
    if ([originIDs count] == 0)
    {
        return;
    }
    DDUserDetailInfoAPI* userDetailInfoAPI = [[DDUserDetailInfoAPI alloc] init];
    [userDetailInfoAPI requestWithObject:originIDs Completion:^(id response, NSError *error) {
        if (!error && response)
        {
            [self addMaintainOriginEntities:response];
        }
        completion(response,error);
    }];
}

- (void)removeOriginForIDs:(NSArray*)originIDs{
    [_allUsers removeObjectsForKeys:originIDs];
}


#pragma mark -
#pragma mark - PrivateAPI
- (void)p_loadLocalUserData
{
    NSArray* users = [[MTDatabaseUtil instance] queryUsers];
    [self addMaintainOriginEntities:users];
    [DDClientState shareInstance].dataState = [DDClientState shareInstance].dataState | DDLocalUserDataReady;
}

@end
