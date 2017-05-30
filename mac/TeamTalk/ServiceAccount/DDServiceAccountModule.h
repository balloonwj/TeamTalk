//
//  DDServiceAccountModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-8-10.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ServiceAction)
{
    ActionNone,
    ActionBang
};

@interface DDServiceAccountModule : NSObject
+ (instancetype)shareInstance;

/**
 *  是否是服务号
 *
 *  @param userID 查询的用户ID
 *
 *  @return 结果
 */
- (BOOL)isServiceAccount:(NSString*)userID;

/**
 *  小T发送老黄历
 */
- (void)sendAlmanac;

/**
 *  小Test发送摇一摇
 */
- (void)sendBang;

/**
 *  Action识别
 *
 *  @param content 待识别内容
 *
 *  @return 动作
 */
- (ServiceAction)regcognizeTheAction:(NSString*)content;

- (NSString*)recognizeTheContent:(NSString*)sender;

- (void)performTheAction:(ServiceAction)serviceAction withContent:(NSString*)content;
@end
