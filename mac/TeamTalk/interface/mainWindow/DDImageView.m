//
//  DDImageView.m
//  Duoduo
//
//  Created by zuoye on 13-11-29.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDImageView.h"

@implementation DDImageView

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
	
    /*
    NSImage *image=[NSImage imageNamed:@"seperator_left"];
    
    [[NSColor colorWithPatternImage:image] set];
    NSRectFill(dirtyRect);
     */
}

@end
