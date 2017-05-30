//
//  DDMessageReviewTextView.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageReviewTextView.h"

@implementation DDMessageReviewTextView

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
- (BOOL)resignFirstResponder
{
    [self setSelectedRange:NSMakeRange(0, 0)];
    return YES;
}
@end
