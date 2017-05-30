//
//  NSImage+Scale.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSImage+Scale.h"

@implementation NSImage (Scale)
- (NSImage *)scaleImageToWidth:(CGFloat)width
{
    NSSize imageSize = [self size];
    CGFloat height = imageSize.height * (width / imageSize.width);
    NSSize drawSize = NSMakeSize(width, height);
    
    // 高度按宽度的比例缩小，这样不会应压缩而失真
    
    NSRect scaleRect = NSMakeRect(0, 0, drawSize.width, drawSize.height);
    NSImage *scaleImage = [[NSImage alloc] initWithSize:drawSize];
    [scaleImage lockFocus];
    [self drawInRect:scaleRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    [scaleImage unlockFocus];
    
    return scaleImage;
}

@end
