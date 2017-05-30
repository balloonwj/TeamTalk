/************************************************************
 * @file         DDTaskService.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       后台逻辑线程task机制封装，能跑一些短时间的短暂的后台计算性任务
 ************************************************************/

#import "DDTaskManager.h"
#import "DDTaskOperation.h"

@implementation DDTaskManager

-(id) init
{
    if(self = [super init])
    {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

-(BOOL) pushTaskWithBlock:(TaskBlock)taskBlock
{
    @synchronized(self)
    {
        DDTaskOperation* operation = [[DDTaskOperation alloc] initWithBlock:taskBlock];
        if(!operation)
            return NO;
        [_queue addOperation:operation];
        //保证FIFO
        [_lastOperation addDependency:operation];
        _lastOperation = operation;
    }
    
    return YES;
}

-(BOOL) pushTask:(id<DDTaskProtocol>)task delegate:(id<DDTaskDelegate>) delegate;
{
    @synchronized(self)
    {
        DDTaskOperation* operation = [[DDTaskOperation alloc] initWithDDTask:task delegate:delegate];
        if(!operation)
            return NO;
        [_queue addOperation:operation];
        //保证FIFO
        [_lastOperation addDependency:operation];
        _lastOperation = operation;
    }

    return YES;
}

-(BOOL) pushTaskWithTarget:(id)target selector:(SEL)sel
{
    @synchronized(self)
    {
        
    }
    
    return YES;
}

-(void) shutdown
{
    [_queue cancelAllOperations];
}

@end
