//
//  AvatorImageView.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-1.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "AvatorImageView.h"
#import "MTSessionEntity.h"
#import "MTUserEntity.h"
#import "MTGroupEntity.h"
#import "MTUserModule.h"
#import "MTGroupModule.h"
#import "NSImageView+MTAddition.h"

@interface AvatorImageView(privateAPI)

- (void)loadUserAvator:(MTSessionEntity*)session;
- (void)loadGroupAvator:(MTSessionEntity*)session;

@end

@implementation AvatorImageView
- (void)setSession:(MTSessionEntity *)session
{

    switch (session.sessionType)
    {
        case SessionTypeSessionTypeSingle:
            [self loadUserAvator:session];
            break;
        case SessionTypeSessionTypeGroup:
            [self loadGroupAvator:session];
            break;
        default:
            break;
    }
}

- (void)setGroup:(MTGroupEntity *)group
{
    NSMutableArray* subviews= [[NSMutableArray alloc] initWithArray:[self subviews]];
    for (NSImageView* view in subviews)
    {
        [view removeFromSuperview];
    }
    [self setImage:nil];
    
    int count = 0;
    for (int index = 0; index < [group.groupUserIds count]; index ++)
    {
        NSString* userID = group.groupUserIds[index];
        MTUserEntity *user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
        if (user.avatar && [user.avatar length] > 0)
        {
            CGFloat x = (count % 2) * (self.frame.size.width / 2.0);
            CGFloat y = count > 1 ? (self.frame.size.height / 2.0) : 0;
            CGFloat width = self.frame.size.width / 2.0;
            CGFloat height = self.frame.size.height / 2.0;
            NSRect frame = NSMakeRect(x, y, width, height);
            NSImageView* imageView = [[NSImageView alloc] initWithFrame:frame];
//            NSURL* avatorURL = [NSURL URLWithString:user.avatar];
            [imageView setImageWithURL:[user smallAvatar] placeholderImage:@"man_placeholder"];
//            [imageView loadImageWithURL:avatorURL setplaceholderImage:@"man_placeholder"];
            [self addSubview:imageView];
            count ++;
            
        }
        if (count >= 4)
        {
            break;
        }
    }
}

- (void)setUser:(MTUserEntity *)user
{
    NSMutableArray* subviews= [[NSMutableArray alloc] initWithArray:[self subviews]];
    if ([subviews count] > 1)
    {
        for (NSImageView* view in subviews)
        {
            [view removeFromSuperview];
        }
    }
    [self setImage:nil];
    
    NSString* avator = [user smallAvatar];
    
//    NSURL* url = [NSURL URLWithString:avator];
    [self setImageWithURL:avator placeholderImage:@"man_placeholder"];
//    [self loadImageWithURL:url setplaceholderImage:@"man_placeholder"];
}

- (void)loadUserAvator:(MTSessionEntity*)session
{
    NSMutableArray* subviews= [[NSMutableArray alloc] initWithArray:[self subviews]];
    if ([subviews count] > 1)
    {
        for (NSImageView* view in subviews)
        {
            [view removeFromSuperview];
        }
    }
    [self setImage:nil];


    NSString* avator = session.avatar;
    [self setImageWithURL:avator placeholderImage:@"man_placeholder"];

}

- (void)loadGroupAvator:(MTSessionEntity*)session
{
    NSMutableArray* subviews= [[NSMutableArray alloc] initWithArray:[self subviews]];
    for (NSImageView* view in subviews)
    {
        [view removeFromSuperview];
    }
    [self setImage:nil];
    MTGroupEntity *group = (MTGroupEntity *)[[MTGroupModule shareInsatnce]getOriginEntityWithOriginID:session.originID];
    int count = 0;
    for (NSInteger index = 0; index < [group.groupUserIds count]; index ++)
    {
        NSString* userID = [NSString stringWithFormat:@"%li",[group.groupUserIds[index] integerValue]];
        MTUserEntity *user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];

        if (user.avatar && [user.avatar length] > 0)
        {
            CGFloat x = (count % 2) * (self.frame.size.width / 2.0);
            CGFloat y = count > 1 ? (self.frame.size.height / 2.0) : 0;
            CGFloat width = self.frame.size.width / 2.0;
            CGFloat height = self.frame.size.height / 2.0;
            NSRect frame = NSMakeRect(x, y, width, height);
           
            NSImageView* imageView = [[NSImageView alloc] initWithFrame:frame];
            NSString* avatar = [user smallAvatar];
//            [imageView loadImageWithURL:avatorURL setplaceholderImage:@"man_placeholder"];
            [imageView setImageWithURL:avatar placeholderImage:@"man_placeholder"];
            [self addSubview:imageView positioned:NSWindowBelow relativeTo:nil];
            count ++;

        }
        if (count >= 4)
        {
            break;
        }
    }
  
    
}

@end
