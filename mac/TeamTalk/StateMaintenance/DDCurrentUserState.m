//
//  DDCurrentUserState.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDCurrentUserState.h"
#import "MTUserEntity.h"
@implementation DDCurrentUserState
+ (instancetype)instance
{
    static DDCurrentUserState* g_currentUserState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_currentUserState = [[DDCurrentUserState alloc] init];
    });
    return g_currentUserState;
}

- (void)loginTheUser:(MTUserEntity*)user
{
    if (_user)
    {
        _user = nil;
    }
    _user = [user copy];
}
@end
