//
//  DDMessageReviewContactsCellView.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageReviewContactsCellView.h"
#import "MTUserEntity.h"
#import "MTGroupEntity.h"
#import "AvatorImageView.h"
@implementation DDMessageReviewContactsCellView

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
    NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0,self.frame.size.height, self.frame.size.width, 1)];
    [view setWantsLayer:YES];
    [view.layer setBackgroundColor:[NSColor colorWithCalibratedRed:232.0 / 255.0
                                                             green:233.0 / 255.0
                                                              blue:232.0 / 255.0
                                                             alpha:1].CGColor];
    [self addSubview:view];
    // Drawing code here.
}

- (void)configWithObject:(id)object
{
    if ([object isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        [_avatarImageView setUser:object];
        NSString* name = [(MTUserEntity*)object name];
        if (name)
        {
            [_nameTextField setStringValue:name];
        }
    }
    else if ([object isKindOfClass:NSClassFromString(@"MTGroupEntity")])
    {
        [_avatarImageView setGroup:object];
        NSString* name = [(MTGroupEntity*)object name];
        if (name)
        {
            [_nameTextField setStringValue:name];
        }
    }
}

@end
