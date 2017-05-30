//
//  DDGroupInfoManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTGroupEntity,DDGroupDataWindow,DDGroupDataModule;
@interface DDGroupInfoManager : NSObject
{
    DDGroupDataModule* _model;
    DDGroupDataWindow* _groupInfoWindowController;
}
+ (DDGroupInfoManager*)instance;

/**
 *  显示组信息
 *
 *  @param showGroup 待显示的组
 *  @param context   context
 */
- (void)showGroup:(MTGroupEntity*)showGroup context:(id)context;

- (void)hideGroupUserInfo;
@end
