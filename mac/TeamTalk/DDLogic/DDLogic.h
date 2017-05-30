/************************************************************
 * @file         DDLogic.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       逻辑框架接口实现：事件通知、业务数据本地序列化反序列化、逻辑任务执行、模块注册等接口
 ************************************************************/

#import <Foundation/Foundation.h>
#import "DDLogicProtocol.h"
#import "DDModuleID.h"
#import "DDModuleManager.h"
#import "DDTaskManager.h"

@interface DDLogic : NSObject<DDLogicProtocol>
{
    DDModuleManager*            _moduleManger;
    DDTaskManager*              _taskManager;
}

#pragma -mark 模块相关
-(BOOL) registerModule:(DDModule*) module;
-(BOOL) unRegisterModule:(DDModule*) module;
-(DDModule*) queryModuleByID:(uint16) moduleId;
//将module业务数据序列化到本地
-(BOOL) archive;

#pragma -mark 监听数据相关
-(void)addObserver:(uint16)moduleId name:(NSString* const)name observer:(id)observer selector:(SEL)aSelector;
//异步通知到主线程
-(void)uiAsyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
//同步通知到主线程 (注：尽量避免使用这个，因为主线程会把逻辑线程给阻塞住，切记)
-(void)uisyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
//同步通知到当前线程
-(void)notify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;

#pragma -mark 逻辑执行器
-(BOOL) pushTaskWithBlock:(TaskBlock)taskBlock;
-(BOOL) pushTask:(id<DDTaskProtocol>)task delegate:(id<DDTaskDelegate>) delegate;
//未实现
-(BOOL) pushTaskWithTarget:(id)target selector:(SEL)sel;

#pragma -mark 网络
//-(void)sendPackedData:(NSMutableData *)data;

#pragma -mark 初始化
-(BOOL) startup;
-(void) shutdown;
-(id)init;
+(DDLogic*) instance;

@end
