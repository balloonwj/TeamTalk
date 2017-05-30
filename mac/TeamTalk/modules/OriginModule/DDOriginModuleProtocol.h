//
//  DDOriginModuleProtocol.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DDGetOriginsInfoCompletion)(NSArray* origins,NSError* error);

@class DDOriginEntity;
@protocol DDOriginModuleProtocol <NSObject>

@required
/**
 *  添加待维护的原始类型
 *
 *  @param originEntities 原始类型数据
 */
- (void)addMaintainOriginEntities:(NSArray*)originEntities;

/**
 *  根据OriginID获取实体类
 *
 *  @param originID originID
 *
 *  @return 实体类
 */
- (DDOriginEntity*)getOriginEntityWithOriginID:(NSString*)originID;

/**
 *  在本地没有相应信息的时候调用此接口，从后端获取
 *
 *  @param originIDs  originIDs
 *  @param completion 完成获取
 */
- (void)getOriginEntityWithOriginIDsFromRemoteCompletion:(NSArray*)originIDs completion:(DDGetOriginsInfoCompletion)completion;

/**
 *  移除Origins
 *
 *  @param originID originIDs
 */
- (void)removeOriginForIDs:(NSArray*)originIDs;

/**
 *  获取所有维护的实体
 *
 *  @return 所有维护的实体
 */
- (NSArray*)getAllOriginEntity;


@optional
/**
 *  添加屏蔽的Origin
 *
 *  @param groupID 待屏蔽的OriginIDs
 */
- (void)addShieldOrigins:(NSArray*)originIDs;

/**
 *  取消屏蔽的Origin
 *
 *  @param groupID 待取消屏蔽的Origin
 */
- (void)cancelShieldOrigins:(NSArray*)originIDs;

/**
 *  是否是被屏蔽的
 *
 *  @param originID originID
 *
 *  @return 屏蔽状态
 */
- (BOOL)shieldForOrigin:(NSString*)originID;


@end
