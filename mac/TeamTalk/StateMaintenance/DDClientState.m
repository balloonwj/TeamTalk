//
//  DDClientState.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-14.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDClientState.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "DDReceiveKickAPI.h"
@interface DDClientState(PrivateAPI)

- (void)n_receiveReachabilityChangedNotification:(NSNotification*)notification;
- (void)p_registerAPI;

@end

@implementation DDClientState
+ (instancetype)shareInstance
{
    static DDClientState* g_clientState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_clientState = [[DDClientState alloc] init];
    });
    return g_clientState;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _userState = DDUserOffLine;
        _socketState = DDSocketDisconnect;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [self p_registerAPI];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveReachabilityChangedNotification:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUseStateWithoutObserver:(DDUserState)userState
{
    _userState = userState;
    if (userState == DDUserOffLine)
    {
        [self setValue:@(0) forKeyPath:DD_DATA_STATE_KEYPATH];
    }
}

- (void)setUserState:(DDUserState)userState
{
    _userState = userState;
    if (userState == DDUserOffLine)
    {
        [self setValue:@(0) forKeyPath:DD_DATA_STATE_KEYPATH];
    }
}

#pragma mark - privateAPI
- (void)n_receiveReachabilityChangedNotification:(NSNotification*)notification
{
    AFNetworkReachabilityStatus netWorkStatus = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    switch (netWorkStatus)
    {
        case AFNetworkReachabilityStatusNotReachable:
            [self setValue:@(DDNetWorkDisconnect) forKeyPath:DD_NETWORK_STATE_KEYPATH];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self setValue:@(DDNetWorkWifi) forKeyPath:DD_NETWORK_STATE_KEYPATH];
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [self setValue:@(DDNetWork3G) forKeyPath:DD_NETWORK_STATE_KEYPATH];
            break;
        case AFNetworkReachabilityStatusUnknown:
            log4Error(@"网络状态：unknow");
            break;
    }
}

- (void)p_registerAPI
{
    DDReceiveKickAPI* receiveKickAPI = [[DDReceiveKickAPI alloc] init];
    [receiveKickAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if (!error)
        {
            KickReasonType reason = [object intValue];
            switch (reason)
            {
                case KickReasonTypeKickReasonDuplicateUser:
                    self.userState = DDUserKickout;
                    break;
                case KickReasonTypeKickReasonMobileKick:
                    self.userState = DDUserKickByMobile;
                    break;
                default:
                    break;
            }
        }
    }];
}
@end
