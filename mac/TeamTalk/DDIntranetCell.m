//
//  DDIntranetCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetCell.h"
#import "DDIntranetEntity.h"
#import "MTMessageModule.h"
@implementation DDIntranetCell

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

- (void)configWithIntranet:(DDIntranetEntity*)intranet
{
    NSImage* iconImage = [NSImage imageNamed:@"intranet_icon"];
    [avatarImageView setImage:iconImage];
    [nameTextField setStringValue:intranet.name];
}

@end
