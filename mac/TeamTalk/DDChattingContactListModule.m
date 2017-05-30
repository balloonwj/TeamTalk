//
//  DDChattingContactListModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingContactListModule.h"
#import "DDSearch.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "MTGroupEntity.h"
#import "MTGroupModule.h"
#import "StateMaintenanceManager.h"


@implementation DDChattingContactListModule
{
    NSMutableArray* _groupUsers;
    NSMutableArray* _showUserMember;
    NSString* _lastSearchContent;
}



- (void)searchContent:(NSString*)searchContent completion:(Completion)completion
{
    _lastSearchContent = [searchContent copy];
    if (!self.groupEntity)
    {
        return;
    }
    
    if ([searchContent length] == 0)
    {
        _showUserMember = [[NSMutableArray alloc] initWithArray:_groupUsers];
        [self sortGroupUserCompletion:^{
            completion();
        }];
        return;
    }
    

    NSArray* ranges = _groupUsers;
    
    [[DDSearch instance] searchContent:searchContent inRange:ranges completion:^(NSArray *result, NSError *error) {
        if (!error)
        {
             _showUserMember = [[NSMutableArray alloc] initWithArray:result];

                [self sortGroupUserCompletion:^{
                    completion();
                }];

        }
    }];
}

- (void)setGroupEntity:(MTGroupEntity *)groupEntity
{
    _groupEntity = groupEntity;
    
    if (groupEntity) {
        if(!_groupUsers){
            _groupUsers = [[NSMutableArray alloc] init];
        }
        [_groupUsers removeAllObjects];
        
        [groupEntity.groupUserIds enumerateObjectsUsingBlock:^(NSString *uid, NSUInteger idx, BOOL *stop) {
            MTUserEntity *user =(MTUserEntity *) [[MTUserModule shareInstance] getOriginEntityWithOriginID:uid];
            if(user){
                 [_groupUsers addObject:user];
            }else{
                DDLog(@" **** 取不到人:%@",uid);
            }
           
        }];
    }
    _showUserMember = [[NSMutableArray alloc] initWithArray:_groupUsers];
    
}


- (void)sortGroupUserCompletion:(Completion)completion
{
    [(NSMutableArray *)_showUserMember sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* uId1 = [(MTUserEntity*)obj1 ID];
        NSString* uId2 = [(MTUserEntity*)obj2 ID];
        StateMaintenanceManager* stateMaintenanceManager = [StateMaintenanceManager instance];
        UserStatType user1OnlineState = [stateMaintenanceManager getUserStateForUserID:uId1];
        UserStatType user2OnlineState = [stateMaintenanceManager getUserStateForUserID:uId2];
        if((user1OnlineState == UserStatTypeUserStatusOnline) &&
           (user2OnlineState == UserStatTypeUserStatusLeave || user2OnlineState == UserStatTypeUserStatusOffline))
        {
            return NSOrderedAscending;
        }
        else if(user1OnlineState == UserStatTypeUserStatusLeave && user2OnlineState == UserStatTypeUserStatusOffline)
        {
            return NSOrderedAscending;
        }
        else if (user2OnlineState == UserStatTypeUserStatusOnline &&
                 (user1OnlineState == UserStatTypeUserStatusLeave || user1OnlineState == UserStatTypeUserStatusOffline))
        {
            return NSOrderedDescending;
        }
        else if(user2OnlineState == UserStatTypeUserStatusLeave && user1OnlineState == UserStatTypeUserStatusOffline)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
        
    }];

//    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
//    });
}

- (void)updateData
{
    [_groupUsers removeAllObjects];
    
    [_groupEntity.groupUserIds enumerateObjectsUsingBlock:^(NSString *uid, NSUInteger idx, BOOL *stop) {
        MTUserEntity *user =(MTUserEntity *) [[MTUserModule shareInstance] getOriginEntityWithOriginID:uid];
        if (user)
        {
            [_groupUsers addObject:user];
        }
    }];
    
    _showUserMember = [[NSMutableArray alloc] initWithArray:_groupUsers];
}

- (NSMutableArray *)getGroupUserList{

    return _showUserMember;
}

-(NSUInteger)getOnlineUserListCount{
    NSMutableArray *array =[self getGroupUserList];
    __block NSUInteger c =0;
    [array enumerateObjectsUsingBlock:^(MTUserEntity *user, NSUInteger idx, BOOL *stop) {
        UserStatType userState = [[StateMaintenanceManager instance]getUserStateForUserID:user.ID];
        if(userState!=UserStatTypeUserStatusOffline){
            c++;
        }
    }];
    return c;
}

- (void)dealloc
{
    //移除观察
}

@end
