//
//  DDSendP2PCmdAPI.h
//  Duoduo
//
//  Created by jianqing.du on 14-5-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSuperAPI.h"

#define SHAKE_WINDOW                @"shakewindow"
#define INPUTING                    @"writing"
#define STOP_INPUTING               @"stop writing"

typedef NS_ENUM(NSUInteger, P2PServiceID)
{
    SHAKE_WINDOW_SERVICEID = 1,
    INPUTING_SERVICEID = 2,
    INTRANET_SERVICEID = 3
};

typedef NS_ENUM(NSUInteger, P2PCommand)
{
    SHAKE_WINDOW_COMMAND = SHAKE_WINDOW_SERVICEID << 16 | 1,
    INPUTING_COMMAND = INPUTING_SERVICEID << 16 | 1,
    STOP_INPUTTING_COMMAND = INPUTING_SERVICEID << 16 | 2,
};


/*
 * 发送P2P命令消息
 */
@interface DDSendP2PCmdAPI : DDSuperAPI

+ (NSString*)contentFor:(int)serverID commandID:(int)commandID content:(NSString*)content;

@end
