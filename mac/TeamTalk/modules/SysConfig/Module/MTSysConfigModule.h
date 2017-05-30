//
//  MTSysConfigModule.h
//  Duoduo
//
//  Created by wj on 15/1/20.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSysConfigEntity.h"

#define MT_SYS_CONFIG_USER_LASTUPTIME   @"user"

@interface MTSysConfigModule : NSObject

+ (MTSysConfigModule*)shareInstance;
- (instancetype)init;
- (void)getSysConfigFromLocal;
- (void)addMaintainSysConfigEntities:(NSArray*)sysConfigEntities;
- (MTSysConfigEntity*)getSysConfigEntity:(NSString*) sysConfigName;
- (BOOL)updateSysConfigValueWithSysConfigName:(MTSysConfigEntity*)sysConfigEntity;
- (void)addSysConfigEntitiesToDBAndMaintainWithsysConfigName:(NSString *)sysConfigName sysConfigValue:(NSInteger)sysConfigValue;

@end
