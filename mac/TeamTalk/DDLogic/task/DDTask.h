/************************************************************
 * @file         DDTask.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       task任务抽象，包括基本task、网络异步task、同步、异步回调等
 ************************************************************/

#import <Foundation/Foundation.h>

@protocol DDTaskProtocol <NSObject>

@required
-(void) execute;

@end

@class DDTask;
@protocol DDTaskDelegate <NSObject>

@optional
-(BOOL) didDDTaskStarted : (DDTask*) task;
-(void) didDDTaskAsyncUICallback:(DDTask*) task;
-(void) didDDTaskCallback : (DDTask*)task;
-(void) didDDTaskFinished :(DDTask*) task;

@end

@interface DDTask : NSObject<DDTaskProtocol>

@property(nonatomic,strong) NSObject<DDTaskDelegate>*  delegate;
-(void) execute;
- (void)uiNotify;

@end
