//
//  MainWindowSegmentedControl.m
//  TabItem
//
//  Created by zuoye on 13-12-25.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "MainWindowSegmentedControl.h"

@implementation MainWindowSegmentedControl

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
	
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
    
    return nil;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	
	int i;
	for (i = 0; i < [self segmentCount]; i++)
	{
		[self setWidth:[self frame].size.width/[self segmentCount]
			forSegment:i];
	}
}

@end
