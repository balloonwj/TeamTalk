//
//  DDChattingWindowManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-26.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingWindowManager.h"

static NSInteger const maintanceTimeInterval = 5;
static NSInteger const removeTimeInterval = 60 * 60 * 2;

@interface DDChattingWindowManager(PrivateAPI)

- (void)p_updateChatmaintainDic;
- (void)p_chectChatWindowExistTime:(NSTimer*)timer;

@end

@implementation DDChattingWindowManager
{
    NSMutableDictionary* _maintanceDic;
    NSMutableDictionary* _chatWindowDic;
    NSString* _chattingSessionID;
    
    NSTimer* _maintanceTimer;
}


+ (instancetype)instance
{
    static DDChattingWindowManager* g_chattingWindowManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_chattingWindowManager = [[DDChattingWindowManager alloc] init];
    });
    return g_chattingWindowManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _maintanceDic = [[NSMutableDictionary alloc] init];
        _chatWindowDic = [[NSMutableDictionary alloc] init];
        _maintanceTimer = [NSTimer scheduledTimerWithTimeInterval:maintanceTimeInterval target:self selector:@selector(p_chectChatWindowExistTime:) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - publicAPI
- (void)addChattingWindow:(DDChattingViewController*)chattingVC forSessionID:(NSString*)sessionID
{
    [_chatWindowDic setObject:chattingVC forKey:sessionID];
}


- (DDChattingViewController*)openChattingWindowForSessionID:(NSString*)sessionID
{
    if ([[_chatWindowDic allKeys] containsObject:sessionID])
    {
        _chattingSessionID = [sessionID copy];
        [self p_updateChatmaintainDic];
        return _chatWindowDic[sessionID];
    }
    else
    {
        return nil;
    }
}

- (void)removeChattingWindowForSessionID:(NSString*)sessionID
{
    [_chatWindowDic removeObjectForKey:sessionID];
}

#pragma mark - privateAPI
//更新需要维护的聊天界面字典
- (void)p_updateChatmaintainDic
{
    [_maintanceDic removeObjectForKey:_chattingSessionID];
    
    [_chatWindowDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isEqualToString:_chattingSessionID] && ![[_maintanceDic allKeys] containsObject:key]) {
            [_maintanceDic setObject:[NSDate date] forKey:key];
        }
    }];
}

//移除超时的聊天界面，减少占用内存
- (void)p_chectChatWindowExistTime:(NSTimer *)timer
{
    NSMutableArray* removeSessionIDs = [NSMutableArray array];
    [_maintanceDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDate* lastCloseTime = (NSDate*)obj;
        NSUInteger timeInterval = [[NSDate date] timeIntervalSinceDate:lastCloseTime];
        if (timeInterval >= removeTimeInterval)
        {
            [removeSessionIDs addObject:key];
            [_chatWindowDic removeObjectForKey:key];
        }
    }];
    
    [removeSessionIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_maintanceDic removeObjectForKey:obj];
    }];
}
@end
