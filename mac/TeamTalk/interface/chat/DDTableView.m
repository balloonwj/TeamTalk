//
//  DDTableView.m
//  Duoduo
//
//  Created by zuoye on 14-1-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDTableView.h"

@implementation DDTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hasCustomGridLine = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
