/**
 * For copyright & license, see LICENSE.
 */

#import "L4AppenderAttachable.h"

NSString * const kL4AppenderAddedEvent   = @"kL4AppenderAddedEvent";
NSString * const kL4AppenderRemovedEvent = @"kL4AppenderRemovedEvent";

@implementation L4AppenderAttachable {
    NSMutableArray  * _appenderList; /**< The collection of log appenders.*/
}

- (NSUInteger)appendLoopOnAppenders:(L4LogEvent *)event
{
    @synchronized(self) {
        for (id <L4Appender> appender in _appenderList)
            [appender doAppend:event];
    }
    return _appenderList.count;
}

#pragma mark Appender Attachable Methods protocol methods

- (void)addAppender:(id <L4Appender>)appender
{
    if (!appender) // sanity check
        return;
    
    @synchronized(self) {
        if (!_appenderList) {
            // only place appenderList array is recreated if its nil.
            _appenderList = [NSMutableArray arrayWithObject:appender];
            return;
        }
        
        if(![_appenderList containsObject:appender]) {
            [_appenderList addObject:appender];
            [[NSNotificationCenter defaultCenter] postNotificationName:kL4AppenderAddedEvent object:appender];
        }
    }
}

- (NSArray *)allAppenders
{
    return _appenderList;
}

- (id <L4Appender>)appenderWithName:(NSString *)name
{
    return [_appenderList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]].lastObject;
}

- (BOOL)isAttached:(id <L4Appender>)appender
{
    if (!appender || !_appenderList)
        return NO; // short circuit the test
    
    return [_appenderList containsObject:appender]; 
}

- (void) removeAppenderWithName:(NSString *)name
{
    [self removeAppender:[self appenderWithName:name]];
}

- (void) removeAppender:(id <L4Appender>) appender
{
    [_appenderList removeObject:appender];
    [[NSNotificationCenter defaultCenter] postNotificationName:kL4AppenderRemovedEvent object:appender];
}

- (void) removeAllAppenders
{
    @synchronized(self) {
        for (id <L4Appender> appender in _appenderList) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kL4AppenderRemovedEvent object:appender];
        }
        [_appenderList removeAllObjects];
        _appenderList = nil;
    }
}

@end
