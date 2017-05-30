//
//  DDSundriesCenter.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-23.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Task)();

@interface DDSundriesCenter : NSObject

@property (nonatomic,readonly)dispatch_queue_t serialQueue;
@property (nonatomic,readonly)dispatch_queue_t parallelQueue;

+ (instancetype)instance;
- (void)pushTaskToSerialQueue:(Task)task;
- (void)pushTaskToParallelQueue:(Task)task;
- (void)pushTaskToSynchronizationSerialQUeue:(Task)task;
@end
