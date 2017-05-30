/************************************************************
 * @file         DDModuleManager.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       框架服务module管理，整个工程所有的module必须要到这里注册，并且分配一个全局唯一的service id
 ************************************************************/

#import "DDModuleManager.h"
#import "DDModuleDataManager.h"

@implementation DDTcpModule

-(void)onHandleTcpData:(uint16)cmdId data:(id)data
{
}

@end

@interface DDModule()

-(void)cacheObserver:(NSString*)name observer:(id)observer;

@end

@implementation DDModule

-(id) initModule:(uint16) moduleId
{
    if(self = [super init])
    {
        _moduleId = moduleId;
        _observerCaches = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) onLoadModule
{
    
}

-(void) onUnloadModule
{
    for(NSString* name in _observerCaches)
    {
        NSArray* sameNameObservers = [_observerCaches objectForKey:name];
        for (id observer in sameNameObservers)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
        }
    }
}

-(void)cacheObserver:(NSString*)name observer:(id)observer
{
    NSMutableArray* sameNameObservers = [_observerCaches objectForKey:name];
    if(!sameNameObservers)
    {
        sameNameObservers = [[NSMutableArray alloc] init];
    }
    if(![sameNameObservers containsObject:observer])
    {
        [sameNameObservers addObject:observer];
    }
    [_observerCaches setValue:sameNameObservers forKey:name];
}

-(void)addObserver:(NSString* const)name observer:(id)observer selector:(SEL)aSelector
{
    //trick 为了在多次add同一个observer的时候，不多次调用
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:name object:nil];
    [self cacheObserver:name observer:observer];
}

-(void)uiAsyncNotify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    NSNotification* notification = [NSNotification notificationWithName:name object:self userInfo:userInfo];
    NSString* uid = [userInfo objectForKey:USERINFO_SID];
    if(uid)
    {
        [notification setSessionId:uid];
    }
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)withObject:notification waitUntilDone:NO];
}

-(void)uiSyncNotify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    NSNotification* notification = [NSNotification notificationWithName:name object:self userInfo:userInfo];
    NSString* uid = [userInfo objectForKey:USERINFO_SID];
    if(uid)
    {
        [notification setSessionId:uid];
    }
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)withObject:notification waitUntilDone:YES];
}

-(void)notify:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
//    [userInfo setObject:@"aaa" forKey:USERINFO_SID];
    NSNotification* notification = [NSNotification notificationWithName:name object:self userInfo:userInfo];
    NSString* uid = [userInfo objectForKey:USERINFO_SID];
    if(uid)
    {
        [notification setSessionId:uid];
    }
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:notification withObject:notification];
}

@end

@interface DDModuleManager()
-(void)unRegisterAllModules;
@end

@implementation DDModuleManager

-(id)init
{
    if(self = [super init])
    {
        _moduleArray = [NSMutableArray array];
        _moduleDataManager = [[DDModuleDataManager alloc] initModuleData:_moduleArray];
    }
    return self;
}

-(BOOL) registerModule:(DDModule*) module
{
    //todo... 去重
    [_moduleArray addObject:module];
    
    [module onLoadModule];
    
    return YES;
}
-(BOOL) unRegisterModule:(DDModule*) module
{
    [module onUnloadModule];
    
    [_moduleArray removeObject:module];
    
    return YES;
}

-(void)addObserver:(uint16)moduleId name:(NSString* const)name observer:(id)observer selector:(SEL)aSelector
{
    DDModule* module = [self queryModuleByID:moduleId];
    [module addObserver:name observer:observer selector:aSelector];
}

-(void)uiAsyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    DDModule* module = [self queryModuleByID:moduleId];
    [module uiAsyncNotify:name userInfo:userInfo];
}

-(void)uisyncNotify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    DDModule* module = [self queryModuleByID:moduleId];
    [module uiAsyncNotify:name userInfo:userInfo];
}

-(void)notify:(uint16)moduleId name:(NSString* const)name userInfo:(NSMutableDictionary*)userInfo
{
    DDModule* module = [self queryModuleByID:moduleId];
    [module notify:name userInfo:userInfo];
}

-(DDModule*) queryModuleByID:(uint16) moduleId
{
    for(DDModule* module in _moduleArray)
    {
        if(module.moduleId == moduleId)
            return module;
    }
    
    return nil;
}

-(BOOL)archive
{
    return [_moduleDataManager archive];
}

-(BOOL) startup
{
    return [_moduleDataManager unArchive];
}

-(void) shutdown
{
    [_moduleDataManager archive];
    
    [self unRegisterAllModules];
}

-(void)unRegisterAllModules
{
    for(DDModule* module in _moduleArray)
    {
        [module onUnloadModule];
    }
}

@end
