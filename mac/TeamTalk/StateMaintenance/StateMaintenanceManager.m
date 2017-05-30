//
//  StateMaintenanceManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "StateMaintenanceManager.h"
#import "LoginEntity.h"
#import "MTUserEntity.h"
#import "DDTcpClientManager.h"
#import "DDReceiveStateChangedAPI.h"
#import "DDOnlineUserListAPI.h"
#import "MTUserModule.h"

@interface StateMaintenanceManager(PrivateAPI)

- (void)p_maintanceOnlineStateOnTimer:(NSTimer*)timer;
- (void)p_registerStateMaintenance;

/**
 *  添加用户状态
 *
 *  @param userID    用户ID
 *  @param userState 在线，或者离开
 */
- (void)p_addOnlineUser:(NSString*)userID state:(UserStatType)userState;

/**
 *  移除在线用户
 *
 *  @param userID 用户ID
 */
- (void)p_removeOnlineUser:(NSString*)userID;

/**
 *  开始维护用户在线状态
 */
- (void)p_startMaintainUsersOnlineState;

/**
 *  停止维护用户在线状态
 */
- (void)p_endMaintainUsersOnlineState;

/**
 *  更新用户状态for kvo
 */
-(void)p_updateUserState:(NSString *)userID state:(UserStatType)userState;

@end

@implementation StateMaintenanceManager
{
    NSMutableDictionary* _userStates;
    NSTimer* _stateMaintenanceTimer;
}
+ (instancetype)instance
{
    static StateMaintenanceManager* g_stateMaintenanceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_stateMaintenanceManager = [[StateMaintenanceManager alloc] init];
    });
    return g_stateMaintenanceManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _userStates = [[NSMutableDictionary alloc] init];
        [self p_registerStateMaintenance];
        [self registObserveClientState];
        [self registObserveDataReadyState];
    }
    return self;
}

//tt_3.0 这里还有一个离线状态需要处理 @某嘉
- (UserStatType)getUserStateForUserID:(NSString*)userID
{

    if (![[_userStates allKeys] containsObject:userID])
    {
        return UserStatTypeUserStatusOffline;
    }
    else
    {
        NSNumber* state = _userStates[userID];
        return [state intValue];
    }
}

//- (void)setUserStateEntity:(DDUserStateEntity *)userStateEntity
//{
//    [self willChangeValueForKey:DD_USER_ONLINE_STATE_KEYPATH];
//    _userStateEntity = [[DDUserStateEntity alloc] initWithUserId:userStateEntity.userId state:userStateEntity.uState];
//    [self didChangeValueForKey:DD_USER_ONLINE_STATE_KEYPATH];
//}
//
//+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {
//    if ([key isEqualToString:DD_USER_ONLINE_STATE_KEYPATH]) {
//        return NO;
//    }
//    
//    return [super automaticallyNotifiesObserversForKey:key];
//}

- (void)dealloc
{
    
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_DATA_STATE_KEYPATH])
    {
        DDDataState oldDataState = [change[@"old"] integerValue];
        DDDataState newDataState = [change[@"new"] integerValue];
        if (!(oldDataState & DDRemoteUserDataReady) && (newDataState & DDRemoteUserDataReady))
        {
            //用户数据加载完成，获取在线用户列表
            [self p_startMaintainUsersOnlineState];
        }
    }
    else if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH])
    {
        switch ([DDClientState shareInstance].userState)
        {
            case DDUserLogining:
                break;
            case DDUserOnline:
                break;
            case DDUserKickout:
            case DDUserKickByMobile:
                [self p_endMaintainUsersOnlineState];
                break;
            case DDUserOffLine:
                //离线所有用户
                [self p_endMaintainUsersOnlineState];
                break;
            case DDUserOffLineInitiative:
                //离线所有用户
                [self p_endMaintainUsersOnlineState];
                break;
            default:
                break;
        }
    }
}

#pragma mark - PrivateAPI
- (void)p_registerStateMaintenance
{
    DDReceiveStateChangedAPI* api = [[DDReceiveStateChangedAPI alloc] init];
    [api registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if (!error)
        {
            //修改用户状态
            UserStat *userStat = (UserStat*)object;
            NSString *strUserId = [NSString stringWithFormat:@"%i",userStat.userId];
            if(userStat.status==UserStatTypeUserStatusOffline){
                [self p_removeOnlineUser:strUserId];
            }else{
                [self p_addOnlineUser:strUserId state:userStat.status];
            }
            
            //通知刷新UI kvo
            DDUserStateEntity *userStateEntity =[[DDUserStateEntity alloc]initWithUserId:strUserId state:userStat.status];
            [[StateMaintenanceManager instance] setValue:userStateEntity forKey:DD_USER_ONLINE_STATE_KEYPATH];
        }
    }];
}

/**
 *  添加在线用户
 *
 *  @param userID 用户ID
 */
- (void)p_addOnlineUser:(NSString*)userID state:(UserStatType)userState
{
    [_userStates setObject:@(userState) forKey:userID];
}

-(void)p_updateUserState:(NSString *)userID state:(UserStatType)userState{
    
}

/**
 *  移除在线用户
 *
 *  @param userID 用户ID
 */
- (void)p_removeOnlineUser:(NSString*)userID
{
    [_userStates removeObjectForKey:userID];
}

- (void)p_startMaintainUsersOnlineState
{
    //TODO发起请求获取当前在线用户列表
    DDOnlineUserListAPI *onlineUserListApi = [[DDOnlineUserListAPI alloc]init];
    NSArray *allUserId = [[MTUserModule shareInstance] getAllUserId];
    NSMutableArray *intAllUserId = [[NSMutableArray alloc] init];
    [allUserId enumerateObjectsUsingBlock:^(NSString *strUserId, NSUInteger idx, BOOL *stop) {
        [intAllUserId addObject:@([strUserId integerValue])];
    }];
    [onlineUserListApi requestWithObject:(id)intAllUserId Completion:^(id response, NSError *error) {
        if(!error){
            NSArray *allUserState  = (NSArray *)response;
            [allUserState enumerateObjectsUsingBlock:^(UserStat *obj, NSUInteger idx, BOOL *stop) {
                if (obj.status!=UserStatTypeUserStatusOffline) {
                    [_userStates setObject:@(obj.status) forKey:[NSString stringWithFormat:@"%i",obj.userId]];
                }
            }];
        }
    }];
}

/**
 *  停止维护用户在线状态
 */
- (void)p_endMaintainUsersOnlineState
{
    [_userStates removeAllObjects];
}

@end

@implementation DDUserStateEntity

-(id)initWithUserId:(NSString *)userId state:(NSUInteger)uState{
    self=[super init];
    if (self) {
        _userId=[userId copy];
        _uState = uState;
    }
    return self;
}

@end
