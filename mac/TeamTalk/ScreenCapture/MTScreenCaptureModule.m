//
//  MTScreenCaptureModule.m
//  Duoduo
//
//  Created by zuoye on 15/1/15.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTScreenCaptureModule.h"
#import "CaptureWindow.h"

@implementation MTScreenCaptureModule{
    NSWindow *_myWindow;
}

+(instancetype) shareInstance{
    static MTScreenCaptureModule *g_screenCaptureModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_screenCaptureModule = [[MTScreenCaptureModule alloc] init];
    });
    return g_screenCaptureModule;
}


- (void)capture:(id)sender
{
    NSRect rect = NSMakeRect(100, 100, 600, 600);
    _myWindow = [[CaptureWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [_myWindow makeKeyAndOrderFront:nil];
}

@end
