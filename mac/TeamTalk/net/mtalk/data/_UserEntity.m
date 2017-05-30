//
//  User.m
//  mtalk
//
//  Created by maye on 13-10-25.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "UserEntity.h"

@implementation UserEntity

-(void)copyContent:(UserEntity*)entity
{
    self.userId = [entity.userId copy];
    self.name = [entity.name copy];
    self.nick = [entity.nick copy];
    self.avatar = [entity.avatar copy];
    self.department = [entity.department copy];
    self.userRole = entity.userRole;
    self.userUpdated = entity.userUpdated;
}

- (NSString*)avatar
{
    if (_avatar && [_avatar length] > 0)
    {
        if (![_avatar hasSuffix:@"_100x100.jpg"]) {
            _avatar = [NSString stringWithFormat:@"%@%@",_avatar,@"_100x100.jpg"];
        }
    }
    return _avatar;
}

-(NSString*)userInfoAvatar
{
    if (_avatar && [_avatar length] > 0)
    {
        if (![_avatar hasSuffix:@"_200x200.jpg"]) {
            _avatar = [NSString stringWithFormat:@"%@%@",_avatar,@"_200x200.jpg"];
        }
    }
    return _avatar;
}


@end
