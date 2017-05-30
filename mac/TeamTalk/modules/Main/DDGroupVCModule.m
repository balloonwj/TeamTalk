//
//  DDGroupVCModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupVCModule.h"
#import "MTGroupModule.h"
#import "DDFixedGroupAPI.h"
#import "MTGroupEntity.h"
#import "SpellLibrary.h"
@implementation DDGroupVCModule
{
    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //tt_3.0
       // DDGroupModule* groupModule = getDDGroupModule();
       // self.groups = [groupModule getAllFixedGroups];
    }
    return self;
}

- (void)loadGroups
{
    NSArray* allGroups = [[MTGroupModule shareInsatnce] getAllOriginEntity];
    NSMutableArray* fixGroups = [[NSMutableArray alloc] init];
    [allGroups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTGroupEntity* group = (MTGroupEntity*)obj;
        if (group.groupType == DDNormalGroupType)
        {
            [fixGroups addObject:group];
        }
    }];
    _groups = [[NSArray alloc] initWithArray:fixGroups];
}

- (NSInteger)indexAtGroups:(MTGroupEntity*)group
{
    __block NSInteger index = -1;
    [self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTGroupEntity* theGroup = (MTGroupEntity*)obj;
        if ([theGroup isEqual:group])
        {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

@end
