//
//  StateMaintenanceManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRootModule.h"
#import "IMBaseDefine.pb.h"

@class DDUserStateEntity;
#define DD_USER_ONLINE_STATE_KEYPATH        @"userStateEntity"

@interface StateMaintenanceManager : DDRootModule
/**
 * 用户在线状态
 */
@property (nonatomic,strong)DDUserStateEntity *userStateEntity;

+ (instancetype)instance;

/**
 *  获得用户的在线状态
 *
 *  @param userID 用户ID
 *
 *  @return 在线状态
 */

-(UserStatType) getUserStateForUserID:(NSString*)userID;
@end


@interface DDUserStateEntity : NSObject

@property (nonatomic,copy)NSString *userId;
@property (nonatomic,assign)NSUInteger uState;

-(id)initWithUserId:(NSString *)userId state:(NSUInteger)uState;
@end
