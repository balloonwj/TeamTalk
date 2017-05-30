//
//  MTMessageModule.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTMessageModule.h"
#import "MTLastMessageManager.h"
#import "MTUnreadMessageManager.h"
#import "DDMessageSendManager.h"
#import "MTSessionModule.h"
#import "DDReceiveMessageAPI.h"
#import "DDReceiveP2PMessageAPI.h"
#import "MessageEntity.h"
#import "DDSendP2PCmdAPI.h"
#import "DDHistoryMessageAPI.h"
#import "DDUnreadMessageAPI.h"
#import "MTMessageEntity.h"
#import "MTDatabaseUtil.h"
#import "DDIntranetMessageEntity.h"
#import "DDMsgReadACKAPI.h"
#import "MTUserModule.h"
#import "MTGroupModule.h"
#import "MTDraftManager.h"
#import "MTInputHistoryManager.h"
#import "DDReceiveMsgDataReadNotifyAPI.h"
#import "DDSetting.h"
#import "DDGetLastMessageIDAPI.h"
static NSUInteger messageID = 0;

typedef void(^MTSaveUnreadMessageCompletion)(MTSessionEntity* session,MTMessageEntity* message);
typedef void(^MTHandleReceiveMessage)();
typedef void(^MTGetHistoryMessages)(NSUInteger messageID);
typedef void(^MTCheckoutMessageSendrInfoCompletion)();

@interface MTMessageModule(PrivateAPI)

- (void)p_loadLocalLastMessage;
- (void)p_loadUnreadMessages;
- (void)p_registAPI;
- (BOOL)p_checkMessageIntegrity:(NSArray*)messages fromMessageID:(NSUInteger)msgID count:(NSUInteger)count;
- (void)p_updateUnreadMessageCount;
- (void)p_saveUnreadMesage:(MTMessageEntity*)message completion:(MTSaveUnreadMessageCompletion)completion;
- (void)p_addUnreadMessage:(MTMessageEntity*)message;
- (void)p_finishSaveUnreadMessage:(MTSessionEntity*)message;
- (void)p_checkoutMessageSenderInfo:(NSArray*)messages completion:(MTCheckoutMessageSendrInfoCompletion)completion;
@end

@implementation MTMessageModule
{
    MTLastMessageManager* _lastMesssageManager;
    MTUnreadMessageManager* _unreadMessageManager;
    DDMessageSendManager* _messageSendManager;
    NSUInteger _unreadMessageCount;
    MTDraftManager* _draftManager;
    MTInputHistoryManager* _inputHistoryManager;
}
+ (instancetype)shareInstance
{
    static MTMessageModule* g_messageModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageModule = [[MTMessageModule alloc] init];
    });
    return g_messageModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _lastMesssageManager = [[MTLastMessageManager alloc] init];
        _unreadMessageManager = [[MTUnreadMessageManager alloc] init];
        _messageSendManager = [[DDMessageSendManager alloc] init];
        _draftManager = [[MTDraftManager alloc] init];
        _inputHistoryManager = [[MTInputHistoryManager alloc] init];
        [self registObserveDataReadyState];
        [self p_registAPI];
    }
    return self;
}

+ (NSUInteger)getMessageID
{
    return ++messageID;
}

- (NSString*)getLastMessageContentForSessionID:(NSString *)sessionID
{
    return [_lastMesssageManager lastMessageContentForSessionID:sessionID];
}

- (NSUInteger)getLastMessageIDForSessionID:(NSString *)sessionID
{
    return [_lastMesssageManager lastMessageIDForSessionID:sessionID];
}

- (BOOL)lastestMessageIDExistInDataForSessionID:(NSString*)sessionID
{
    return [_lastMesssageManager sessionExistForSessionID:sessionID];
}

- (void)setLasteMessageContent:(NSString*)messageContent messsageID:(NSUInteger)messageID forSessionID:(NSString*)sessionID
{
    [_lastMesssageManager setLastMessage:messageContent messageID:messageID forSessionID:sessionID];
}

- (void)clearUnreadMessagesForSessionID:(NSString*)sessionID
{
    [_unreadMessageManager clearUnreadMesageCountForSessionID:sessionID];
    [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:sessionID];
    [self p_updateUnreadMessageCount];
}

- (NSUInteger)getUnreadMessgeCount
{
    return [_unreadMessageManager getUnreadMessageCount];
}

- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID
{
    return [_unreadMessageManager getUnreadMessageCountForSessionID:sessionID];
}

- (MTMessageEntity*)sendMessage:(NSAttributedString*)message forSession:(NSString*)sessionID completion:(SendMessageCompletion)completion
{
    MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
    MTMessageEntity* messageEntity = [_messageSendManager sendMessage:message forSession:sessionEntity success:^(MTMessageEntity *message) {
        message.sendState = MessageSendSuccess;
        [_lastMesssageManager setLastMessage:@"asdasdad" messageID:message.messageServerID forSessionID:message.sessionID];
        [[MTDatabaseUtil instance] insertMessages:@[message]];
        completion(message,nil);
    } failure:^(MTMessageEntity *message, NSError *error) {
        message.sendState = MessageSendFailure;
        completion(message,error);
    }];
//    [[MTDatabaseUtil instance] insertMessages:@[messageEntity]];
    return messageEntity;
}

- (void)getHistoryMessage:(NSString* )sessionID fromMessageID:(NSInteger)messageID count:(NSInteger)count Completion:(GetHistoryMessageCompletion)completion
{
    MTGetHistoryMessages getHistoryMessages = ^(NSUInteger lastMessageID){
        NSArray* localMessage = [[MTDatabaseUtil instance] queryMessageForSessionID:sessionID messageID:lastMessageID messageCount:count];
        if (![self p_checkMessageIntegrity:localMessage fromMessageID:lastMessageID count:count])
        {
            //通过网络去拉取
            DDHistoryMessageAPI* historyMessageAPI = [[DDHistoryMessageAPI alloc] init];
            NSUInteger userID = [[DDClientState shareInstance].userID intValue];
            MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
            NSUInteger originID = [sessionEntity.originID intValue];
            NSArray* object = @[@(userID),@(sessionEntity.sessionType),@(originID),@(lastMessageID),@(20)];
            [historyMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
                if (!error)
                {
                    //保存到本地
                    [[MTDatabaseUtil instance] insertMessages:response];
                    //完成
                    [self p_checkoutMessageSenderInfo:response completion:^{
                        completion(response);
                    }];
                }
                else
                {
                    [self p_checkoutMessageSenderInfo:localMessage completion:^{
                        completion(localMessage);
                    }];
                }
            }];
        }
        else
        {
            //本地消息可用
            [self p_checkoutMessageSenderInfo:localMessage completion:^{
                completion(localMessage);
            }];
        }
        
    };
    
    if (messageID == 0 && ![self lastestMessageIDExistInDataForSessionID:sessionID])
    {
        MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
        DDGetLastMessageIDAPI* getLastMessageIDAPI = [[DDGetLastMessageIDAPI alloc] init];
        [getLastMessageIDAPI requestWithObject:@[@(sessionEntity.sessionType),sessionEntity.originID] Completion:^(id response, NSError *error) {
            if (!error)
            {
                [_lastMesssageManager setLastMessage:@"xx00" messageID:[response intValue] forSessionID:sessionEntity.sessionID];
                getHistoryMessages([response intValue]);
            }
            else
            {
                getHistoryMessages(0);
            }
        }];
    }
    else
    {
        getHistoryMessages(messageID);
    }
}

#pragma mark -
#pragma mark Draft
- (NSAttributedString*)getDraftForSessionID:(NSString*)sessionID
{
    return [_draftManager getDraftForSessionID:sessionID];
}

- (void)setDraft:(NSAttributedString*)draft forSessionID:(NSString*)sessionID
{
    [_draftManager setDraft:draft forSessionID:sessionID];
}

#pragma -
#pragma mark - Input History
- (void)addInputHistory:(NSAttributedString*)historyText forSessionID:(NSString*)sessionID
{
    [_inputHistoryManager addInputHistory:historyText forSessionID:sessionID];
}

- (NSAttributedString*)getInputHistoryForSessionID:(NSString *)sessionID forIndex:(NSUInteger)index
{
    return [_inputHistoryManager getInputHistoryForSessionID:sessionID forIndex:index];
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_DATA_STATE_KEYPATH])
    {
        DDDataState oldDataState = [change[@"old"] intValue];
        DDDataState newDataState = [change[@"new"] intValue];
        if (!(oldDataState & DDLocalSessionDataReady) &&
            (newDataState & DDLocalSessionDataReady)) {
            [self p_loadLocalLastMessage];
        }
        else if (!(oldDataState & DDRemoteSessionDataReady) &&
            (newDataState & DDRemoteSessionDataReady))
        {
            //session 远程数据加载完成
            [self p_loadUnreadMessages];
        }
    }
}

#pragma mark -
#pragma mark PrivateAPI
- (void)p_loadLocalLastMessage
{
    [_lastMesssageManager initialLastMessageData];
}

- (void)p_loadUnreadMessages
{
    [_unreadMessageManager clearAllUnreadMessageCount];
    DDUnreadMessageAPI* getUnreadMessageAPI = [[DDUnreadMessageAPI alloc] init];
    NSUInteger userID = [[DDClientState shareInstance].userID intValue];
    
    
    //更新消息计数的block
    void (^MTUpdateUnreadMessageCount)() = ^{
        [self p_updateUnreadMessageCount];
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
    };
    
    [getUnreadMessageAPI requestWithObject:@(userID) Completion:^(id response, NSError *error) {
        if (!error)
        {
            NSDictionary* unreadMessageCount = (NSDictionary*)response;
            [unreadMessageCount enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([[[DDSetting instance] getShieldSessionIDs] containsObject:key])
                {
                    [[MTSessionModule shareInstance] sendSessionReadACK:key];
                }
                else
                {
                    MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] getSessionBySessionID:key];
                    if (!sessionEntity)
                    {
                        SessionType sessionType = [MTSessionEntity getSessionTypeFromSessionID:key];
                        if (sessionType == SessionTypeSessionTypeSingle)
                        {
                            MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:key];
                            MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] addSessionFromOriginEntity:user saveToDB:YES];
                            [_unreadMessageManager setUnreadMessageCounnt:[obj intValue] forSessionID:sessionEntity.sessionID];
                            
                        }
                        else if (sessionType == SessionTypeSessionTypeGroup)
                        {
                            NSString* groupID = [MTSessionEntity getOriginIDFromSessionID:key];
                            MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
                            
                            if (group)
                            {
                                MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] addSessionFromOriginEntity:group saveToDB:YES];
                                [_unreadMessageManager setUnreadMessageCounnt:[obj intValue] forSessionID:sessionEntity.sessionID];

                            }
                            else
                            {
                                NSString* groupID = [MTSessionEntity getOriginIDFromSessionID:key];
                                [[MTGroupModule shareInsatnce] getOriginEntityWithOriginIDsFromRemoteCompletion:@[groupID] completion:^(NSArray *origins, NSError *error) {
                                    if (!error && [origins count] > 0)
                                    {
                                        MTSessionEntity* sessionEntity = [[MTSessionModule shareInstance] addSessionFromOriginEntity:origins saveToDB:YES];
                                        [_unreadMessageManager setUnreadMessageCounnt:[obj intValue] forSessionID:sessionEntity.sessionID];
                                        MTUpdateUnreadMessageCount();
                                    }
                                }];
                            }
                        }
                    }
                    else
                    {
                        [_unreadMessageManager setUnreadMessageCounnt:[obj intValue] forSessionID:key];
                    }
                }
            }];
            MTUpdateUnreadMessageCount();
        }
    }];
    
}

-(NSString *)getLastUnreadSessionId{
    return  [_unreadMessageManager getLastUnreadSessionId];
}

- (void)p_registAPI
{
    //收到消息API注册
    DDReceiveMessageAPI* receiveMessageAPI = [[DDReceiveMessageAPI alloc] init];
    [receiveMessageAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        MTMessageEntity* message = (MTMessageEntity*)object;
        
        MTHandleReceiveMessage handleReceiveMessage = ^{
            [self p_saveUnreadMesage:message completion:^(MTSessionEntity *session, MTMessageEntity *message) {
                
                if (![[[DDSetting instance] getShieldSessionIDs] containsObject:message.sessionID])
                {
                    [self p_addUnreadMessage:message];
                }
                else
                {
                    [[MTSessionModule shareInstance] sendSessionReadACK:message.sessionID];
                }
                
                log4Info(@"收到消息sessionID:%@ content:%@",message.sessionID,message.messageContent);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DD_MESSAGE_MODULE_RECEIVE_MESSAGE object:message];
                [self p_finishSaveUnreadMessage:session];
            }];
        };
        
        //判断本地是否有发送者信息，如果没有则从远端获得
        if (![[MTUserModule shareInstance] getOriginEntityWithOriginID:message.senderID])
        {
            [[MTUserModule shareInstance] getOriginEntityWithOriginIDsFromRemoteCompletion:@[message.senderID] completion:^(NSArray *origins, NSError *error) {
                if (!error)
                {
                    handleReceiveMessage();
                }
            }];
        }
        else
        {
            handleReceiveMessage();
        }
    }];
    
    //收到p2p消息API注册
    DDReceiveP2PMessageAPI* receiveP2PMessageAPI = [[DDReceiveP2PMessageAPI alloc] init];
    [receiveP2PMessageAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        NSDictionary* dic = (NSDictionary*)object;
        NSData* contentData = [dic[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
        if (!contentData)
        {
            return;
        }
        NSDictionary* contentDic = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:nil];
        if (!contentDic)
        {
            return;
        }
        NSMutableDictionary* newDic = [[NSMutableDictionary alloc] initWithDictionary:object];
        [newDic setObject:contentDic forKey:@"content"];
        //{\"CmdID\":\"%i\",\"Content\":\"%@\",\"ServiceID\":\"%i\"}
        NSUInteger cmdID = [contentDic[@"cmd_id"] integerValue];
        NSUInteger serviceID = [contentDic[@"service_id"] integerValue];
        
        if (cmdID == SHAKE_WINDOW_COMMAND && serviceID == SHAKE_WINDOW_SERVICEID)
        {
            //收到抖屏
            [NotificationHelp postNotification:notificationReceiveP2PShakeMessage userInfo:nil object:newDic];
            
        }
        else if (cmdID == INPUTING_COMMAND && serviceID == INPUTING_SERVICEID)
        {
            //正在输入
            [NotificationHelp postNotification:notificationReceiveP2PInputingMessage userInfo:nil object:newDic];
        }
        else if (cmdID == STOP_INPUTTING_COMMAND && serviceID == INPUTING_SERVICEID)
        {
            //停止正在输入
            [NotificationHelp postNotification:notificationReceiveP2PStopInputingMessage userInfo:nil object:newDic];
        }
    }];
    
    //收到其他端消息已经读的通知
    DDReceiveMsgDataReadNotifyAPI *msgDataReadN = [[DDReceiveMsgDataReadNotifyAPI alloc] init];
    [msgDataReadN registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
       // NSString *userId = [object objectForKey:@"userId"];
        NSString *originId = [object objectForKey:@"sessionId"];
       // UInt32 msgId = [object objectForKey:@"msgId"];
        SessionType sessionType = [[object objectForKey:@"sessionType"] intValue];
        NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:originId sessionType:sessionType];
    
        [self clearUnreadMessagesForSessionID:sessionID];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:sessionID];
        NSLog(@" ******已经读: %@",sessionID);
    }];
     
}


- (BOOL)p_checkMessageIntegrity:(NSArray*)messages fromMessageID:(NSUInteger)msgID count:(NSUInteger)count
{
    NSUInteger tempMesssage = msgID;
    
    for (NSUInteger index = 0; index < count; index ++)
    {
        if ([messages count] > index)
        {
            MTMessageEntity* message = messages[index];
            NSUInteger messageServerID = message.messageServerID;
            if (tempMesssage != messageServerID)
            {
                return NO;
            }
            tempMesssage --;
        }
        else
        {
            if (msgID - index != 0)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    return YES;
}

- (void)p_updateUnreadMessageCount
{
    NSUInteger unreadMessageCount = [self getUnreadMessgeCount];
    [self setValue:@(unreadMessageCount) forKeyPath:DD_MESSAGE_UNREAD_COUNT_KEY];
}

- (void)p_saveUnreadMesage:(MTMessageEntity*)message completion:(MTSaveUnreadMessageCompletion)completion
{
    NSString* sessionID = [message sessionID];

    NSUInteger messageServerID = [message messageServerID];
    //更新最后一条消息
    [_lastMesssageManager setLastMessage:@"asd" messageID:messageServerID forSessionID:sessionID];
    //添加或者更新session
    MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
    if (session)
    {
        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
        completion(session,message);
    }
    else
    {
        SessionType sessionType = [MTSessionEntity getSessionTypeFromSessionID:sessionID];
        if (sessionType == SessionTypeSessionTypeSingle)
        {
            NSString* userID = [MTSessionEntity getOriginIDFromSessionID:sessionID];
            MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
            if (user)
            {
                MTSessionEntity* session = [[MTSessionModule shareInstance] addSessionFromOriginEntity:user saveToDB:YES];
                [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
                completion(session,message);
            }
            else
            {
                [[MTUserModule shareInstance]getOriginEntityWithOriginIDsFromRemoteCompletion:@[userID] completion:^(NSArray *origins, NSError *error) {
                    if (!error)
                    {
                        MTUserEntity* user = origins[0];
                        MTSessionEntity* session = [[MTSessionModule shareInstance] addSessionFromOriginEntity:user saveToDB:YES];
                        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
                        completion(session,message);
                    }
                }];
            }
        }
        else if(sessionType == SessionTypeSessionTypeGroup)
        {
            NSString* groupID = [MTSessionEntity getOriginIDFromSessionID:sessionID];
            MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
            if (group)
            {
                MTSessionEntity* session = [[MTSessionModule shareInstance] addSessionFromOriginEntity:group saveToDB:YES];
                [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
                completion(session,message);
            }
            else
            {
                [[MTGroupModule shareInsatnce] getOriginEntityWithOriginIDsFromRemoteCompletion:@[groupID] completion:^(NSArray *origins, NSError *error) {
                    if (!error)
                    {
                        MTGroupEntity* group = origins[0];
                        MTSessionEntity* session = [[MTSessionModule shareInstance] addSessionFromOriginEntity:group saveToDB:YES];
                        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
                        completion(session,message);
                    }
                }];
            }
        }
    }
}

- (void)p_addUnreadMessage:(MTMessageEntity*)message
{
    NSString* sessionID = [message sessionID];
    if (![[message senderID ] isEqualToString:[[DDClientState shareInstance] userID]]) {
        //添加未读计数.
        [_unreadMessageManager addUnreadMesageCountForSessionID:sessionID];
    }
}

- (void)p_finishSaveUnreadMessage:(MTSessionEntity *)session
{
    //更新未读消息计数
    [self p_updateUnreadMessageCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
}

- (void)p_checkoutMessageSenderInfo:(NSArray*)messages completion:(MTCheckoutMessageSendrInfoCompletion)completion
{
    NSMutableArray* unknowUsers = [[NSMutableArray alloc] init];
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTMessageEntity* message = (MTMessageEntity*)obj;
        NSString* userID = message.senderID;
        if (![[MTUserModule shareInstance] getOriginEntityWithOriginID:userID])
        {
            [unknowUsers addObject:userID];
        }
    }];
    if ([unknowUsers count] > 0)
    {
        [[MTUserModule shareInstance] getOriginEntityWithOriginIDsFromRemoteCompletion:unknowUsers completion:^(NSArray *origins, NSError *error) {
            completion();
        }];
    }
    else
    {
        completion();
    }
}


@end
