//
//  NSImage+Addition.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Addition)
- (void)saveImageToFile:(NSString*)fileName compressionFactor:(CGFloat)factor;
- (NSData*)imageDataCompressionFactor:(CGFloat)factor;
@end
