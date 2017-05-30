//
//  DDUserInfoManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDUserDataWindowController,MTUserEntity,DDUserDataModel,DDUserInfoPanel;
/**
 *  管理显示个人资料
 */
@interface DDUserInfoManager : NSObject
{
    DDUserDataWindowController* _userDataWindowController;
    DDUserInfoPanel* _userInfoPanel;
    DDUserDataModel* _model;
}
+ (id)instance;

/**
 *  显示用户资料界面，若用户是非小仙小侠帐号则给出提示
 *
 *  @param user   待显示的用户
 *  @param sender context
 */
- (void)showUser:(MTUserEntity*)user forContext:(id)sender;

- (void)showUserForBang:(MTUserEntity*)user context:(id)sender;

- (void)hidePanel;
@end
