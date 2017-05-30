/************************************************************
 * @file         DDLogic.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       逻辑框架接口实现：事件通知、业务数据本地序列化反序列化、逻辑任务执行、模块注册等接口
 ************************************************************/

#import "DDLogic.h"

@implementation DDLogic

#pragma -mark 初始化
+(DDLogic*) instance
{
    static DDLogic* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}
-(id)init
{
    if(self = [super init])
    {
        _moduleManger = [[DDModuleManager alloc] init];
        _taskManager = [[DDTaskManager alloc] init];
    }
    
    return self;
}

-(BOOL) startup
{
    [_moduleManger startup];
    
    return  YES;
}
-(void) shutdown
{
    [_taskManager shutdown];
    
    [_moduleManger shutdown];
}

#pragma -mark 模块相关
-(BOOL) registerModule:(DDModule*)  module
{
    return [_moduleManger registerModule:module];
}
-(BOOL) unRegisterModule:(DDModule*) module
{
    return [_moduleManger unRegisterModule:module];
}
-(BOOL) archive
{
    return [_moduleManger archive];
}
-(DDModule*) queryModuleByID:(uint16) moduleId
{
    return [_moduleManger queryModuleByID:moduleId];
}

#pragma -mark 监听数据相关
-(void)addObserver:(uint16)moduleId name:(NSString *const)name observer:(id)observer selector:(SEL)aSelector
{
    [_moduleManger addObserver:moduleId name:name observer:observer selector:aSelector];
}

-(void)uiAsyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    [_moduleManger uiAsyncNotify:moduleId name:name userInfo:userInfo];
}

-(void)uisyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    [_moduleManger uiAsyncNotify:moduleId name:name userInfo:userInfo];
}

-(void)notify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    [_moduleManger notify:moduleId name:name userInfo:userInfo];
}

#pragma -mark 逻辑执行器
-(BOOL) pushTask:(id<DDTaskProtocol>)task delegate:(id<DDTaskDelegate>) delegate
{
    return [_taskManager pushTask:task delegate:delegate];
}

-(BOOL) pushTaskWithBlock:(TaskBlock)taskBlock
{
    return [_taskManager pushTaskWithBlock:taskBlock];
}

-(BOOL) pushTaskWithTarget:(id)target selector:(SEL)sel
{
    return NO;
}

#pragma -mark 网络
//-(void)sendPackedData:(NSMutableData *)data
//{
//    DDTcpLinkModule* moduleTcpLink = getDDTcpLinkModule();
//    [moduleTcpLink sendPackedData:data];
//}

@end
