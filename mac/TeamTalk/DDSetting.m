//
//  DDSetting.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSetting.h"

static NSString* const kSettingVersionKey = @"SettingVersion";

@interface DDSetting(privateAPI)

- (void)checkUpdateToRestoreSetting;

@end

static NSString* kTopKey = @"TopSession";
static NSString* kShieldKey = @"ShieldSession";
@implementation DDSetting
+ (instancetype)instance
{
    static DDSetting* g_setting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_setting = [[DDSetting alloc] init];
    });
    return g_setting;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self checkUpdateToRestoreSetting];
    }
    return self;
}

- (void)restoreDefaultSetting
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:SHIELD_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*)getTopSessionIDs
{
    NSDictionary* topSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_SESSION_KEY];
    NSString* myID =  [[DDClientState shareInstance] userID];
    return topSessionDic[myID];
}

- (void)addTopSessionID:(NSString*)sessionID
{
    NSDictionary* topSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_SESSION_KEY];
    NSString* myID =  [[DDClientState shareInstance] userID];
    NSArray* oldTopSessions = topSessionDic[myID];
    NSMutableArray* newTopSession = [[NSMutableArray alloc] initWithArray:oldTopSessions];
    if (![newTopSession containsObject:sessionID])
    {
        [newTopSession addObject:sessionID];
    }
    NSMutableDictionary* newTopSessionDic = [[NSMutableDictionary alloc] initWithDictionary:topSessionDic];
    [newTopSessionDic setObject:newTopSession forKey:myID];
    [[NSUserDefaults standardUserDefaults] setObject:newTopSessionDic forKey:TOP_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeTopSessionID:(NSString*)sessionID
{
    NSArray* oldTopSession = [self getTopSessionIDs];
    if (![oldTopSession containsObject:sessionID])
    {
        return;
    }
    else
    {
        NSMutableArray* newTopSession = [[NSMutableArray alloc] initWithArray:oldTopSession];
        [newTopSession removeObject:sessionID];
        

        NSString* myID = [[DDClientState shareInstance] userID];
        
        NSDictionary* oldTopSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_SESSION_KEY];
        NSMutableDictionary* newTopSessionDic = [[NSMutableDictionary alloc] initWithDictionary:oldTopSessionDic];
        [newTopSessionDic setObject:newTopSession forKey:myID];
        
        [[NSUserDefaults standardUserDefaults] setObject:newTopSessionDic forKey:TOP_SESSION_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (NSArray*)getShieldSessionIDs
{
    NSDictionary* shieldSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:SHIELD_SESSION_KEY];
    NSString* myID =  [[DDClientState shareInstance] userID];
    NSMutableArray* shieldSessions = [[NSMutableArray alloc] initWithArray:shieldSessionDic[myID]];
    NSNumber* boolNumber = [[NSUserDefaults standardUserDefaults]objectForKey:FIRST_TIME_SET_BUSINESS_SHIELD];
    if (!boolNumber)
    {
        if (![shieldSessions containsObject:@"group_1fis"])
        {
            [self addShieldSessionID:@"group_1fis"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:FIRST_TIME_SET_BUSINESS_SHIELD];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FIRST_TIME_SET_BUSINESS_SHIELD];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    return shieldSessions;
}

- (void)addShieldSessionID:(NSString*)sessionID
{
    NSDictionary* shieldSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:SHIELD_SESSION_KEY];

    NSString* myID = [[DDClientState shareInstance] userID];
    NSArray* oldTopSessions = shieldSessionDic[myID];
    NSMutableArray* newShieldSession = [[NSMutableArray alloc] initWithArray:oldTopSessions];
    if (![newShieldSession containsObject:sessionID])
    {
        [newShieldSession addObject:sessionID];
    }
    
    NSMutableDictionary* newShieldSessionDic = [[NSMutableDictionary alloc] initWithDictionary:shieldSessionDic];
    [newShieldSessionDic setObject:newShieldSession forKey:myID];
    
    [[NSUserDefaults standardUserDefaults] setObject:newShieldSessionDic forKey:SHIELD_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeShieldSessionID:(NSString*)sessionID
{
    NSDictionary* shieldSessionDic = [[NSUserDefaults standardUserDefaults] objectForKey:SHIELD_SESSION_KEY];
    NSString* myID =  [[DDClientState shareInstance] userID];
    NSArray* oldTopSessions = shieldSessionDic[myID];
    NSMutableArray* newShieldSession = [[NSMutableArray alloc] initWithArray:oldTopSessions];
    if ([newShieldSession containsObject:sessionID])
    {
        [newShieldSession removeObject:sessionID];
    }
    
    NSMutableDictionary* newShieldSessionDic = [[NSMutableDictionary alloc] initWithDictionary:shieldSessionDic];
    [newShieldSessionDic setObject:newShieldSession forKey:myID];
    
    [[NSUserDefaults standardUserDefaults] setObject:newShieldSessionDic forKey:SHIELD_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - private API
- (void)checkUpdateToRestoreSetting
{
    NSString* version = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingVersionKey];
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if(!version)
    {
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kSettingVersionKey];
        [self restoreDefaultSetting];
    }
    if (version && ![version isEqualToString:currentVersion])
    {
//        [self restoreDefaultSetting];
//        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kSettingVersionKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
