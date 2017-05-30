//
//  DDCurrentUserState.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTUserEntity;
@interface DDCurrentUserState : NSObject
@property (nonatomic,readonly)MTUserEntity* user;
+ (instancetype)instance;

/**
 *  初始化登录用户
 *
 *  @param user 登录用户
 */
- (void)loginTheUser:(MTUserEntity*)user;

@end
