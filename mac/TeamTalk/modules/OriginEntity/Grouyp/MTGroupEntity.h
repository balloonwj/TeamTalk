//
//  MTGroupEntity.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDOriginEntity.h"
#import "IMBaseDefine.pb.h"

typedef NS_ENUM(NSUInteger, DDGroupType)
{
    DDTmpGroupType=2,
    DDNormalGroupType=1
};
@interface MTGroupEntity : DDOriginEntity

/**
 *  群类型(固定组|讨论组)
 */
@property (nonatomic,assign)DDGroupType groupType;

/**
 *  群主
 */
@property (nonatomic,retain)NSString* groupCreatorId;

/**
 * 群成员IDs
 */
@property (nonatomic,strong)NSMutableArray* groupUserIds;

/**
 * 群成员IDs
 */
@property (assign)BOOL isShield;

@property (nonatomic,assign)NSInteger groupVersion;

/**
 *  初始化方法
 *
 *  @param groupID  groupID
 *  @param type     groupType
 *
 *  @return Session实体
 */
- (id)initWithGroupID:(NSString*)ID
            groupType:(DDGroupType)groupType
                 name:(NSString*)name
               avatar:(NSString*)avatar
            creatorId:(NSString*)creatorId
         shieldStatus:(BOOL)shieldStatus
         groupUserIds:(NSMutableArray*)groupUserIds
              version:(NSInteger)groupVersion;


- (id)initWithGroupInfo:(GroupInfo*)groupInfo;

- (NSString*)getMemberList;

@end