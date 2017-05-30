//
//  DDAppBackgroundColorView.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAppBackgroundColorView.h"

@implementation DDAppBackgroundColorView
- (void)drawRect:(NSRect)dirtyRect
{
    NSColor* backgroundColor = [NSColor colorWithDeviceRed:234.0 / 255.0
                                                     green:234.0 / 255.0
                                                      blue:234.0 / 255.0
                                                     alpha:1];
    [backgroundColor set];
    [[NSBezierPath bezierPath] fill];
}
@end
