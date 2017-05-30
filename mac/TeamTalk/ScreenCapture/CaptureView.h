//
//  CaptureView.h
//  MyCapture
//
//  Created by jianqing.du on 13-11-25.
//  Copyright (c) 2013年 ziteng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DRAG_POINT_NUM  8
#define DRAG_POINT_LEN  6

// 最多只能画32个椭圆和矩形框
#define MAX_ELLIPSE_NUM 32
#define MAX_RECT_NUM    32

@interface CaptureView : NSView
{
    NSImage *image;
    NSRect drawingRect;
    NSTrackingArea *trackingArea;
    BOOL drawDragPoints;
    
    NSBezierPath *rectPath;         // 截屏框
    
    // 左下角空心圆开始，按顺时针顺序的8个拖动空心圆
    NSBezierPath *dragPath[DRAG_POINT_NUM];
    NSRect dragRect[DRAG_POINT_NUM];
    
    // 画椭圆或矩形注释
    NSBezierPath *drawCommentPath;
    BOOL drawComment;
    
    NSRect ellipseRect[MAX_ELLIPSE_NUM];
    NSInteger ellipseCnt;
    NSRect rectRect[MAX_RECT_NUM];
    NSInteger rectCnt;
}

- (void)setDrawImage:(NSImage* )newImage inRect: (NSRect)rect;
- (void)setDrawDragPoints:(BOOL)flag;
- (int)isInDragPoints:(NSPoint)point;

- (void)newEllipseRect:(NSRect)rect;
- (void)setEllipseRect:(NSRect)rect;
- (void)newRectangleRect:(NSRect)rect;
- (void)setRectangleRect:(NSRect)rect;

- (void)drawCommentRect;

@end
