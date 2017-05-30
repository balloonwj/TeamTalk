//
//  MessageDate.h
//  Duoduo
//
//  Created by 独嘉 on 14-8-19.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDate : NSDate
+ (NSDate*)date;
+ (NSTimeInterval)dateTimeInterval;
+ (void)setLocalAndServerGap:(int)gap;
@end
