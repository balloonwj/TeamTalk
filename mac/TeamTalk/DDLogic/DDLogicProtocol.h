/************************************************************
 * @file         DDLogicProtocol.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       逻辑框架接口定义：事件通知、监听数据变更、逻辑任务执行、服务注册等接口
 ************************************************************/

#import <Foundation/Foundation.h>
#import "DDModuleManager.h"
#import "DDTask.h"
#import "DDTaskOperation.h"

#pragma -mark 模块相关
@protocol DDModuleProtocol <NSObject>

@required
//注册模块
-(BOOL) registerModule:(DDModule*) module;
//反注册模块
-(BOOL) unRegisterModule:(DDModule*) module;
//通过module id查找模块
-(DDModule*) queryModuleByID:(uint16) moduleId;

//监听数据相关
-(void)addObserver:(uint16)moduleId name:(NSString* const)name observer:(id)observer selector:(SEL)aSelector;
//异步通知到主线程
-(void)uiAsyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
//同步通知到主线程 (注：尽量少用这个，因为主线程会把逻辑线程给阻塞住，切记)
-(void)uisyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
//同步通知到当前线程
-(void)notify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;

@end

#pragma -mark 逻辑执行器
@protocol DDWorkerProtocol <NSObject>

@required
//将一个任务FIFO推入任务执行器
-(BOOL) pushTask:(id<DDTaskProtocol>)task delegate:(id<DDTaskDelegate>) delegate;
-(BOOL) pushTaskWithBlock:(TaskBlock)taskBlock;
//未实现
-(BOOL) pushTaskWithTarget:(id)target selector:(SEL)sel;

@end


@protocol DDLogicProtocol <DDModuleProtocol,DDWorkerProtocol>

@required
-(BOOL) startup;
-(void) shutdown;

@end