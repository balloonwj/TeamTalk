//
//  DDCornerRadiusTextField.m
//  Duoduo
//
//  Created by 独嘉 on 14-7-15.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDCornerRadiusTextField.h"

@implementation DDCornerRadiusTextField
{
    float _cornerRadius;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    //设置下填充色，这里就用灰色啦，不那么抢眼
    [[NSColor redColor] setFill];
    //根据view的框框，画个圆角矩形出来
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect
                                                         xRadius:4
                                                         yRadius:4];
    //填充颜色
	[path fill];
    
}

- (void)setCornerRadius:(float)cornerRadius
{
//    _cornerRadius = cornerRadius;
//    [self displayIfNeeded];
}

@end
