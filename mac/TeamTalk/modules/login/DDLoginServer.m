//
//  DDLoginServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginServer.h"
#import "DDTcpClientManager.h"

typedef void(^LoginServerSuccess)(id loginEntity);
typedef void(^LoginServerFailure)();

//static NSInteger const timeoutInterval = 10;

@interface DDLoginServer(Notification)


@end

@implementation DDLoginServer
{
    LoginServerSuccess _success;
    LoginServerFailure _failure;
    BOOL _logining;
    NSUInteger _connectTimes;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        _logining = NO;
        _connectTimes = 0;
    }
    return self;
}



@end
