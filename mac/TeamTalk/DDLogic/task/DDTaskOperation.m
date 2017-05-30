/************************************************************
 * @file         DDTaskOperation.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       通过NSOperation包装task，用于执行后台一些短暂的计算性任务
 ************************************************************/

#import "DDTask.h"
#import "DDTaskOperation.h"

@implementation DDTaskOperation

-(void) main
{
    if([self isCancelled])
        return;
    if([_delegate respondsToSelector:@selector(didDDTaskStarted:)])
    {
       if(![_delegate didDDTaskStarted:_ddTask])
           return;
    }
    if(_ddTask)
        [_ddTask execute];
    else
        _block();
    if([self isCancelled])
        return;
    if([_delegate respondsToSelector:@selector(didDDTaskFinished:)])
    {
        [_delegate didDDTaskFinished:_ddTask];
    }
}

-(id) initWithBlock:(TaskBlock)taskBlock
{
    if(self = [super init])
    {
        _block = taskBlock;
    }
    return self;
}

-(id) initWithDDTask:(id<DDTaskProtocol>) task delegate : (id<DDTaskDelegate>)delegate
{
    if(self = [super init])
    {
        _ddTask = task;
        if([_ddTask isKindOfClass:[DDTask class]])
        {
            DDTask* task = (DDTask*) _ddTask;
            task.delegate = delegate;
        }
        _delegate = delegate ;
    }
    
    return self;
}

@end

@implementation DDTask

-(void) execute
{
}

- (void)uiNotify
{
    if([_delegate respondsToSelector:@selector(didDDTaskAsyncUICallback:)])
    {
        [_delegate performSelectorOnMainThread:@selector(didDDTaskAsyncUICallback:) withObject:self waitUntilDone:NO];
    }
}
@end
