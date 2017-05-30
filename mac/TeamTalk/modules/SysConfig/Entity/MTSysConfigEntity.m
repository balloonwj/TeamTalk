//
//  MTSysConfigEntity.m
//  Duoduo
//
//  Created by wj on 15/1/20.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTSysConfigEntity.h"

@implementation MTSysConfigEntity

- (id) initWithsysConfigName:(NSString *)sysConfigName sysConfigValue:(NSInteger)sysConfigValue
{
    self = [super init];
    if (self)
    {
        _sysConfigName = [sysConfigName copy];
        _sysConfigValue = sysConfigValue;
    }
    return self;
}

@end
