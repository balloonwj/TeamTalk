//
//  DDMultiSelectedOutlineView.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMultiSelectedOutlineView.h"

@implementation DDMultiSelectedOutlineView

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
	
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent
{
    
    NSEvent* newEvent = [NSEvent mouseEventWithType:NSOtherMouseDown location:[theEvent locationInWindow] modifierFlags:NSCommandKeyMask timestamp:[theEvent timestamp] windowNumber:[theEvent windowNumber] context:[theEvent context] eventNumber:[theEvent eventNumber] clickCount:[theEvent clickCount] pressure:[theEvent pressure]];
    [super mouseDown:newEvent];
}

@end
