//
//  DDSplitView.m
//  Duoduo
//
//  Created by zuoye on 13-12-2.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDSplitView.h"

@implementation DDSplitView

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


-(NSColor *)dividerColor{
    
    return [NSColor grayColor];
}

@end
