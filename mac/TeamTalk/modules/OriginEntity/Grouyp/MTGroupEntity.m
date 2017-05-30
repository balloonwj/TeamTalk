//
//  MTGroupEntity.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTGroupEntity.h"

@implementation MTGroupEntity

- (id)initWithGroupID:(NSString *)ID groupType:(DDGroupType)groupType name:(NSString *)name avatar:(NSString *)avatar creatorId:(NSString *)creatorId shieldStatus:(BOOL)shieldStatus groupUserIds:(NSMutableArray *)groupUserIds version:(NSInteger)groupVersion
{
    self = [super init];
    if (self)
    {
        _ID = [ID copy];
        _name = [name copy];
        _avatar = [avatar copy];
        _groupCreatorId = [creatorId copy];
        _groupType = groupType;
        _isShield = shieldStatus;
        _groupUserIds = [groupUserIds copy];
        _groupVersion = groupVersion;
    }
    return self;
}


//只给PB调用.
- (instancetype)initWithGroupInfo:(GroupInfo*)groupInfo
{
    NSString* groupID = [NSString stringWithFormat:@"%d",groupInfo.groupId];
    NSString* groupCreatorId =  [[NSNumber numberWithInt:groupInfo.groupCreatorId] stringValue];
    NSInteger groupType = groupInfo.groupType;
    NSString* groupName = groupInfo.groupName;
    NSString* groupAvatar = groupInfo.groupAvatar;
    NSMutableArray* groupUserIds  = [[NSMutableArray alloc] init];
    for (int i = 0; i<[groupInfo.groupMemberList count]; i++) {
        [groupUserIds addObject:[NSString stringWithFormat:@"%@",groupInfo.groupMemberList[i]] ];
    }
    NSUInteger groupVersion = groupInfo.version;
    BOOL shieldStatus = groupInfo.shieldStatus != 0;
    self = [self initWithGroupID:groupID groupType:groupType name:groupName avatar:groupAvatar creatorId:groupCreatorId shieldStatus:shieldStatus groupUserIds:groupUserIds version:groupVersion];
    return self;
}

- (NSString*)getMemberList
{
    return [_groupUserIds componentsJoinedByString:@","];
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[MTGroupEntity class]]) {
        return NO;
    }
    
    MTGroupEntity* group = (MTGroupEntity*)object;
    if ([group.ID isEqualToString:self.ID] &&
        [group.name isEqualToString:self.name])
    {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.ID hash];
}

@end
