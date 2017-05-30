//
//  DDSundriesCenter.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-23.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSundriesCenter.h"

@implementation DDSundriesCenter
+ (instancetype)instance
{
    static DDSundriesCenter* g_ddSundriesCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_ddSundriesCenter = [[DDSundriesCenter alloc] init];
    });
    return g_ddSundriesCenter;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _serialQueue = dispatch_queue_create("com.mogujie.SundriesSerial", NULL);
        _parallelQueue = dispatch_queue_create("com.mogujie.SundriesParallel", NULL);
    }
    return self;
}

- (void)pushTaskToSerialQueue:(Task)task
{
    dispatch_async(self.serialQueue, ^{
        task();
    });
}

- (void)pushTaskToParallelQueue:(Task)task
{
    dispatch_async(self.parallelQueue, ^{
        task();
    });
}

- (void)pushTaskToSynchronizationSerialQUeue:(Task)task
{
    dispatch_sync(self.serialQueue, ^{
        task();
    });
}

@end
