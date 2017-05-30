/************************************************************
 * @file         SessionEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       会话实体信息
 ************************************************************/

#import <Foundation/Foundation.h>

@interface SessionEntity : NSObject<NSCopying>

enum
{
    SESSIONTYPE_SINGLE = 1,          //单个用户会话
    SESSIONTYPE_GROUP = 2,           //群会话
    SESSIONTYPE_TEMP_GROUP = 3,         //临时群会话.
    
};

@property(nonatomic,assign) sint16 type;                    //会话类型，群、单用户
@property(nonatomic,assign) long lastSessionTime;           //最后会话时间
@property(nonatomic,strong) NSString* sessionId;            //会话ID


//共有数据接口
@property(nonatomic,strong,readonly)NSString* avatar;           //头像
@property(nonatomic,strong,readonly)NSString* name;             //名称
@property(nonatomic,strong,readonly)NSString* orginId;          //由于groupId和userId会存在重复情况，这里获取其原始的userid或者groupid

//个人会话特有接口函数
@property(nonatomic,assign,readonly)uint32 onlineStatus;        //在线状态
@property(nonatomic,strong,readonly)NSString* nick;             //昵称

//群会话特有口函数
@property(nonatomic,strong,readonly)NSArray*  groupUsers;       //群成员列表
//群成员排序
-(void)sortGroupUsers;
-(NSUInteger)onlineUsersInGroup;                                //群成员列表在线人数.

@end
