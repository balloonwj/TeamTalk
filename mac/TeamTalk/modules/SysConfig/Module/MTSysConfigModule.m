//
//  MTSysConfigModule.m
//  Duoduo
//
//  Created by wj on 15/1/20.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTSysConfigModule.h"
#import "MTDatabaseUtil.h"

@implementation MTSysConfigModule{
    NSMutableDictionary* _sysConfig;
}

+ (MTSysConfigModule*)shareInstance
{
    static MTSysConfigModule* g_sysConfigModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sysConfigModule = [[MTSysConfigModule alloc] init];
    });
    return g_sysConfigModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sysConfig = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)getSysConfigFromLocal
{
    NSArray* sysConfig = [[MTDatabaseUtil instance] querySysConfig];
    [self addMaintainSysConfigEntities:sysConfig];
}

- (void)addMaintainSysConfigEntities:(NSArray*)sysConfigEntities
{
    for (MTSysConfigEntity* sysConfig in sysConfigEntities) {
        [_sysConfig setObject:sysConfig forKey:sysConfig.sysConfigName];
    }
}

- (MTSysConfigEntity*)getSysConfigEntity:(NSString*) sysConfigName
{
    return [_sysConfig objectForKey:sysConfigName];
}

- (BOOL)updateSysConfigValueWithSysConfigName:(MTSysConfigEntity*)sysConfigEntity
{
    BOOL result = [[MTDatabaseUtil instance] updateSysConfig:(MTSysConfigEntity*) sysConfigEntity];
    return result;
}

- (void)addSysConfigEntitiesToDBAndMaintainWithsysConfigName:(NSString *)sysConfigName sysConfigValue:(NSInteger)sysConfigValue
{
    MTSysConfigEntity* newSysConfigEntity = [[MTSysConfigEntity alloc] initWithsysConfigName:sysConfigName sysConfigValue:sysConfigValue];
    [[MTDatabaseUtil instance] insertSysConfig:(MTSysConfigEntity *)newSysConfigEntity];
    NSArray* sysConfigArray = [[NSArray alloc] initWithObjects:newSysConfigEntity, nil];
    [[MTSysConfigModule shareInstance] addMaintainSysConfigEntities:sysConfigArray];
}
@end
