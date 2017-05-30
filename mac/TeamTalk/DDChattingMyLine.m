//
//  DDChattingMyLine.m
//  Duoduo
//
//  Created by 东邪 on 14-5-14.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingMyLine.h"

@implementation DDChattingMyLine
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.mBackgroundColor set];
    [NSBezierPath fillRect:dirtyRect];
}
-(void)setBackgroundColor:(NSColor *)color
{
    self.mBackgroundColor=color;

}
-(void)setBackgroundImage:(NSImage *)image
{
     NSColor *backgroundColor = [NSColor colorWithPatternImage:image];
     self.mBackgroundColor=backgroundColor;
}
- (void)awakeFromNib
{
 
}
@end
