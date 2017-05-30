//
//  WhiteBackgroundView.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WhiteBackgroundView : NSView
@property(nonatomic,strong)NSColor *color;
-(void)setBackgroundImage:(NSImage *)image;
-(void)setBackgroundColor:(NSColor *)color;
@end
