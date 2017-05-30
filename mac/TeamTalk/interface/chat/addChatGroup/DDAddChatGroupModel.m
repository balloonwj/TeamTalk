//
//  DDAddChatGroupModel.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddChatGroupModel.h"
#import "MTUserEntity.H"
#import "DDAddChatGroup.h"
#import "SpellLibrary.h"
#import "MTUserModule.h"
#import "MTDepartmentManager.h"
@interface  MTUserEntity(DDAddChatGroupModel)

- (BOOL)adjustToSearchText:(NSString*)searchText;
@end

@interface DDAddChatGroupModel(PrivateAPI)

- (void)addUserToSelectUsersList:(MTUserEntity*)user;

@end

@implementation DDAddChatGroupModel
{
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _groups = [[NSMutableArray alloc] init];
        _selectUsers = [[NSMutableArray alloc] init];
        _selectGroups = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)loadAllWorkListSuccess:(void(^)())success Failure:(void(^)(NSError* error))failure
{
    NSArray* allUsers =[[MTUserModule shareInstance ]getAllOriginEntity];
    NSMutableDictionary* allData = [[NSMutableDictionary alloc] init];

    [allUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTUserEntity* userEntity = (MTUserEntity*)obj;
        if ([userEntity.ID isEqualToString:[[DDClientState shareInstance] userID]]) {
            return;
        }
        
        NSInteger departmentID = userEntity.department;

        if (![[allData allKeys] containsObject:@(departmentID)])
        {
            NSMutableArray* usersInGroup = [[NSMutableArray alloc] init];
            [usersInGroup addObject:userEntity];
            [allData setObject:usersInGroup forKey:@(departmentID)];
        }
        else
        {
            NSMutableArray* usersInGroup = allData[@(departmentID)];
            [usersInGroup addObject:userEntity];
        }
    }];
    
    [allData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DDAddChatGroup* group = [[DDAddChatGroup alloc] init];
        group.departmentID = [key intValue];
        MTDepartmentEntity* departmentEntity = [[MTDepartmentManager shareInstance] getDepartmentForID:group.departmentID];
        group.parentDepartmentID = departmentEntity.parentID;
        group.priority = departmentEntity.priority;
        group.name = departmentEntity.name;
        group.users = obj;
        [_groups addObject:group];
    }];
    [_groups sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DDAddChatGroup* chatGroup1 = (DDAddChatGroup*)obj1;
        DDAddChatGroup* chatGroup2 = (DDAddChatGroup*)obj2;
        if (chatGroup1.priority > chatGroup2.priority)
        {
            return NSOrderedDescending;
        }
        else if (chatGroup1.priority < chatGroup2.priority)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    _showGroups = _groups;

    success();
}

- (void)selectItem:(id)item
{
    _lastSelectedOne = item;
    if ([item isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        MTUserEntity* user = (MTUserEntity*)item;
        if([self.initialGroupUsersIDs containsObject:user.ID])
        {
            return;
        }
        [self addUserToSelectUsersList:user];
        NSMutableArray* deselectedGroups = [[NSMutableArray alloc] init];
        for (DDAddChatGroup* group in _selectGroups)
        {
            BOOL deselectGroup = YES;
            for (MTUserEntity* user in group.users)
            {
                if ([_selectUsers containsObject:user])
                {
                    deselectGroup = NO;
                    break;
                }
            }
            if (deselectGroup)
            {
                [deselectedGroups addObject:group];
            }
        }
        [_selectGroups removeObjectsInArray:deselectedGroups];
    }
    else if([item isKindOfClass:NSClassFromString(@"DDAddChatGroup")])
    {
        DDAddChatGroup* group = (DDAddChatGroup*)item;
        if (![_selectGroups containsObject:group])
        {
            [_selectGroups addObject:group];
            for (MTUserEntity* user in group.users)
            {
                if (![self.selectUsers containsObject:user] && ![self.initialGroupUsersIDs containsObject:user.ID])
                {
                    [self.selectUsers addObject:user];
                }
            }
        }
        else
        {
            [_selectGroups removeObject:group];
            for (MTUserEntity* user in group.users)
            {
                if ([self.selectUsers containsObject:user])
                {
                    [self.selectUsers removeObject:user];
                }
            }
        }
    }
}

- (BOOL)exitInSelectedUsers:(id)item
{
    if ([item isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        if([self.initialGroupUsersIDs containsObject:[(MTUserEntity*)item ID]])
        {
            return YES;
        }
    }
    if ([self.selectUsers containsObject:item] || [self.selectGroups containsObject:item])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)couldSelected:(id)item
{
    if ([item isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        if ([self.initialGroupUsersIDs containsObject:[(MTUserEntity*)item ID]])
        {
            return NO;
        }
    }
    return YES;
}

- (void)searchUser:(NSString* )sender
{
    if ([sender length] == 0)
    {
        _showGroups = _groups;
        return;
    }
    else
    {
        _showGroups = [[NSMutableArray alloc] init];
    }
    for (DDAddChatGroup * group in _groups)
    {
        DDAddChatGroup* newGroup = [[DDAddChatGroup alloc] init];
        newGroup.name = group.name;
        NSMutableArray* users = [[NSMutableArray alloc] init];
        
        [group.users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTUserEntity* user = (MTUserEntity*)obj;
            if ([user adjustToSearchText:sender])
            {
                [users addObject:user];
            }
        }];
        newGroup.users = users;
        if ([users count] > 0)
        {
            [_showGroups addObject:newGroup];
        }
    }
}

#pragma mark Private API
- (void)addUserToSelectUsersList:(MTUserEntity*)user
{
    if ([self.selectUsers containsObject:user]) {
        [self.selectUsers removeObject:user];
    }
    else
    {
        [self.selectUsers addObject:user];
    }
}

@end

@implementation MTUserEntity(DDAddChatGroupModel)

- (BOOL)adjustToSearchText:(NSString*)searchText
{
    NSString* name = self.name;
    if ([name rangeOfString:searchText].length > 0)
    {
        return YES;
    }
    
    NSMutableArray* spells = [NSMutableArray array];
    for (int index = 0; index < [name length]; index ++)
    {
        NSString* wordAtIndex = [name substringWithRange:NSMakeRange(index, 1)];
        NSString* spellAtIndex = [[SpellLibrary instance] getSpellForWord:wordAtIndex];
        [spells addObject:spellAtIndex];
    }
    
    for (int count = 0; count < [spells count] + 1; count ++)
    {
        NSString* spell = [[SpellLibrary instance] briefSpellWordFromSpellArray:spells fullWord:count];
        if ([spell rangeOfString:searchText].length > 0)
        {
            return YES;
        }
    }
    return NO;
}
@end