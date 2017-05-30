//
//  DDGridBackgroundView.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGridBackgroundView.h"

@implementation DDGridBackgroundView

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
    NSImage* image = [NSImage imageNamed:@"background"];
    NSColor* color = [NSColor colorWithPatternImage:image];
    [color set];
    [NSBezierPath fillRect:dirtyRect];
    // Drawing code here.
}
@end
