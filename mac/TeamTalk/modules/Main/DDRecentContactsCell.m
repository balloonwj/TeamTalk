//
//  DDRecentContactsCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRecentContactsCell.h"
#import "MTSessionEntity.h"
#import "AvatorImageView.h"
#import "DDSetting.h"
#import "MTMessageModule.h"
#import "StateMaintenanceManager.h"
#import "DDServiceAccountModule.h"
#import <Quartz/Quartz.h>
#import "NSImageView+MTAddition.h"
CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

NSNumber* DegreesToNumber(CGFloat degrees) {
    return [NSNumber numberWithFloat: DegreesToRadians(degrees)];
}

@implementation DDRecentContactsCell


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}
-(void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
}
- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)clearUnreadCount{
    [unreadMessageLabel setStringValue:@""];
    [unreadMessageLabel setHidden:YES];
    [unreadMessageBackground setHidden:YES];
}

- (void)configeCellWithObject:(MTSessionEntity*)object
{
    //头像和在线状态
    if (object.sessionType==SessionTypeSessionTypeGroup)
    {
        [nameTextField setTextColor:[NSColor blackColor]];
    }
    else
    {
        if ([[StateMaintenanceManager instance] getUserStateForUserID:object.sessionID] == UserStatTypeUserStatusOnline)
        {
            [nameTextField setTextColor:[NSColor blackColor]];
        }
        else
        {
            [nameTextField setTextColor:[NSColor grayColor]];
        }
    }
    if ([object.name isEqualToString:@"小T"])
    {
        DDLog(@"ad");
    }
    
    [(AvatorImageView*)self.imageView setSession:object];
    
//    [self.imageView setImageWithURL:object.avatar placeholderImage:[NSImage imageNamed:@"man_placeholder"]];

    if (object.name)
    {
        [nameTextField setStringValue:object.name];
    }
    else
    {
        [nameTextField setStringValue:@""];
    }
    
    //置顶图标
    NSArray* topSessions = [[DDSetting instance] getTopSessionIDs];
    if ([topSessions containsObject:object.sessionID])
    {
        [topIconImageView setHidden:NO];
    }
    else
    {
        [topIconImageView setHidden:YES];
    }
    
    //屏蔽图标
    NSArray* shieldSessions = [[DDSetting instance] getShieldSessionIDs];
    if ([shieldSessions containsObject:object.sessionID])
    {
        [shieldIconImageView setImage:[NSImage imageNamed:@"shield"]];
        [shieldIconImageView setHidden:NO];
    }
    else
    {
        [shieldIconImageView setHidden:YES];
    }
    
    //显示未读消息数
    NSInteger unreadCount = [[MTMessageModule shareInstance] getUnreadMessageCountForSessionID:object.sessionID];
    NSString* unreadCountString;
    if (unreadCount == 0)
    {
        [unreadMessageLabel setHidden:YES];
        [unreadMessageLabel setStringValue:@""];
        [unreadMessageBackground setHidden:YES];
    }
    else if (unreadCount < 99)
    {
        [unreadMessageBackground setHidden:NO];
        [unreadMessageLabel setHidden:NO];
        unreadCountString = [NSString stringWithFormat:@"%li",(long)unreadCount];
        [unreadMessageLabel setStringValue:unreadCountString];
    }
    else
    {
        [unreadMessageBackground setHidden:NO];
        [unreadMessageLabel setHidden:NO];
        unreadCountString = @"99+";
        [unreadMessageLabel setStringValue:unreadCountString];
    }
    self.tempColor=nameTextField.textColor;
    
    if ([[DDServiceAccountModule shareInstance] isServiceAccount:object.sessionID])
    {
        if (unreadCount > 0)
        {
//            float width = avatarImageView.bounds.size.width;
//            float height = avatarImageView.bounds.size.height;
//            float x = avatarImageView.frame.origin.x;
//            float y = avatarImageView.frame.origin.y;
            
            CAAnimationGroup* group = [[CAAnimationGroup alloc] init];
            group.duration = 1;
            group.repeatCount = 10000;
            CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

            NSMutableArray *values = [NSMutableArray array]; // Turn right
            [values addObject:@(1)]; // Turn left
            [values addObject:@(0.8)]; // Turn right
            [values addObject:@(1)];
            [animation setValues:values];
            group.animations = @[animation];
            [self.imageView.layer addAnimation:group forKey:@"T"];
        }
        else
        {
            [self.imageView.layer removeAllAnimations];
        }
    }
}
- (void) setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    NSTableRowView *row = (NSTableRowView*)self.superview;
    //NSColor *tempColor = nameTextField.textColor;
    if (row.isSelected) {
        nameTextField.textColor = [NSColor whiteColor];
    } else {
        nameTextField.textColor = self.tempColor;
    }
    
}
- (void)setTopIconHidden:(BOOL)hidden
{
    [topIconImageView setHidden:hidden];
}
@end
