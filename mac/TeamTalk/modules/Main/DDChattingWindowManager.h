//
//  DDChattingWindowManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-26.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDChattingViewController;
@interface DDChattingWindowManager : NSObject
+ (instancetype)instance;

/**
 *  添加正在聊天的试图控制器
 *
 *  @param chattingVC 正在聊天的视图控制器
 *  @param sessionID  会话ID
 */
- (void)addChattingWindow:(DDChattingViewController*)chattingVC forSessionID:(NSString*)sessionID;


/**
 *  打开正在聊天的视图控制器
 *
 *  @param sessionID 会话ID
 *
 *  @return 视图控制器
 */
- (DDChattingViewController*)openChattingWindowForSessionID:(NSString*)sessionID;

//temp
- (void)removeChattingWindowForSessionID:(NSString*)sessionID;
@end
