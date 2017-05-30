//
//  DDMessageReviewModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageEntity;
@interface DDMessageReviewModule : NSObject

/**
 *  获得所有的会话
 *
 *  @return 所有的会话
 */
- (NSArray*)allSession;

/**
 *  获得对应会话的所有消息
 *
 *  @param sessionID 对应的会话
 *  @param page 页码
 *
 *  @return 消息列表
 */
- (NSArray*)messagesForSessionID:(NSString*)sessionID page:(NSInteger)page;
@end
