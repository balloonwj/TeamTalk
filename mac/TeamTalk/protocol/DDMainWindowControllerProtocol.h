//
//  DDMainWindowControllerProtocol.h
//  Duoduo
//
//  Created by zuoye on 13-12-2.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDControllerProtocol.h"


@protocol DDMainWindowControllerProtocol <DDControllerProtocol>

-(void)openChat:(NSString *)name icon:(NSImage *)icon;
//用户新消息通知
-(void)notifyUserNewMsg:(NSString*)uid title:(NSString*)title content:(NSString*)content;
@end
