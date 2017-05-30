//
//  MTUserEntity.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDOriginEntity.h"
#import "IMBaseDefine.pb.h"
@interface MTUserEntity : DDOriginEntity
{
    NSInteger _gender;
    NSInteger _department;
    NSString* _email;
    NSString* _realName;
    NSString* _userDomain;
    NSString* _tel;
    NSInteger _status;
    NSString* _departmentName;
}
@property (nonatomic,assign,readonly)NSInteger gender;
@property (nonatomic,assign,readonly)NSInteger department;
@property (nonatomic,retain,readonly)NSString* email;
@property (nonatomic,retain,readonly)NSString* realName;
@property (nonatomic,retain,readonly)NSString* userDomain;
@property (nonatomic,retain,readonly)NSString* tel;
@property (nonatomic,assign,readonly)NSInteger status;
@property (nonatomic,retain,readonly)NSString* departmentName;

- (instancetype)initWithID:(NSString*)ID name:(NSString*)name avatar:(NSString*)avatar gender:(NSInteger)gender department:(NSInteger)department email:(NSString*)email realName:(NSString*)realName userDomain:(NSString*)userDomain tel:(NSString*)tel status:(NSInteger)status;

- (instancetype)initWithUserInfo:(UserInfo*)userInfo;

- (NSString*)toJson;

- (NSString*)smallAvatar;

@end
