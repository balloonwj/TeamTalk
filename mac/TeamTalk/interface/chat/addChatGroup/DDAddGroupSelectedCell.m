//
//  DDAddGroupSelectedCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddGroupSelectedCell.h"
#import "MTUserEntity.h"
#import "AvatorImageView.h"
typedef void(^Cancel)();

@implementation DDAddGroupSelectedCell
{
    Cancel _calcel;
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

- (void)awakeFromNib
{

}

- (void)configeWithUser:(id)user cancel:(void(^)())cancel
{
    [self.avatar setWantsLayer:YES];
    [self.avatar.layer setCornerRadius:3.0];
    [self.avatar.layer setMasksToBounds:YES];
    _calcel = nil;
    _calcel = [cancel copy];

    [self.avatar setUser:user];
    NSString* name = [(MTUserEntity*)user name];
    [self.name setStringValue:name];
}

- (IBAction)cancelSelected:(id)sender
{
    _calcel();
}

@end
