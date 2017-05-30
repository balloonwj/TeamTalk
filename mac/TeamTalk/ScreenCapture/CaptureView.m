//
//  CaptureView.m
//  MyCapture
//
//  Created by jianqing.du on 13-11-25.
//  Copyright (c) 2013年 ziteng. All rights reserved.
//

#import "CaptureView.h"


@implementation CaptureView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSRect frame = [[NSScreen mainScreen] frame];
        [self setFrame:frame];
        
        // track mouseMoved event when inactive
        trackingArea = [[NSTrackingArea alloc] initWithRect:frame options:NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
        [self addTrackingArea: trackingArea];
        
        drawDragPoints = NO;
        rectPath = [NSBezierPath bezierPath];
        [rectPath setLineWidth:1.5];
        
        for (int i = 0; i < DRAG_POINT_NUM; i++) {
            dragPath[i] = [NSBezierPath bezierPath];
            [dragPath[i] setLineWidth:1.0];
            
            dragRect[i].size.width = DRAG_POINT_LEN;
            dragRect[i].size.height = DRAG_POINT_LEN;
        }
        
        drawCommentPath = [NSBezierPath bezierPath];
        drawComment = NO;
        [drawCommentPath setLineWidth:2.0];
        ellipseCnt = rectCnt = 0;
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    // Drawing code here.
    if (image) {
        [image drawInRect:drawingRect fromRect:drawingRect operation:NSCompositeCopy fraction:1.0];
        
        [[NSColor blueColor] set];
        
        [rectPath removeAllPoints];
        [rectPath appendBezierPathWithRect:drawingRect];
        [rectPath stroke];
        
        
        if (drawDragPoints) {
            [[NSColor whiteColor] set];
            for (int i = 0; i < DRAG_POINT_NUM; i++) {
                [dragPath[i] removeAllPoints];
                [dragPath[i] appendBezierPathWithOvalInRect:dragRect[i]];
                [dragPath[i] fill];
            }
        }
        
        [self drawCommentRect];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)setDrawImage:(NSImage* )newImage inRect: (NSRect)rect
{
    image = newImage;
    drawingRect = rect;
    //DDLog(@"set new image");
    
    // lower-left corner point
    dragRect[0].origin.x = rect.origin.x;
    dragRect[0].origin.y = rect.origin.y;
    
    // middle-left point
    dragRect[1].origin.x = rect.origin.x;
    dragRect[1].origin.y = rect.origin.y + rect.size.height / 2.0;
    
    // upper-left corner point
    dragRect[2].origin.x = rect.origin.x;
    dragRect[2].origin.y = rect.origin.y + rect.size.height;
    
    // middle-upper point
    dragRect[3].origin.x = rect.origin.x + rect.size.width / 2.0;
    dragRect[3].origin.y = rect.origin.y + rect.size.height;
    
    // upper-right corner point
    dragRect[4].origin.x = rect.origin.x + rect.size.width;
    dragRect[4].origin.y = rect.origin.y + rect.size.height;
    
    // middle-right point
    dragRect[5].origin.x = rect.origin.x + rect.size.width;
    dragRect[5].origin.y = rect.origin.y + rect.size.height / 2.0;
    
    // lower-right corner point
    dragRect[6].origin.x = rect.origin.x + rect.size.width;
    dragRect[6].origin.y = rect.origin.y;
    
    // middle-lower point
    dragRect[7].origin.x = rect.origin.x + rect.size.width / 2.0;
    dragRect[7].origin.y = rect.origin.y;
    
    // 修正位置，x,y都减少DRAG_POINT_LEN / 2
    for (int i = 0; i < DRAG_POINT_NUM; i++) {
        dragRect[i].origin.x -= DRAG_POINT_LEN / 2;
        dragRect[i].origin.y -= DRAG_POINT_LEN / 2;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)setDrawDragPoints:(BOOL)flag
{
    drawDragPoints = flag;
    [self setNeedsDisplay:YES];
}

/*
 * 0 - 7: scale the capture window
 * 8: drag the window
 * -1: do nothing
 */
- (int)isInDragPoints:(NSPoint)point
{
    for (int i = 0; i < DRAG_POINT_NUM; i++) {
        if ([dragPath[i] containsPoint:point]) {
            return i;
        }
    }
    
    if ([rectPath containsPoint:point]) {
        return DRAG_POINT_NUM;
    }
    
    return -1;
}

- (void)newEllipseRect:(NSRect)rect
{
    if (ellipseCnt >= MAX_ELLIPSE_NUM) {
        return;
    }
    
    drawComment = YES;
    ellipseRect[ellipseCnt++] = rect;
}

- (void)setEllipseRect:(NSRect)rect
{
    ellipseRect[ellipseCnt - 1] = rect;
    [self setNeedsDisplay:YES];
}

- (void)newRectangleRect:(NSRect)rect
{
    if (rectCnt >= MAX_RECT_NUM) {
        return;
    }
    
    drawComment = YES;
    rectRect[rectCnt++] = rect;
}

- (void)setRectangleRect:(NSRect)rect
{
    //DDLog(@"rectCnt=%lu, (%.0f, %.0f, %.0f, %.0f", rectCnt, rect.origin.x,
    //      rect.origin.y, rect.size.width, rect.size.height);
    rectRect[rectCnt - 1] = rect;
    [self setNeedsDisplay:YES];
}

- (void)drawCommentRect
{
    if (drawComment) {
        [[NSColor redColor] set];
        for (NSInteger i = 0; i < ellipseCnt; i++) {
            [drawCommentPath removeAllPoints];
            [drawCommentPath appendBezierPathWithOvalInRect:ellipseRect[i]];
            [drawCommentPath stroke];
        }
        
        for (NSInteger i = 0; i < rectCnt; i++) {
            [drawCommentPath removeAllPoints];
            [drawCommentPath appendBezierPathWithRect:rectRect[i]];
            [drawCommentPath stroke];
        }
    }
}

@end
