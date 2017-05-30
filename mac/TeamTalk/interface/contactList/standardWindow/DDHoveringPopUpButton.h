//
//  DDHoveringPopUpButton.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDHoveringPopUpButton : NSButton{
    NSTrackingRectTag	trackingTag;
	BOOL				highlightOnHoverAndClick;
	SEL					doubleAction;
}

- (void)setTitle:(NSString *)inTitle;
- (void)setImage:(NSImage *)inImage;
- (void)setDoubleAction:(SEL)inDoubleAction;
- (void)setHighlightOnHoverAndClick:(BOOL)inHighlightOnHoverAndClick;

- (NSRect)trackingRect;

@end

