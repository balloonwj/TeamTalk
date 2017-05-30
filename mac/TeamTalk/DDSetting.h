//
//  DDSetting.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSetting : NSObject

+ (instancetype)instance;

/**
 *  还原默认设置
 */
- (void)restoreDefaultSetting;

/**
 *  获得置顶的会话
 *
 *  @return 置顶的会话ID
 */
- (NSArray*)getTopSessionIDs;


/**
 *  会话置顶
 *
 *  @param sessionID 会话ID
 */
- (void)addTopSessionID:(NSString*)sessionID;

/**
 *  取消会话置顶
 *
 *  @param sessionID 会话ID
 */
- (void)removeTopSessionID:(NSString*)sessionID;

/**
 *  获得屏蔽的会话IDS
 *
 *  @return 屏蔽的会话ID
 */
- (NSArray*)getShieldSessionIDs;

/**
 *  屏蔽会话
 *
 *  @param sessionID 会话ID
 */
- (void)addShieldSessionID:(NSString*)sessionID;

/**
 *  取消屏蔽会话
 *
 *  @param sessionID 会话ID
 */
- (void)removeShieldSessionID:(NSString*)sessionID;
@end
