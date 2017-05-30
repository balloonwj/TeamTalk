//
//  User.h
//  mtalk
//
//  Created by maye on 13-10-25.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UserEntity : NSObject

@property(nonatomic,strong) NSString *userId;       //用户ID
@property(nonatomic,strong) NSString *name;         //用户名
@property(nonatomic,strong) NSString *nick;         //用户昵称
@property(nonatomic,strong) NSString *avatar;       //用户头像
@property(nonatomic,strong) NSString *department;   //用户部门
@property(nonatomic,assign) uint32 userRole;        //用户角色
@property(nonatomic,assign) uint32 userUpdated;     //用户最近联系时间

-(void)copyContent:(UserEntity*)entity;
-(NSString*)userInfoAvatar;

@end
