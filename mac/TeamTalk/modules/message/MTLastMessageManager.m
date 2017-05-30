//
//  MTLastMessageManager.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTLastMessageManager.h"
#import "MTDatabaseUtil.h"
#import "MTMessageEntity.h"
#define MESSAGE_CONTENT_KEY                 @"MessageContent"
#define MESSAGE_ID_KEY                      @"MessageID"

@interface MTLastMessageManager(privateAPI)


@end

@implementation MTLastMessageManager
{
    NSMutableDictionary* _lastMessageDic;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)initialLastMessageData
{
    _lastMessageDic = [[NSMutableDictionary alloc] init];
    NSDictionary* lastMessageData = [[MTDatabaseUtil instance] getLastestMessage];
    [lastMessageData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MTMessageEntity* message = (MTMessageEntity*)obj;
        NSDictionary* toSaveDic = @{MESSAGE_ID_KEY : @(message.messageServerID),
                                    MESSAGE_CONTENT_KEY : message.messageContent};
        [_lastMessageDic setObject:toSaveDic forKey:message.sessionID];
    }];
}

- (void)setLastMessage:(NSString*)messageContent messageID:(NSUInteger)messageID forSessionID:(NSString*)sessionID
{
    
    if (!messageContent) {
        messageContent = [NSString stringWithFormat:@""];
    }
    NSDictionary* toSaveDic = @{MESSAGE_ID_KEY : @(messageID),
                                MESSAGE_CONTENT_KEY : messageContent};
    [_lastMessageDic setObject:toSaveDic forKey:sessionID];
}

- (NSString*)lastMessageContentForSessionID:(NSString*)sessionID
{
    NSDictionary* lastMessageDic = _lastMessageDic[sessionID];
    if (lastMessageDic)
    {
        return lastMessageDic[MESSAGE_CONTENT_KEY];
    }
    return nil;
}

- (NSUInteger)lastMessageIDForSessionID:(NSString*)sessionID
{
    NSDictionary* lastMessageDic = _lastMessageDic[sessionID];
    if (lastMessageDic)
    {
        return [lastMessageDic[MESSAGE_ID_KEY] integerValue];
    }
    return 0;
}

- (BOOL)sessionExistForSessionID:(NSString*)sessionID
{
    return [[_lastMessageDic allKeys] containsObject:sessionID];
}

#pragma mark -
#pragma mark PrivateAPI
@end
