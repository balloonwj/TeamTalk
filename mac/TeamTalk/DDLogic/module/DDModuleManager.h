/************************************************************
 * @file         DDModuleManager.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       框架服务module管理，整个工程所有的module必须要到这里注册，并且分配一个全局唯一的service id
 ************************************************************/

#import <Foundation/Foundation.h>
#import "NSNotification+DDLogic.h"

static NSString* const USERINFO_DEFAULT_KEY = @"defaultKey";    //NSNotification通知userinfo字典默认key

@interface DDModule : NSObject
{
    NSMutableDictionary*       _observerCaches;
}

@property(nonatomic,readonly) uint16       moduleId;

-(id) initModule:(uint16) moduleId;

-(void) onLoadModule;
-(void) onUnloadModule;

-(void)addObserver:(NSString* const)name observer:(id)observer selector:(SEL)aSelector;
-(void)uiAsyncNotify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
-(void)uiSyncNotify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
-(void)notify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;

@end

@interface DDTcpModule : DDModule

-(void)onHandleTcpData:(uint16)cmdId data:(id)data;

@end

@class DDModuleDataManager;
@interface DDModuleManager : NSObject
{
    NSMutableArray*             _moduleArray;
    DDModuleDataManager*        _moduleDataManager;
}

-(id)init;
-(BOOL) startup;
-(void) shutdown;

-(BOOL) registerModule:(DDModule*) module;
-(BOOL) unRegisterModule:(DDModule*) module;
-(DDModule*) queryModuleByID:(uint16) moduleId;
-(BOOL)archive;


-(void)addObserver:(uint16)moduleId name:(NSString* const)name observer:(id)observer selector:(SEL)aSelector;
-(void)uiAsyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
-(void)uisyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;
-(void)notify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo;

@end
