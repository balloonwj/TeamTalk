/************************************************************
 * @file         DDWtach.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       watch实现监听service中tag的变化，通知给观察者s（废弃这块的封装,等到要做Core data的时候再来考虑）
 ************************************************************/

#import <Foundation/Foundation.h>

@protocol WatchHandle <NSObject>

@required
-(void)OnWatchHandle:(uint32)tagID;

@end

@interface DDWatch : NSObject
{
    NSString*                               _notifiName;
    NSMutableArray*                         _observerArray;
    id<WatchHandle>                         _delegate;
}

-(void)addWatch:(id<WatchHandle>)observer selector:(SEL)aSelector;
-(void)uiNotify:(uint32)tagID;

-(id) initWatch:(NSString*)nitifiName;

@end

