 /************************************************************
 * @file         SessionEntity.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       会话实体信息
 ************************************************************/

#import "SessionEntity.h"
#import "DDGroupModule.h"
#import "DDUserlistModule.h"
#import "GroupEntity.h"
#import "UserEntity.h"

@implementation SessionEntity

- (void)setLastSessionTime:(long)lastSessionTime
{
    _lastSessionTime = lastSessionTime;
}

-(NSString*)name
{
    if(SESSIONTYPE_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        if (!group.name)
        {
            log4Error(@"group name is nil,group ID is %@",group.groupId);
        }
        return group.name;
    }
    else if(SESSIONTYPE_SINGLE == _type)
    {
        DDUserlistModule* moduleUserlist = getDDUserlistModule();
        UserEntity* user = [moduleUserlist getUserById:_sessionId];
        if (!user.name)
        {
            log4Error(@"user name is nil, user ID is %@",user.userId);
        }
        return user.name;
    }else if(SESSIONTYPE_TEMP_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        if (!group.name)
        {
            log4Error(@"group name is nil,group ID is %@",group.groupId);
        }
        return group.name;
    }
    else
    {
        DDLog(@"name not exist session type");
        return  nil;
    }
}

-(NSString*)nick
{
    if(SESSIONTYPE_GROUP == _type || SESSIONTYPE_TEMP_GROUP ==_type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        return group.name;
    }
    else if(SESSIONTYPE_SINGLE == _type)
    {
        DDUserlistModule* moduleUserlist = getDDUserlistModule();
        UserEntity* user = [moduleUserlist getUserById:_sessionId];
        return user.nick;
    }
    else
    {
        DDLog(@"nick not exist session type");
        return  nil;
    }
}

-(NSString*)avatar
{
    if(SESSIONTYPE_GROUP == _type || SESSIONTYPE_TEMP_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        return group.avatar;
    }
    else if(SESSIONTYPE_SINGLE == _type)
    {
        DDUserlistModule* moduleUserlist = getDDUserlistModule();
        UserEntity* user = [moduleUserlist getUserById:_sessionId];
        return user.avatar;
    }
    else
    {
        DDLog(@"avatar not exist session type");
        return  nil;
    }
}

-(NSArray*)groupUsers
{
    if(SESSIONTYPE_GROUP == _type || SESSIONTYPE_TEMP_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        return group.groupUserIds;
    }
    else
    {
        DDLog(@"groupUsers error session type is :%d",_type);
        return  nil;
    }
}

-(uint32)onlineStatus
{
    if(SESSIONTYPE_GROUP == _type || SESSIONTYPE_TEMP_GROUP == _type)
    {
        return USER_STATUS_ONLINE;
    }
    else if(SESSIONTYPE_SINGLE)
    {
        StateMaintenanceManager* stateMaintenanceManager = [StateMaintenanceManager instance];
        return [stateMaintenanceManager getUserStateForUserID:self.sessionId];
    }
    else
    {
        DDLog(@"onlineStatus not exist session type");
        return  USER_STATUS_ONLINE;
    }
}

-(NSString*)orginId
{
    if(SESSIONTYPE_GROUP == _type ||SESSIONTYPE_TEMP_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        return [group getOriginGroupId];
    }
    else if(SESSIONTYPE_SINGLE == _type)
    {
        return _sessionId;
    }
    else
    {
        DDLog(@"orginGroupId not exist session type");
        return  nil;
    }
}

-(void)sortGroupUsers;
{
    if(SESSIONTYPE_GROUP == _type ||SESSIONTYPE_TEMP_GROUP == _type)
    {
        DDGroupModule* moduleGrp = getDDGroupModule();
        GroupEntity* group = [moduleGrp getGroupByGId:_sessionId];
        [group sortGroupUsers];
    }
}

-(NSUInteger)onlineUsersInGroup{
    NSUInteger onlineCount=0;
    if(SESSIONTYPE_GROUP == _type ||SESSIONTYPE_TEMP_GROUP == _type){
        StateMaintenanceManager* stateManager = [StateMaintenanceManager instance];
        NSArray *groups = [NSArray arrayWithArray:[self groupUsers]];
        for (NSString *userId in groups)
        {
            UserState state = [stateManager getUserStateForUserID:userId];
            if (state == USER_STATUS_ONLINE)
            {
                onlineCount ++;
            }
        }
    }
    return onlineCount;
}

#pragma mark - COPY
- (id)copyWithZone:(NSZone *)zone
{
    SessionEntity *newOne = [[SessionEntity alloc] init];
    newOne.type = self.type;
    newOne.lastSessionTime = self.lastSessionTime;
    newOne.sessionId = [self.sessionId copyWithZone:zone];
    return newOne;
}
@end
