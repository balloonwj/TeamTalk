//
//  MTUserEntity.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTUserEntity.h"
#import "MTImageCache.h"
#import "MTDepartmentManager.h"
@implementation MTUserEntity
@synthesize gender = _gender;
@synthesize department = _department;
@synthesize email = _email;
@synthesize realName = _realName;
@synthesize userDomain = _userDomain;
@synthesize tel = _tel;
@synthesize status = _status;
@synthesize departmentName = _departmentName;
- (instancetype)initWithID:(NSString*)ID name:(NSString*)name avatar:(NSString*)avatar gender:(NSInteger)gender department:(NSInteger)department email:(NSString*)email realName:(NSString*)realName userDomain:(NSString *)userDomain tel:(NSString*)tel status:(NSInteger)status
{
    self = [super init];
    if (self)
    {
        _ID = [ID copy];
        _name = [name copy];
        _avatar = [avatar copy];
        _gender = gender;
        _department = department;
        _email = [email copy];
        _realName = [realName copy];
        _userDomain = [userDomain copy];
        _tel = [tel copy];
        _status = status;
    }
    return self;
}


- (instancetype)initWithUserInfo:(UserInfo*)userInfo
{
    NSString* ID = [NSString stringWithFormat:@"%d",userInfo.userId];
    self = [self initWithID:ID name:userInfo.userNickName avatar:userInfo.avatarUrl gender:userInfo.userGender department:userInfo.departmentId email:userInfo.email realName:userInfo.userRealName userDomain:userInfo.userDomain tel:userInfo.userTel status:userInfo.status];
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }
    if (![object isKindOfClass:[MTUserEntity class]])
    {
        return NO;
    }
    MTUserEntity* user = (MTUserEntity*)object;
    if ([self.ID isEqualToString:user.ID] &&
        [self.name isEqualToString:self.name])
    {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.ID hash];
}

- (NSString*)toJson
{
    NSString* avatar = self.smallAvatar;
    NSString* filePath = [[MTImageCache shareInstance] filePathWithKey:avatar];
    if (filePath)
    {
        avatar = [filePath copy];
    }
    NSDictionary* dic = @{@"ID":_ID,
                          @"Name":_name,
                          @"Avatar":avatar,
                          @"Gender":@(_gender),
                          @"Department":_department ? @(_department) : @"",
                          @"Email":_email ? _email : @"",
                          @"RealName":_realName ? _realName : @"",
                          @"UserDoamin":_userDomain ? _userDomain : @"",
                          @"Tel":_tel ? _tel : @"",
                          @"Status":@(_status)};
    NSError* error = nil;
    NSData *historyData = [NSJSONSerialization dataWithJSONObject:dic
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    
    if (!error)
    {
        NSString* json = [[NSString alloc] initWithData:historyData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
    
}

- (NSString*)smallAvatar
{
    if (![self.avatar hasSuffix:@"_100x100.jpg"])
    {
        return [NSString stringWithFormat:@"%@_100x100.jpg",self.avatar];
    }
    return self.avatar;
}

- (NSString*)departmentName
{
    if ([_departmentName length] == 0)
    {
        MTDepartmentEntity* department = [[MTDepartmentManager shareInstance] getDepartmentForID:self.department];
        _departmentName = [department.name copy];
    }
    return _departmentName;
}
@end
