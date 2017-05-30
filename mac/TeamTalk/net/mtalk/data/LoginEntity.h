/************************************************************
 * @file         LoginEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       登陆相关的参数
 ************************************************************/

#import <Foundation/Foundation.h>

@class UserEntity;

@interface LoginEntity : NSObject

@property(nonatomic,strong) NSString* ip1;     //电信IP地址
@property(nonatomic,strong) NSString* ip2;     //联通IP地址
@property(nonatomic,assign) sint16 port;       //端口
@property(nonatomic,assign) sint32 result;     //服务器返回的登陆值
@property(nonatomic,assign) uint32 serverTime;  //服务器时间
@property(nonatomic,strong) UserEntity*  myUserInfo; //登陆用户信息

@end
