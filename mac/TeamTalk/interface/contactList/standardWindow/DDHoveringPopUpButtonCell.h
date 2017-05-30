//
//  DDHoveringPopUpButtonCell.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDHoveringPopUpButtonCell : NSButtonCell{
    NSMutableAttributedString		*title;
    NSSize							textSize;
    
    NSImage							*currentImage;
    NSSize							imageSize;
    
    NSMutableDictionary				*statusAttributes;
    NSMutableParagraphStyle			*statusParagraphStyle;
    
    BOOL					hovered;
    CGFloat					hoveredFraction;
}

- (void)setTitle:(NSString *)inTitle;
- (void)setImage:(NSImage *)inImage;

- (void)setHovered:(BOOL)inHovered animate:(BOOL)animate;
- (BOOL)hovered;
- (CGFloat)trackingWidth;

@end
