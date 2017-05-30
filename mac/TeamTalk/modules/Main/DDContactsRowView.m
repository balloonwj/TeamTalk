//
//  DDContactsRowView.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-28.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDContactsRowView.h"

@implementation DDContactsRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
//    [self drawBackgroundInRect:dirtyRect];
	[self drawSelectionInRect:dirtyRect];
//    [self drawSeparatorInRect:dirtyRect];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
//    NSColor *primaryColor = [[NSColor alternateSelectedControlColor] colorWithAlphaComponent:0.5];
    NSColor *primaryColor = [NSColor colorWithCalibratedRed:32.0/255.0
                                                      green:109.0/255.0
                                                       blue:182.0/255.0
                                                      alpha:1];
//    NSColor *secondarySelectedControlColor = [[NSColor secondarySelectedControlColor] colorWithAlphaComponent:0.5];
    
    // Implement our own custom alpha drawing
    switch (self.selectionHighlightStyle) {
        case NSTableViewSelectionHighlightStyleRegular: {
            if (self.selected) {
                [backgroundImage setHidden:YES];
                [primaryColor set];
                [NSBezierPath fillRect:dirtyRect];
//                if (self.emphasized) {
//                    [primaryColor set];
//                } else {
//                    [secondarySelectedControlColor set];
//                }
//                NSRect bounds = self.bounds;
//                const NSRect *rects = NULL;
//                NSInteger count = 0;
//                [self getRectsBeingDrawn:&rects count:&count];
//                for (NSInteger i = 0; i < count; i++) {
//                    NSRect rect = NSIntersectionRect(bounds, rects[i]);
//                    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
//                }
            }
            else
            {
                [backgroundImage setHidden:NO];
            }
            break;
        }
        default: {
            // Do super's drawing
            [super drawSelectionInRect:dirtyRect];
            break;
        }
    }
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect {
    // Draw the grid
    NSRect sepRect = self.bounds;
    sepRect.origin.y = NSMaxY(sepRect) - 1;
    sepRect.size.height = 1;
    sepRect = NSIntersectionRect(sepRect, dirtyRect);
    if (!NSIsEmptyRect(sepRect)) {
        [[NSColor gridColor] set];
        NSRectFill(sepRect);
    }
}

//- (void)drawBackgroundInRect:(NSRect)dirtyRect{
////    NSImage* backgroundImage = [NSImage imageNamed:@"recent-contacts-cell-background"];
////    NSColor* backgroundColor = [NSColor colorWithPatternImage:backgroundImage];
////    [backgroundColor set];
////    [NSBezierPath fillRect:dirtyRect];
//    NSColor* backgroundColor = [NSColor colorWithDeviceRed:235.0 / 255.0
//                                                      green:235.0 / 255.0
//                                                       blue:235.0 / 255.0
//                                                      alpha:1];
//    
//    
//    [backgroundColor set];
//    [NSBezierPath fillRect:dirtyRect];
//}
@end
