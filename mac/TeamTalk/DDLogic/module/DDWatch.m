/************************************************************
 * @file         DDWtach.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       watch实现监听service中tag的变化，通知给观察者s（废弃这块的封装,等到要做Core data的时候再来考虑）
 ************************************************************/

#import "DDWatch.h"
@interface DDWatch()

-(void)onWatchNotify:(NSNotification*)notification;

@end

@implementation DDWatch

-(void)onWatchNotify:(NSNotification*)notification
{
    [_delegate OnWatchHandle:2];
}

-(void)addWatch:(id<WatchHandle>)observer selector:(SEL)aSelector
{
    //todo 去重
    [_observerArray addObject:observer];
    
    _delegate = observer;
}

-(void)uiNotify:(uint32)tagID
{
    [[NSNotificationCenter defaultCenter] postNotificationName:_notifiName object:self];
}

-(id) initWatch:(NSString*)nitifiName
{
    if(self = [super init])
    {
        _notifiName = nitifiName;
        _observerArray = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWatchNotify:) name:_notifiName object:self];
    }
    return self;
}

@end
