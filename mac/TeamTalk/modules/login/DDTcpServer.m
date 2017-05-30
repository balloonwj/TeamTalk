//
//  DDTcpServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDTcpServer.h"
#import "DDTcpClientManager.h"

typedef void(^Success)();
typedef void(^Failure)();

static NSInteger timeoutInterval = 10;

@interface DDTcpServer(notification)

- (void)n_receiveTcpLinkConnectCompleteNotification:(NSNotification*)notification;
- (void)n_receiveTcpLinkConnectFailureNotification:(NSNotification*)notification;


@end

@implementation DDTcpServer
{
    Success _success;
    Failure _failure;
    BOOL _connecting;
    NSUInteger _connectTimes;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        _connecting = NO;
        _connectTimes = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveTcpLinkConnectCompleteNotification:)
                                                     name:notificationTcpLinkConnectComplete
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveTcpLinkConnectFailureNotification:)
                                                     name:notificationTcpLinkConnectFailure
                                                   object:nil];
        
    }
    return self;
}

- (void)loginTcpServerIP:(NSString*)ip port:(NSInteger)point Success:(void(^)())success failure:(void(^)())failure
{
    if (!_connecting)
    {
        _connectTimes ++;
        _connecting = YES;
        _success = [success copy];
        _failure = [failure copy];
        [[DDTcpClientManager instance] disconnect];
        [[DDTcpClientManager instance] connect:ip port:point status:UserStatTypeUserStatusOnline];
        
        NSUInteger nowTimes = _connectTimes;
        double delayInSeconds = timeoutInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_connecting && nowTimes == _connectTimes)
            {
                _connecting = NO;
                _failure();
            }
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationTcpLinkConnectComplete object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationTcpLinkConnectFailure object:nil];
}

#pragma mark - notification
- (void)n_receiveTcpLinkConnectCompleteNotification:(NSNotification*)notification
{
    if(_connecting)
    {
        _connecting = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            _success();
        });
    }

}

- (void)n_receiveTcpLinkConnectFailureNotification:(NSNotification*)notification
{
    if (_connecting)
    {
        _connecting = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            _failure();
        });
    }
}

@end
