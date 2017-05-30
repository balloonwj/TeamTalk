//
//  NSWindow+Addition.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSWindow+Addition.h"

@implementation NSWindow (Addition)
- (void)addCloseButtonAtTopLeft
{
    [self setStyleMask:NSBorderlessWindowMask];
    NSButton* button = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:self.styleMask];
    CGFloat y = [(NSView*)self.contentView bounds].size.height - button.bounds.size.height - 10;
    
    [button setFrame:NSMakeRect(10, y, button.bounds.size.width, button.bounds.size.height)];
    [self.contentView addSubview:button positioned:NSWindowAbove relativeTo:nil];
}
@end
