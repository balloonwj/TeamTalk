//
//  MTSessionEntity.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"

#define DD_GROUP_SESSIONID_PREFIX                       @"group_"
#define DD_GROUP_SESSIONID(groupID)                     [NSString stringWithFormat:@"%@%@",DD_GROUP_SESSIONID_PREFIX,groupID]



/**
 *  //创建一个session，只需赋值sessionID和Type即可，其他信息会自动补齐
 */
@interface MTSessionEntity : NSObject


/**
 * 最新一条消息.
 */
@property(nonatomic,strong)NSString *lastMsg;

/**
 *  会话ID
 */
@property (nonatomic,retain)NSString* sessionID;
/**
 *  原始ID，(若是店铺，则是对应的客服ID)
 */
@property (nonatomic,retain)NSString* originID;

/**
 *  会话类型
 */
@property (nonatomic,assign)SessionType sessionType;

/**
 *  会话名称
 */
@property (nonatomic,readonly)NSString* name;

/**
 *  会话头像
 */
@property (nonatomic,retain)NSString* avatar;

/**
 *  会话时间戳
 */
@property (nonatomic,assign)NSUInteger timeInterval;

/**
 *  最后一条消息的ID.
 */
@property(assign)NSInteger lastMsgID;


/**
 *  初始化方法
 *
 *  @param originID originID
 *  @param type     sessionType
 *
 *  @return Session实体
 */
- (id)initWithOriginID:(NSString*)originID type:(SessionType)type;

/**
 *  更新会话时间
 *
 *  @param date 时间
 */
- (void)updateUpdateTime:(NSUInteger)date;

/**
 *  根据OriginID 和 sessionType 获取SessionID
 *
 *  @param originID    originID
 *  @param sessionType sessionType
 *
 *  @return sessionID
 */
+ (NSString*)getSessionIDForOriginID:(NSString*)originID sessionType:(SessionType)sessionType;

+ (NSString*)getOriginIDFromSessionID:(NSString*)sessionID;

+ (SessionType)getSessionTypeFromSessionID:(NSString*)sessionID;

/**
 *  是否被屏蔽了
 *
 *  @return 屏蔽结果
 */
- (BOOL)shield;

@end
