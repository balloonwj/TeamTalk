//
//  DDSearchFieldResultCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-2-19.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSearchFieldResultCell.h"
#import "EGOImageView.h"

@implementation DDSearchFieldResultCell

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

- (void)setImageURL:(NSURL*)url
{
    [_imageCell loadImageWithURL:url setplaceholderImage:@"man_placeholder"];
}

- (void)setName:(NSString*)name
{
    if (name)
    {
        [_nameTextField setStringValue:name];
    }
}

@end
