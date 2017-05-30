//
//  WhiteBackgroundView.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "WhiteBackgroundView.h"
#import "NSAttributedString+Message.h"

@implementation WhiteBackgroundView
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color=[NSColor whiteColor];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
         self.color=[NSColor whiteColor];
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self.color set];
    [NSBezierPath fillRect:dirtyRect];
    
}
-(void)setBackgroundColor:(NSColor *)color
{
    self.color = color;
}
-(void)setBackgroundImage:(NSImage *)image
{
    self.color= [NSColor colorWithPatternImage:image] ;
}
- (void)awakeFromNib
{
    
}

@end

