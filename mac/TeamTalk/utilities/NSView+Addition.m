 //
//  NSView+Addition.m
//  Duoduo
//
//  Created by 独嘉 on 14-2-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSView+Addition.h"
/**
 *  NSView category
 */
@implementation NSView (Addition)

#pragma Getter
- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)right
{
    return self.x + self.width;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)up
{
    return self.y + self.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

#pragma Setter
- (void)setX:(CGFloat)x
{
    NSRect newRect = NSMakeRect(x, self.y, self.width, self.height);
    [self setFrame:newRect];
}

- (void)setRight:(CGFloat)right
{
    CGFloat width = self.width;
    CGFloat x = right - width;
    [self setX:x];
}

- (void)setY:(CGFloat)y
{
    NSRect newRect = NSMakeRect(self.x, y, self.width, self.height);
    [self setFrame:newRect];
}

- (void)setUp:(CGFloat)up
{
    CGFloat height = self.height;
    CGFloat y = up - height;
    [self setY:y];
}

- (void)setWidth:(CGFloat)width
{
    NSRect newRect = NSMakeRect(self.x, self.y, width, self.height);
    [self setFrame:newRect];
}

- (void)setHeight:(CGFloat)height
{
    NSRect newRect = NSMakeRect(self.x, self.y, self.width, height);
    [self setFrame:newRect];
}
@end
