//
//  DDUserInfoPanel.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserInfoPanel.h"

@implementation DDUserInfoPanel
- (BOOL)canBecomeMainWindow
{
    return YES;
}

// Much like above method.
- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)sendEvent:(NSEvent *)theEvent
{
    //	Delegate wasn’t interested, so do the usual routing.
    if ([theEvent type] == NSLeftMouseDragged)
    {
        [self setFrameOrigin:NSMakePoint(self.frame.origin.x + [theEvent deltaX], self.frame.origin.y - [theEvent deltaY])];
    }
    [super sendEvent:theEvent];
}

@end
