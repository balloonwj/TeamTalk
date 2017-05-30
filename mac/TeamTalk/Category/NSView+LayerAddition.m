//
//  NSView+LayerAddition.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSView+LayerAddition.h"

@implementation NSView (LayerAddition)
- (void)setShadow:(NSColor*)color
           offset:(NSSize)offset
          opacity:(CGFloat)opacity
{
//    [self setWantsLayer: YES];
//    [self.layer setShadowColor:color.CGColor];
//    [self.layer setShadowOffset:offset];
//    [self.layer setShadowOpacity:opacity];
    
    
//    NSPoint p = [self convertPoint:[self bounds].origin
//                          fromView:self];
//    NSRect rect = NSMakeRect(p.x,p.y-[self bounds].size.height,
//                             [self bounds].size.width,[self bounds].size.height);
//    NSBezierPath *myPath = [NSBezierPath bezierPathWithRect:rect];
//    [self allocateGState];
//    NSShadow *shadow = [[NSShadow alloc] init];
//    [shadow setShadowBlurRadius: 10];
//    [shadow setShadowOffset: offset];
//    [shadow setShadowColor:[color colorWithAlphaComponent:opacity]];
//    [shadow set];
//
//    [[NSColor blackColor] set];
//    [myPath stroke];
//    [[NSColor whiteColor] set];
//    [myPath fill];
//    [self releaseGState];
}
@end
