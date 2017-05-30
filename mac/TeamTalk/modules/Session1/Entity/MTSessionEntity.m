//
//  MTSessionEntity.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "MTSessionEntity.h"
#import "MTUserModule.h"
#import "MTGroupModule.h"
#import "MTDatabaseUtil.h"

@implementation MTSessionEntity

@synthesize  name;
@synthesize timeInterval;

- (void)setSessionID:(NSString *)sessionID
{
    _sessionID = [sessionID copy];
    name = nil;
    
    timeInterval = 0;
}

- (void)setSessionType:(SessionType)sessionType
{
    _sessionType = sessionType;
    name = nil;
    timeInterval = 0;
}

- (NSString*)originID
{
    NSString* realSessionID = nil;
    switch (self.sessionType)
    {
        case SessionTypeSessionTypeSingle:
            realSessionID = [self.sessionID copy];
            break;
        case SessionTypeSessionTypeGroup:
            realSessionID = [self.sessionID substringFromIndex:[DD_GROUP_SESSIONID_PREFIX length]];
            break;
    }
    return realSessionID;
}

- (NSString*)name
{
    if (!name)
    {
        switch (_sessionType)
        {
            case SessionTypeSessionTypeSingle:
            {

                MTUserEntity *user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:_originID];
                if ([user.name length] > 0)
                {
                    name = user.name;
                }
                else
                {
                    name = user.realName;
                }

            }
                break;
            case SessionTypeSessionTypeGroup:
            {
                MTGroupEntity *group = (MTGroupEntity *)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:_originID];
                if (group)
                {
                    name = group.name;
                }
            }
                break;
        }
    }
    return name ? name : @" ";
}

- (NSString*)avatar
{
    if (!_avatar)
    {
        switch (_sessionType)
        {
            case SessionTypeSessionTypeSingle:
            {
                MTUserEntity *user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:_originID];
                if (![user.avatar hasSuffix:@"_100x100.jpg"])
                {
                    _avatar = [NSString stringWithFormat:@"%@_100x100.jpg",user.avatar];
                }
                else
                {
                    _avatar = user.avatar;
                }
            }
                break;
            case SessionTypeSessionTypeGroup:
            {
                /*
                 MTGroupEntity *group = (MTGroupEntity *)[[MTGroupModule shareInsatnce]getOriginEntityWithOriginID:_originID];
                int count = 0;
                for (NSInteger index = 0; index < [group.groupUserIds count]; index ++)
                {
                    NSString* userID = group.groupUserIds[index];
                    MTUserEntity *user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
                    NSLog(@"==userId:%@ =uesr:%@ =>> %@: ",userID,user,user.avatar);
                    if (user.avatar && [user.avatar length] > 0)
                    {
                        CGFloat x = (count % 2) * (self.frame.size.width / 2.0);
                        CGFloat y = count > 1 ? (self.frame.size.height / 2.0) : 0;
                        CGFloat width = self.frame.size.width / 2.0;
                        CGFloat height = self.frame.size.height / 2.0;
                        NSRect frame = NSMakeRect(x, y, width, height);
                        
                        EGOImageView* imageView = [[EGOImageView alloc] initWithFrame:frame];
                        NSURL* avatorURL = [NSURL URLWithString:user.avatar];
                        [imageView loadImageWithURL:avatorURL setplaceholderImage:@"man_placeholder"];
                        [self addSubview:imageView positioned:NSWindowBelow relativeTo:nil];
                        //            [self addSubview:imageView];
                        count ++;
                        
                    }
                    if (count >= 4)
                    {
                        break;
                    }
                }
                 */
            }
                break;
        }
    }
    return _avatar;
}

#pragma mark -
#pragma mark Public API
- (id)initWithOriginID:(NSString*)originID type:(SessionType)type
{
    self = [super init];
    if (self)
    {
        self.originID = originID;
        self.sessionType = type;
        switch (type)
        {
            case SessionTypeSessionTypeSingle:
            {
                self.sessionID = originID;
            }
                break;
            case SessionTypeSessionTypeGroup:
            {
                NSString* sessionID = DD_GROUP_SESSIONID(originID);
                self.sessionID = sessionID;
            }
                break;
        }
    }
    return self;
}

- (void)updateUpdateTime:(NSUInteger)date
{
    self.timeInterval = date;
    [[MTDatabaseUtil instance] updateSessions:@[self]];
    
    DDLog(@"--------------------->update session time:sessionName:%@ sessionTime:%lu",self.name,(unsigned long)self.timeInterval);
}

+ (NSString*)getSessionIDForOriginID:(NSString*)originID sessionType:(SessionType)sessionType
{
    switch (sessionType)
    {
        case SessionTypeSessionTypeSingle:
        {
            return originID;
        }
            break;
        case SessionTypeSessionTypeGroup:
        {
            NSString* sessionID = DD_GROUP_SESSIONID(originID);
            return sessionID;
        }
            break;
    }
    return @"sessionID";
}

+ (NSString*)getOriginIDFromSessionID:(NSString*)sessionID
{
    if ([sessionID hasPrefix:DD_GROUP_SESSIONID_PREFIX])
    {
        NSString* originID = [sessionID stringByReplacingOccurrencesOfString:DD_GROUP_SESSIONID_PREFIX withString:@""];
        return originID;
    }
    else
    {
        return sessionID;
    }
}

+ (SessionType)getSessionTypeFromSessionID:(NSString*)sessionID
{
    if ([sessionID hasPrefix:DD_GROUP_SESSIONID_PREFIX])
    {
        return SessionTypeSessionTypeGroup;
    }
    else
    {
        return SessionTypeSessionTypeSingle;
    }
}

- (BOOL)shield
{
    switch (self.sessionType)
    {
        case SessionTypeSessionTypeSingle:
        {
            NSString* originID = self.originID;
#warning 判断用户是否被屏蔽，并且返回
//            BOOL shield = [[DDUserModule shareInstance] shieldForOrigin:originID];
            return NO;
        }
            break;
        case SessionTypeSessionTypeGroup:
        {
            NSString* originID = self.originID;
#warning 判断群是否被屏蔽，并且返回

//            BOOL shield = [[DDGroupModule shareInstance] shieldForOrigin:originID];
            return NO;
        }
            break;
    }
    return NO;
}


@end
