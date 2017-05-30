//
//  DDTabItemView.m
//  Duoduo
//
//  Created by zuoye on 13-11-28.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDTabItemView.h"

@implementation DDTabItemView

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
    NSImage *image=[NSImage imageNamed:@"icon_conversation_highlight_theme_gray"];
    
    [[NSColor colorWithPatternImage:image] set];
    NSRectFill(dirtyRect);

    
}

@end
