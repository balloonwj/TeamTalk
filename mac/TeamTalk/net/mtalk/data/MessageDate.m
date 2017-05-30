//
//  MessageDate.m
//  Duoduo
//
//  Created by 独嘉 on 14-8-19.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "MessageDate.h"

static int _gap = 0;

@implementation MessageDate
+ (NSDate*)date
{
    NSDate * date = [[NSDate date] dateByAddingTimeInterval:_gap];
    return date;
}

+ (NSTimeInterval)dateTimeInterval
{
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    date += _gap;
    return date;
}

+ (void)setLocalAndServerGap:(int)gap
{
    _gap = gap;
}

@end
