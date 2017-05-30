//
//  DDGroupDataModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupDataModule.h"
#import "MTGroupEntity.h"
#import "MTUserModule.h"

#define USERS_IN_ROW                6

@interface DDGroupDataModule(PrivateAPI)

- (void)updateGroupUsers;

@end

@implementation DDGroupDataModule
{
    NSMutableArray* _groupUsers;
}

- (void)setShowGroup:(MTGroupEntity *)showGroup
{
    if (_showGroup)
    {
        _showGroup = nil;
    }
    _showGroup = showGroup;
    [self updateGroupUsers];
}

- (NSString*)windowTitle
{
    if (_showGroup)
    {
        return _showGroup.name;
    }
    else
    {
        return nil;
    }
}

- (NSInteger)rowNumber
{
    NSInteger rowNumber = [_groupUsers count] % USERS_IN_ROW == 0 ? [_groupUsers count] / USERS_IN_ROW : [_groupUsers count] / USERS_IN_ROW + 1;
    return rowNumber;
}

- (NSArray*)usersForRow:(NSInteger)row
{
    NSArray* users;
    if ([_groupUsers count] > USERS_IN_ROW * (row + 1))
    {
        users = [_groupUsers subarrayWithRange:NSMakeRange(row * USERS_IN_ROW, USERS_IN_ROW)];
    }
    else
    {
        users = [_groupUsers subarrayWithRange:NSMakeRange(row * USERS_IN_ROW, [_groupUsers count] - row * USERS_IN_ROW)];
    }
    NSMutableArray* userEntitys = [NSMutableArray array];
    for (NSString* user in users)
    {
        
        [userEntitys addObject:user];
    }
    return userEntitys;
}

#pragma mark - Private API
- (void)updateGroupUsers
{
    _groupUsers = nil;
    _groupUsers = [[NSMutableArray alloc] init];
    if (_showGroup)
    {
        [_showGroup.groupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:obj];;
            if (user && ![_groupUsers containsObject:user]) {
                [_groupUsers addObject:user];
            }
        }];
    }
}
@end
