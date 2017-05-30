//
//  DDApplicationUpdate.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDApplicationUpdate.h"
#import <Sparkle/Sparkle.h>
static NSInteger const updateCheckTimeInterval = 60 * 30;

@implementation DDApplicationUpdate
{
    NSTimer* _checkUpdateTimer;
}
+ (instancetype)instance
{
    static DDApplicationUpdate* g_applicationUpdate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_applicationUpdate = [[DDApplicationUpdate alloc] init];
    });
    return g_applicationUpdate;
}

- (void)startAutoCheckUpdate
{
    if (!_checkUpdateTimer)
    {
        _checkUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateCheckTimeInterval target:self selector:@selector(checkoutUpdateInBackground) userInfo:nil repeats:YES];
    }
}

- (void)startAutoCheckUpdateAtOnce
{
    if (_checkUpdateTimer)
    {
        [_checkUpdateTimer invalidate];
        _checkUpdateTimer = nil;
    }
    
    _checkUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateCheckTimeInterval target:self selector:@selector(checkoutUpdateInBackground) userInfo:nil repeats:YES];
    [_checkUpdateTimer fire];
}

- (void)checkoutUpdateInBackground
{
    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}
@end
