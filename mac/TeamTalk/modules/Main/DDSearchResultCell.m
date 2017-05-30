//
//  DDSearchResultCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSearchResultCell.h"
#import "MTUserEntity.h"
#import "MTGroupEntity.h"
#import "AvatorImageView.h"
@implementation DDSearchResultCell
- (void)configeWithObject:(id)object
{
    if ([object isKindOfClass:[MTUserEntity class]])
    {
        MTUserEntity* user = (MTUserEntity*)object;
        [avatarImageView setUser:user];
        if (user.name)
        {
            [nameTextField setStringValue:user.name];
        }
        else
        {
            [nameTextField setStringValue:@""];
        }
    }
    else if([object isKindOfClass:[MTGroupEntity class]])
    {
        MTGroupEntity* group = (MTGroupEntity*)object;
        [avatarImageView setGroup:group];
        if (group.name)
        {
            [nameTextField setStringValue:group.name];
        }
        else
        {
            [nameTextField setStringValue:@""];
        }
    }
}
@end
