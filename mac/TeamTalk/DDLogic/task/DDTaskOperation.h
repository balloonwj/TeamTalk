/************************************************************
 * @file         DDTaskOperation.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       通过NSOperation包装task，用于执行后台一些短暂的计算性任务
 ************************************************************/

#import <Foundation/Foundation.h>

@protocol DDTaskProtocol;
@protocol DDTaskDelegate;

typedef void(^TaskBlock)();

@interface DDTaskOperation : NSOperation
{
@private
    id<DDTaskProtocol>      _ddTask;
    id<DDTaskDelegate>      _delegate;
    TaskBlock               _block;
}

-(id) initWithDDTask:(id<DDTaskProtocol>) task delegate : (id<DDTaskDelegate>)delegate;
-(id) initWithBlock:(TaskBlock)taskBlock;

@end