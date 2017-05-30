//
//  BackgroudView.m
//  Duoduo
//
//  Created by jianqing.du on 14-3-26.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "BackgroudView.h"

@implementation BackgroudView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    NSRect frame = [self frame];
    [[NSColor redColor] set];
    
    [NSBezierPath fillRect:frame];
}

@end
