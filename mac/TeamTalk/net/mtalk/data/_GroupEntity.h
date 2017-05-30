/************************************************************
 * @file         GroupEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       群实体信息
 ************************************************************/

#import <Foundation/Foundation.h>

static NSString* const GROUP_PRE = @"group_";          //group id 前缀

enum
{
    GROUP_TYPE_FIXED = 1,       //固定群
    GROUP_TYPE_TEMPORARY,       //临时群
};

@interface GroupEntity : NSObject

@property(nonatomic,strong) NSString* groupCreatorId;        //群创建者ID
@property(nonatomic,assign) uint32 groupType;                //群类型
@property(nonatomic,assign) uint32 groupUpdated;             //群最近联系时间
@property(nonatomic,strong) NSString* groupId;               //群ID
@property(nonatomic,strong) NSString* name;                  //群名称
@property(nonatomic,strong) NSString* avatar;                //群头像
@property(nonatomic,strong) NSMutableArray* groupUserIds;    //群用户列表ids
@property(nonatomic,readonly)NSMutableArray* fixGroupUserIds;//固定的群用户列表IDS，用户生成群头像
//注：由于groupId和userId会存在重复情况，这里获取其原始的group id
-(NSString*)getOriginGroupId;
//对群成员排序
-(void)sortGroupUsers;

-(void)copyContent:(GroupEntity*)entity;

+(NSString *)getSessionId:(NSString *)groupId;

- (void)addFixOrderGroupUserIDS:(NSString*)ID;

@end
