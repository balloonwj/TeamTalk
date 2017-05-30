//
//  DDMessageSendManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, MessageType)
{
    AllString,
    HasImage
};
@class MTMessageEntity,MTSessionEntity;

typedef void(^MTSendMessageSuccess)(MTMessageEntity* message);
typedef void(^MTSendMessageFailure)(MTMessageEntity* message,NSError* error);

@interface DDMessageSendManager : NSObject
@property (nonatomic,readonly)dispatch_queue_t sendMessageSendQueue;
@property (nonatomic,readonly)NSMutableArray* waitToSendMessage;
+ (instancetype)instance;

/**
 *  发送消息
 *
 *  @param content 发送内容，是富文本
 *  @param session 所属的会话
 */
- (MTMessageEntity*)sendMessage:(NSAttributedString*)content forSession:(MTSessionEntity*)session success:(MTSendMessageSuccess)success  failure:(MTSendMessageFailure)failure;

@end

@interface NSAttributedString(MessageSendManager)

- (MessageType)messageType;
- (NSString*)getAllStringContentFromInput;
- (NSString*)getHasImageContentFromInput;
@end