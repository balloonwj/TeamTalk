//
//  DDAddChatGroupModel.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDAddChatGroupModel : NSObject


@property (nonatomic,readonly)NSMutableArray* groups;
@property (nonatomic,readonly)NSMutableArray* showGroups;
@property (nonatomic,retain)NSMutableArray* selectUsers;
@property (nonatomic,retain)NSMutableArray* selectGroups;
@property (nonatomic,readonly)id lastSelectedOne;

@property (nonatomic,retain)NSMutableArray* initialGroupUsersIDs;
- (void)loadAllWorkListSuccess:(void(^)())success Failure:(void(^)(NSError* error))failure;

- (void)selectItem:(id)item;
- (BOOL)exitInSelectedUsers:(id)item;
- (BOOL)couldSelected:(id)item;

- (void)searchUser:(NSString* )sender;

@end
