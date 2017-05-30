//
//  AvatorImageView.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-1.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MTSessionEntity,MTUserEntity,MTGroupEntity;
@interface AvatorImageView : NSImageView
@property (nonatomic,retain)MTSessionEntity* session;

- (void)setSession:(MTSessionEntity *)session;
- (void)setGroup:(MTGroupEntity *)group;
- (void)setUser:(MTUserEntity *)user;
@end
