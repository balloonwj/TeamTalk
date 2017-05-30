//
//  CaptureWindow.h
//  MyCapture
//
//  Created by jianqing.du on 13-11-26.
//  Copyright (c) 2013年 ziteng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "DDScreenCaptureModule.h"

@class BackgroudView;

@interface CaptureWindow : NSWindow
{
    // These points are used in dragging to mark capture region
    NSPoint startLocation;
    NSPoint currentLocation;
    
    NSImage* originImage;
    NSImage* darkImage;
    
    CFArrayRef windowList;
    
    int captureState;
    NSRect captureWindowRect;
    
    int dragDirection;
    
    IBOutlet id myView;
    NSButton *okButton;
    NSButton *cancelButton;
    NSButton *ellipseButton;
    NSButton *rectButton;
    BackgroudView *backgroundView;
}

- (void)captureScreen;
+(CaptureWindow *)shareInsatnce;
@end
