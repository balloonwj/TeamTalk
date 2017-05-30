//
//  MTUnreadMessageManager.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTUnreadMessageManager.h"

@implementation MTUnreadMessageManager
{
    NSMutableDictionary* _unreadMessageCountDic;
    NSString *_lastSessionId;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _unreadMessageCountDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setUnreadMessageCounnt:(NSUInteger)count forSessionID:(NSString*)sessionID
{
    [_unreadMessageCountDic setObject:@(count) forKey:sessionID];
     _lastSessionId = sessionID;
}

- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID
{
    return [_unreadMessageCountDic[sessionID] integerValue];
}

- (NSUInteger)getUnreadMessageCount
{
    __block NSUInteger count = 0;
    [_unreadMessageCountDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        count += [obj integerValue];
    }];
    return count;
}

- (void)clearUnreadMesageCountForSessionID:(NSString*)sessionID
{
    [_unreadMessageCountDic removeObjectForKey:sessionID];
}

- (void)clearAllUnreadMessageCount
{
    [_unreadMessageCountDic removeAllObjects];
}

- (void)addUnreadMesageCountForSessionID:(NSString*)sessionID
{
    NSUInteger count = [self getUnreadMessageCountForSessionID:sessionID];
    [self setUnreadMessageCounnt:(count + 1) forSessionID:sessionID];
}
-(NSString *)getLastUnreadSessionId{
    NSString *_lastSID = _lastSessionId;
    
    [_unreadMessageCountDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj integerValue]>0 && ![key isEqualToString:_lastSessionId]) {
            _lastSessionId=key;
        }
    }];
    return _lastSID;
}


@end
