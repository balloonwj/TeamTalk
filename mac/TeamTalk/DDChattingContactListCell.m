//
//  DDChattingContactListCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-14.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingContactListCell.h"
#import "MTUserEntity.h"
#import "StateMaintenanceManager.h"
@implementation DDChattingContactListCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)configeWithUser:(MTUserEntity*)user
{
    NSString* name = user.name;
    if (!name)
    {
        [_userNameTextField setStringValue:
         @""];
    }
    else
    {
        [_userNameTextField setStringValue:name];
    }
    NSImage* icon;
    NSString* userID = user.ID;
    StateMaintenanceManager* stateMaintenanceManager = [StateMaintenanceManager instance];
    UserStatType userOnlineState = [stateMaintenanceManager getUserStateForUserID:userID];
    switch (userOnlineState)
    {
        case UserStatTypeUserStatusOnline:
            icon = [NSImage imageNamed:@"state-online"];
            break;
        case UserStatTypeUserStatusOffline:
            icon = [NSImage imageNamed:@"state-offline"];
            break;
        case UserStatTypeUserStatusLeave:
            icon = [NSImage imageNamed:@"state-leave"];
            break;
    }
    
    [_stateImageView setImage:icon];
}

@end
