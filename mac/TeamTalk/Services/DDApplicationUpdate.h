//
//  DDApplicationUpdate.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDApplicationUpdate : NSObject
+ (instancetype)instance;

/**
 *  开始自动更新，不立刻开始，而是根据定时器时间而定
 */
- (void)startAutoCheckUpdate;

/**
 *  马上开始自动更新
 */
- (void)startAutoCheckUpdateAtOnce;

/**
 *  在后台检测更新
 */
- (void)checkoutUpdateInBackground;
@end
