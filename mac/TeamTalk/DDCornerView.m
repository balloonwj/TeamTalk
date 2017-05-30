//
//  DDCornerView.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-16.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDCornerView.h"

@implementation DDCornerView
- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath * path;
    path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:18 yRadius:18];
    
    [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.3] set];
    [path fill];
}
@end
