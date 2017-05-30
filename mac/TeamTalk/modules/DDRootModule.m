//
//  DDRootModule.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDRootModule.h"

@implementation DDRootModule
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _observerClientState = NO;
        _observerUserOnlineState = NO;
    }
    return self;
}

- (void)registObserveClientState
{
    _observerClientState = YES;
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_USER_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}

- (void)registObserveNetWorkState
{
    _observerNetWorkState = YES;
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_NETWORK_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}

- (void)registObserveDataReadyState
{
    _observerDataSate = YES;
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_DATA_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}

-(void)registObserveUserOnlineState{
    _observerUserOnlineState=YES;
    [[StateMaintenanceManager instance] addObserver:self forKeyPath:DD_USER_ONLINE_STATE_KEYPATH options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc
{
    if (_observerClientState)
    {
        [[DDClientState shareInstance] removeObserver:self
                                           forKeyPath:DD_USER_STATE_KEYPATH];
    }
    if (_observerNetWorkState)
    {
        [[DDClientState shareInstance] removeObserver:self
                                           forKeyPath:DD_NETWORK_STATE_KEYPATH];
    }
    if (_observerDataSate)
    {
        [[DDClientState shareInstance] removeObserver:self
                                           forKeyPath:DD_DATA_STATE_KEYPATH];
    }
    if (_observerUserOnlineState) {
        [[StateMaintenanceManager instance] removeObserver:self forKeyPath:DD_USER_ONLINE_STATE_KEYPATH];
    }
}

#pragma mark - 
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSAssert(NO, @"子类注册了KVO却没有实现KVO，class:%@",NSStringFromClass([self class]));
}


@end
