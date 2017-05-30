//
//  CaptureWindow.m
//  MyCapture
//
//  Created by jianqing.du on 13-11-26.
//  Copyright (c) 2013年 ziteng. All rights reserved.
//

#import "CaptureWindow.h"
#import "CaptureView.h"
#import "BackgroudView.h"
#import "MTScreenCaptureModule.h"
#import "DDInterfaceController.h"
#import "DDWindowAdditions.h"
#define BUTTON_SIZE 32

enum {
    CAPTURE_STATE_IDLE,
    CAPTURE_STATE_CAPTURING,
    CAPTURE_STATE_DONE,
    CAPTURE_STATE_DRAG,
    CAPTURE_STATE_SCALE,
    CAPTURE_STATE_DRAW_ELLIPSE,
    CAPTURE_STATE_DRAW_RECT,
};


@implementation CaptureWindow

+(CaptureWindow *)shareInsatnce{
    static CaptureWindow *g_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
       // g_instance = [[CaptureWindow alloc] initWithCoder:];
    });
    
    return g_instance;
}


/*
 In Interface Builder, the class for the window is set to this subclass. Overriding the initializer provides a mechanism for controlling how objects of this class are created.
 */
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    captureState = CAPTURE_STATE_IDLE;
    
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    if (self == nil) {
        return nil;
    }
    
    // 由于setBackgroundColor时要用用darkImage，所以需要先抓整屏
    [self captureScreen];
   
    [self setLevel:NSStatusWindowLevel];
    [self setBackgroundColor:[NSColor colorWithPatternImage:darkImage]];
    
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    [self setFrame:screenFrame display:YES animate:YES];
    
    myView = [[CaptureView alloc] initWithFrame:contentRect];
    NSView *superView = [self contentView];
    [superView addSubview:myView];
    
    [self setAcceptsMouseMovedEvents:YES];
    
    [self captureAppScreen];
    
    return self;
}

/*
 Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)onOK
{
    DDLog(@"OK button click");
    
    // 把选择的截图保存到粘贴板
    [originImage lockFocus];
    // 画上注释的框
    [myView drawCommentRect];
    
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:captureWindowRect];
    
    [originImage unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    
    
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];

    NSImage *pasteImage = [[NSImage alloc] initWithData:imageData];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard writeObjects: [NSArray arrayWithObject:pasteImage]];
    

    //发布截图确定事件.
    //截图点击确定.
     [self orderOut:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_screen_capture_ok" object:nil];
    
   
}




- (void)onCancel
{
    DDLog(@"Cancel button click");
    [self orderOut:nil];
}

- (void)onEllipse
{
    captureState = CAPTURE_STATE_DRAW_ELLIPSE;
    [myView setDrawDragPoints:NO];  // 画注释框时就不画拖拽点了
    DDLog(@"ellipse button click");
}

- (void)onRect
{
    captureState = CAPTURE_STATE_DRAW_RECT;
    [myView setDrawDragPoints:NO];  // 画注释框时就不画拖拽点了
    DDLog(@"rect button click");
}


#pragma mark mouse/keyboard event
- (void)mouseUp:(NSEvent *)theEvent
{
    if (captureState == CAPTURE_STATE_CAPTURING) {
        captureState = CAPTURE_STATE_DONE;
        
        currentLocation = [theEvent locationInWindow];
        DDLog(@"stop position: %@", NSStringFromPoint(currentLocation));

        // get mouse move rectangle
        NSRect mouseRect = [self currentRect];
        
        // width and height are float, so use compare
        if (mouseRect.size.width < 0.1 || mouseRect.size.height < 0.1) {
            DDLog(@"capture app window");
        } else {
            DDLog(@"capture mouse drag");
            captureWindowRect = mouseRect;
        }
    } else if (captureState == CAPTURE_STATE_DRAG) {
        captureState = CAPTURE_STATE_DONE;
    } else if (captureState == CAPTURE_STATE_SCALE) {
        captureState = CAPTURE_STATE_DONE;
    } else {
        return;
    }
    
    [myView setDrawDragPoints:YES];
    [myView setDrawImage:originImage inRect:captureWindowRect];
    
    
    NSView *superView = [self contentView];
    
    // 按钮后面添加黑色背景
    float backgroundX = captureWindowRect.origin.x + captureWindowRect.size.width - 4 * BUTTON_SIZE;
    float backgroundY = captureWindowRect.origin.y - BUTTON_SIZE;
    if (backgroundX < 0) {
        backgroundX = 0;
    }
    
    if (backgroundY < 0) {
        backgroundY = 0;
    }
    
    NSRect backgrounRect = NSMakeRect(backgroundX, backgroundY, 4 * BUTTON_SIZE + 100, BUTTON_SIZE + 100);
    backgroundView = [[BackgroudView alloc] initWithFrame:backgrounRect];
    [backgroundView setNeedsDisplay:YES];
    
    
    [superView addSubview:backgroundView positioned:NSWindowAbove relativeTo:myView];
    
    
    // 截屏后面添加ok和cancel按钮
    NSRect okRect;
    float x = captureWindowRect.origin.x + captureWindowRect.size.width - BUTTON_SIZE;
    float y = captureWindowRect.origin.y - BUTTON_SIZE;
    if (x < 3 * BUTTON_SIZE) {
        x = 3 * BUTTON_SIZE;
    }
    if (y < 0) {
        y = 0;
    }
    okRect = NSMakeRect(x, y, BUTTON_SIZE, BUTTON_SIZE);
    
    okButton = [[NSButton alloc] initWithFrame:okRect];
    //[okButton setTitle:@"OK"];
    NSImage *okImage = [NSImage imageNamed:@"ScreenCapture_toolbar_ok"];
    [okButton setImage:okImage];
    [okButton setTarget:self];
    [okButton setAction:@selector(onOK)];
   
    [superView addSubview:okButton positioned:NSWindowAbove relativeTo:backgroundView];
    
    NSRect cancelRect = NSMakeRect(x - BUTTON_SIZE, y, BUTTON_SIZE, BUTTON_SIZE);
    
    cancelButton = [[NSButton alloc] initWithFrame:cancelRect];
    //[cancelButton setTitle:@"Cancel"];
    NSImage *cancelImage = [NSImage imageNamed:@"ScreenCapture_toolbar_cancel"];
    [cancelButton setImage:cancelImage];
    [cancelButton setTarget:self];
    [cancelButton setAction:@selector(onCancel)];
    [superView addSubview:cancelButton positioned:NSWindowAbove relativeTo:backgroundView];
    
    NSRect ellipseRect = NSMakeRect(x - 2 * BUTTON_SIZE, y, BUTTON_SIZE, BUTTON_SIZE);
    ellipseButton = [[NSButton alloc] initWithFrame:ellipseRect];
    [ellipseButton setImage:[NSImage imageNamed:@"ScreenCapture_toolbar_ellipse"]];
    [ellipseButton setTarget:self];
    [ellipseButton setAction:@selector(onEllipse)];
    [superView addSubview:ellipseButton positioned:NSWindowAbove relativeTo:backgroundView];
    
    NSRect rectBtnRect = NSMakeRect(x - 3 * BUTTON_SIZE, y, BUTTON_SIZE, BUTTON_SIZE);
    rectButton = [[NSButton alloc] initWithFrame:rectBtnRect];
    [rectButton setImage:[NSImage imageNamed:@"ScreenCapture_toolbar_rect"]];
    [rectButton setTarget:self];
    [rectButton setAction:@selector(onRect)];
    [superView addSubview:rectButton positioned:NSWindowAbove relativeTo:backgroundView];
    
    [okButton setBordered:NO];
    [cancelButton setBordered:NO];
    [ellipseButton setBordered:NO];
    [rectButton setBordered:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // 双击截屏
	if ( [theEvent clickCount] == 2 ) {
        [self onOK];
        return;
    }
    
    if (captureState == CAPTURE_STATE_CAPTURING) {
        startLocation = [theEvent locationInWindow];
        DDLog(@"start position: %@", NSStringFromPoint(startLocation));
    } else if (captureState == CAPTURE_STATE_DONE) {
        startLocation = [theEvent locationInWindow];
        dragDirection = [myView isInDragPoints:startLocation];
        DDLog(@"drag direction: %i", dragDirection);
        
        if (dragDirection != -1) {
            [okButton removeFromSuperview];
            [cancelButton removeFromSuperview];
            [ellipseButton removeFromSuperview];
            [rectButton removeFromSuperview];
            [backgroundView removeFromSuperview];
            
            if (dragDirection == 8) {
                captureState = CAPTURE_STATE_DRAG;
            } else {
                captureState = CAPTURE_STATE_SCALE;
            }
        }
    } else if (captureState == CAPTURE_STATE_DRAW_ELLIPSE) {
        startLocation = [theEvent locationInWindow];
        [myView newEllipseRect:NSZeroRect];
        DDLog(@"start draw ellipse");
    } else if (captureState == CAPTURE_STATE_DRAW_RECT) {
        startLocation = [theEvent locationInWindow];
        [myView newRectangleRect:NSZeroRect];
        DDLog(@"start draw rect");
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (captureState == CAPTURE_STATE_CAPTURING) {
        currentLocation = [theEvent locationInWindow];
    
        NSRect rect = [self currentRect];
        [myView setDrawImage:originImage inRect:rect];
    } else if (captureState == CAPTURE_STATE_DRAG) {
        currentLocation = [theEvent locationInWindow];
        CGFloat deltaX = currentLocation.x - startLocation.x;
        CGFloat deltaY = currentLocation.y - startLocation.y;
        
        NSRect rect = captureWindowRect;
        rect.origin.x += deltaX;
        rect.origin.y += deltaY;
        captureWindowRect = rect;
        [myView setDrawImage:originImage inRect:captureWindowRect];
        
        startLocation = currentLocation;
    } else if (captureState == CAPTURE_STATE_SCALE) {
        currentLocation = [theEvent locationInWindow];
        CGFloat deltaX = currentLocation.x - startLocation.x;
        CGFloat deltaY = currentLocation.y - startLocation.y;
        
        switch (dragDirection) {
            case 0: // user drag lower-left corner point
                captureWindowRect.origin.x += deltaX;
                captureWindowRect.origin.y += deltaY;
                captureWindowRect.size.width -= deltaX;
                captureWindowRect.size.height -= deltaY;
                break;
            case 1: // user drag middle-left point
                captureWindowRect.origin.x += deltaX;
                captureWindowRect.size.width -= deltaX;
                break;
            case 2: // user drag upper-left corner point
                captureWindowRect.origin.x += deltaX;
                captureWindowRect.size.width -= deltaX;
                captureWindowRect.size.height += deltaY;
                break;
            case 3: // user drag middle-upper point
                captureWindowRect.size.height += deltaY;
                break;
            case 4: // user drag upper-right corner point
                captureWindowRect.size.width += deltaX;
                captureWindowRect.size.height += deltaY;
                break;
            case 5: // user drag middle-right point
                captureWindowRect.size.width += deltaX;
                break;
            case 6: // user drag lower-right corner point
                captureWindowRect.origin.y += deltaY;
                captureWindowRect.size.width += deltaX;
                captureWindowRect.size.height -= deltaY;
                break;
            case 7: // user drag middle-lower point
                captureWindowRect.origin.y += deltaY;
                captureWindowRect.size.height -= deltaY;
                break;
        }
        
        [myView setDrawImage:originImage inRect:captureWindowRect];
        
        startLocation = currentLocation;
    } else if (captureState == CAPTURE_STATE_DRAW_ELLIPSE) {
        currentLocation = [theEvent locationInWindow];
        
        NSRect rect = [self currentRect];
        [myView setEllipseRect:rect];
    } else if (captureState == CAPTURE_STATE_DRAW_RECT) {
        currentLocation = [theEvent locationInWindow];
        
        NSRect rect = [self currentRect];
        [myView setRectangleRect:rect];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (captureState == CAPTURE_STATE_CAPTURING) {
        [self captureAppScreen];
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    switch([theEvent keyCode]) {
        case 53: // esc
            DDLog(@"ESC");
            [self orderOut:nil];
            // Call the full-screen mode method
            break;
        default:
            [super keyDown:theEvent];
    }
}

- (NSRect)currentRect
{
    float minX = MIN(startLocation.x, currentLocation.x);
    float maxX = MAX(startLocation.x, currentLocation.x);
    float minY = MIN(startLocation.y, currentLocation.y);
    float maxY = MAX(startLocation.y, currentLocation.y);
    
    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

- (CGImageRef)screenShot
{
    CFArrayRef windowsRef = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        
    NSRect rect = [[NSScreen mainScreen] frame];
    CGImageRef imgRef = CGWindowListCreateImageFromArray(rect, windowsRef, kCGWindowImageDefault);
    
    CFRelease(windowsRef);

    return imgRef;
}

- (void)captureScreen
{
    captureState = CAPTURE_STATE_CAPTURING;
    
    // 获取所有OnScreen的窗口
    windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly |kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    //DDLog(CFSTR("Array: %@"), windowList);
    
    CGImageRef imgRef = [self screenShot];
    
    NSRect mainFrame = [[NSScreen mainScreen] frame];
    originImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    darkImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    CGImageRelease(imgRef);
    
    // 对darkImage做暗化处理
    [darkImage lockFocus];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
    NSRectFillUsingOperation(mainFrame, NSCompositeSourceAtop);
    [darkImage unlockFocus];
}

- (BOOL)isPoint: (NSPoint)point inRect: (NSRect)rect
{
    if ( point.x >= rect.origin.x
        && point.x <= (rect.origin.x + rect.size.width)
        && point.y >= rect.origin.y
        && point.y <= (rect.origin.y + rect.size.height) ) {
        return YES;
    } else {
        return NO;
    }
}

// clip the application window to the display screen, reserve 1 pixel for draw box line
- (NSRect)clipWindowRect:(NSRect)windowRect
{
    NSRect mainFrame = [[NSScreen mainScreen] frame];
    
    if (windowRect.origin.x < 0) {
        windowRect.size.width += windowRect.origin.x;
        windowRect.origin.x = 1;
    }
    
    if (windowRect.origin.y < 0) {
        windowRect.size.height += windowRect.origin.y;
        windowRect.origin.y = 1;
    }
    
    if (windowRect.origin.x + windowRect.size.width >= mainFrame.size.width) {
        windowRect.size.width = mainFrame.size.width - windowRect.origin.x -1;
    }
    
    if (windowRect.origin.y + windowRect.size.height >= mainFrame.size.height) {
        windowRect.size.height = mainFrame.size.height - windowRect.origin.y -1;
    }
    
    return windowRect;
}

- (void)captureAppScreen
{
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    
    //DDLog(@"mouse scroll wheel: %@", NSStringFromPoint(mouseLocation));
    
    NSRect mainFrame = [[NSScreen mainScreen] frame];
    CFIndex cnt = CFArrayGetCount(windowList);
    for (CFIndex i = 0; i < cnt; i++) {
        NSDictionary *dict = (NSDictionary *)CFArrayGetValueAtIndex(windowList, i);
        NSRect windowRect;;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)[dict objectForKey:(id)kCGWindowBounds], &windowRect);
        
        // 转换坐标系
        windowRect.origin.y = mainFrame.size.height - windowRect.origin.y -
        windowRect.size.height;
        
        int layer = 0;
        CFNumberRef numberRef = (__bridge CFNumberRef)[dict objectForKey: (id)kCGWindowLayer];
        CFNumberGetValue(numberRef, kCFNumberSInt32Type, &layer);
        if (layer == 0 && [self isPoint: mouseLocation inRect: windowRect]) {
            /*DDLog(@"mouse in, %li, x=%f, y=%f, width=%f, heigth=%f, name=%@",
                  i, windowRect.origin.x, windowRect.origin.y,windowRect.size.width,windowRect.size.height, [dict objectForKey: (id)kCGWindowName]);*/
            
            captureWindowRect = [self clipWindowRect:windowRect];
            [myView setDrawImage:originImage inRect:captureWindowRect];
            return;
        }
        
    }

}

@end
