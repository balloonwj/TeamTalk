//
//  DDUserInfoManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserInfoManager.h"
#import "DDUserDataWindowController.h"
#import "DDUserDataModel.h"
#import "MTUserEntity.h"
#import "DDAlertWindowController.h"
@implementation DDUserInfoManager

+ (id)instance
{
    static DDUserInfoManager* g_userInfoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_userInfoManager = [[DDUserInfoManager alloc] init];
    });
    return g_userInfoManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _userDataWindowController = [[DDUserDataWindowController alloc] initWithWindowNibName:@"DDUserInfoPanel"];
        _model = [[DDUserDataModel alloc] init];
        _userDataWindowController.model = _model;
    }
    return self;
}

- (void)showUser:(MTUserEntity*)user forContext:(id)sender
{
    [_userDataWindowController.window center];
    _model.showUser = user;
    [_userDataWindowController.window makeKeyAndOrderFront:nil];
    
//    if((user.userRole & 0x20000000) != 0){
//        
//        [[DDAlertWindowController  defaultControler] showAlertWindow:nil title:@"提示" info:@"我是公众帐号." leftBtnName:@"" midBtnName:@"" rightBtnName:@"确定"];
//    }else if((user.userRole & 0xC0000000) != 0){
//        _model.showUser = user;
//        [_userDataWindowController.window makeKeyAndOrderFront:nil];
//        [_userDataWindowController.window center];
//        
//    }else{
//        [[DDAlertWindowController  defaultControler] showAlertWindow:nil title:@"提示" info:@"不能查看非小仙小侠的个人信息." leftBtnName:@"" midBtnName:@"" rightBtnName:@"确定"];
//    }
}

- (void)showUserForBang:(MTUserEntity*)user context:(id)sender
{
    
}

- (void)hidePanel
{
    if (_userDataWindowController)
    {
        [_userDataWindowController.window orderOut:nil];
    }
}

@end
