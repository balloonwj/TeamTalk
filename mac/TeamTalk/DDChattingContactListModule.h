//
//  DDChattingContactListModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^Completion)();

@class MTGroupEntity;
@interface DDChattingContactListModule : NSObject
@property (nonatomic,retain)MTGroupEntity* groupEntity;
- (void)searchContent:(NSString*)searchContent completion:(Completion)completion;
- (void)sortGroupUserCompletion:(Completion)completion;;
- (NSMutableArray *)getGroupUserList;
-(NSUInteger)getOnlineUserListCount;
- (void)updateData;

@end
