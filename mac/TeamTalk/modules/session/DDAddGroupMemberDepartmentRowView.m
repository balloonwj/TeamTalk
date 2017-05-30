//
//  DDAddGroupMemberDepartmentRowView.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddGroupMemberDepartmentRowView.h"

@implementation DDAddGroupMemberDepartmentRowView

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
    [self drawBackgroundInRect:dirtyRect];
	[self drawSelectionInRect:dirtyRect];
    [self drawSeparatorInRect:dirtyRect];
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
                [primaryColor set];
                NSRect bounds = self.bounds;
                const NSRect *rects = NULL;
                NSInteger count = 0;
                [self getRectsBeingDrawn:&rects count:&count];
                for (NSInteger i = 0; i < count; i++) {
                    NSRect rect = NSIntersectionRect(bounds, rects[i]);
                    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
                }
                NSImage* image = [NSImage imageNamed:@"addgroupmember-selected"];
                [self.selectedIcon setImage:image];
            }
            else
            {
                NSImage* image = [NSImage imageNamed:@"addgroummember-unselected"];
                [self.selectedIcon setImage:image];
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

- (void)drawBackgroundInRect:(NSRect)dirtyRect{
    NSColor* backgroundColor = [NSColor colorWithDeviceRed:245.0 / 255.0
                                                     green:245.0 / 255.0
                                                      blue:245.0 / 255.0
                                                     alpha:1];
    [backgroundColor set];
    [NSBezierPath fillRect:dirtyRect];
}


@end
