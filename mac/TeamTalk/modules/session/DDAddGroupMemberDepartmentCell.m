//
//  DDAddGroupMemberDepartmentCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddGroupMemberDepartmentCell.h"
#import "DDAddChatGroup.h"
@implementation DDAddGroupMemberDepartmentCell
{
    NSColor* backgroundColor;
}

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

- (void)setItem:(id)item
{
    [self.name setStringValue:[(DDAddChatGroup*)item name]];
}

@end
