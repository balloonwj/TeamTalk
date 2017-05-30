//
//  NSImage+Addition.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSImage+Addition.h"

@implementation NSImage (Addition)
- (void)saveImageToFile:(NSString*)fileName compressionFactor:(CGFloat)factor
{
    [self lockFocus];
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
    [self unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:factor] forKey:NSImageCompressionFactor];
    
    
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];
    
    //设定好文件路径后进行存储就ok了
    [imageData writeToFile:fileName atomically:YES];
}

- (NSData*)imageDataCompressionFactor:(CGFloat)factor
{
    [self lockFocus];
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
    [self unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:factor] forKey:NSImageCompressionFactor];
    
    
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];
    return imageData;
}

@end
