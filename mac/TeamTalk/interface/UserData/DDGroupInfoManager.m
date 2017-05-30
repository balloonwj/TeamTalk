//
//  DDGroupInfoManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupInfoManager.h"
#import "DDGroupDataWindow.h"
#import "DDGroupDataModule.h"
@implementation DDGroupInfoManager
+ (DDGroupInfoManager*)instance
{
    static DDGroupInfoManager* g_groupInfoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_groupInfoManager = [[DDGroupInfoManager alloc] init];
    });
    return g_groupInfoManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _groupInfoWindowController = [[DDGroupDataWindow alloc] initWithWindowNibName:@"DDGroupDataWindow"];
        _model = [[DDGroupDataModule alloc] init];
        _groupInfoWindowController.module = _model;
    }
    return self;
}

- (void)showGroup:(MTGroupEntity*)showGroup context:(id)context
{
    _model.showGroup = showGroup;
    [_groupInfoWindowController.window makeKeyAndOrderFront:nil];
    [_groupInfoWindowController.window center];

}

- (void)hideGroupUserInfo
{
    if (_groupInfoWindowController)
    {
        [_groupInfoWindowController.window orderOut:nil];
    }
}
@end
