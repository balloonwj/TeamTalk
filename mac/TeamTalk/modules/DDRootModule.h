//
//  DDRootModule.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DDRootModule : NSObject
@property (nonatomic,assign,readonly)BOOL observerClientState;
@property (nonatomic,assign,readonly)BOOL observerNetWorkState;
@property (nonatomic,assign,readonly)BOOL observerDataSate;
@property (nonatomic,assign,readonly)BOOL observerUserOnlineState;
/**
 *  注册观察用户登录状态
 */
- (void)registObserveClientState;

/**
 *  注册观察网络状态
 */
- (void)registObserveNetWorkState;

/**
 *  注册观察数据准备状态
 */
- (void)registObserveDataReadyState;

/**
 * 注册观察用户在线状态
 */
- (void)registObserveUserOnlineState;
@end
