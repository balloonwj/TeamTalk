/************************************************************
 * @file         DDTaskService.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       后台逻辑线程task机制封装，执行一些短时间的短暂的后台计算性任务
 ************************************************************/

#import <Foundation/Foundation.h>

#import "DDTaskOperation.h"

@interface DDTaskManager : NSObject
{
@private
    NSOperationQueue* _queue;
    NSOperation* _lastOperation;
}

-(BOOL) pushTask:(id<DDTaskProtocol>)task delegate:(id<DDTaskDelegate>) delegate;
//todo task with block、target action
-(BOOL) pushTaskWithBlock:(TaskBlock)taskBlock;
-(BOOL) pushTaskWithTarget:(id)target selector:(SEL)sel;
-(void) shutdown;

@end
