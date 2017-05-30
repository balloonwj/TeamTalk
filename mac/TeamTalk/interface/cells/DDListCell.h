//
//  DDListCell.h
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDProxyListObject.h"

@class DDListObject, DDListOutlineView;

#define DROP_HIGHLIGHT_WIDTH_MARGIN 5.0f
#define DROP_HIGHLIGHT_HEIGHT_MARGIN 1.0f

@interface DDListCell : NSCell {
	DDListOutlineView	*__weak controlView;
    DDProxyListObject	*proxyObject;
    BOOL				isGroup;
	
	NSTextAlignment		textAlignment;
	CGFloat					labelFontHeight;
	
	CGFloat					topSpacing;
	CGFloat					bottomSpacing;
	CGFloat					topPadding;
	CGFloat					bottomPadding;
    
	CGFloat					leftPadding;
	CGFloat					rightPadding;
	CGFloat					leftSpacing;
	CGFloat					rightSpacing;
	
	CGFloat					indentation;
    
	NSColor				*textColor;
	NSColor				*invertedTextColor;
	
	NSFont				*font;
	
	BOOL				useAliasesAsRequested;
	NSMutableDictionary *labelAttributes;
}

- (void)setProxyListObject:(DDProxyListObject *)inObject;
@property (readonly, nonatomic) BOOL isGroup;
@property (readwrite, weak, nonatomic) DDListOutlineView *controlView;

//Display options
@property (readwrite, nonatomic) NSFont *font;
@property (readwrite, nonatomic) NSTextAlignment textAlignment;
@property (readwrite, nonatomic) NSColor *textColor;
@property (readwrite, nonatomic) NSColor *invertedTextColor;

//Cell sizing and padding
- (void) setSplitVerticalSpacing:(int) inSpacing;
- (void) setSplitVerticalPadding:(int) inPadding;
@property (readonly, nonatomic) NSSize cellSize;
@property (readonly, nonatomic) CGFloat cellWidth;
@property (readwrite, nonatomic) CGFloat rightSpacing;
@property (readwrite, nonatomic) CGFloat leftSpacing;
@property (readwrite, nonatomic) CGFloat topSpacing;
@property (readwrite, nonatomic) CGFloat bottomSpacing;
@property (readwrite, nonatomic) CGFloat rightPadding;
@property (readwrite, nonatomic) CGFloat leftPadding;
@property (readwrite, nonatomic) CGFloat topPadding;
@property (readwrite, nonatomic) CGFloat bottomPadding;
@property (readwrite, nonatomic) CGFloat indentation;

//Drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)_drawHighlightWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawSelectionWithFrame:(NSRect)rect;
- (void)drawBackgroundWithFrame:(NSRect)rect;
- (void)drawContentWithFrame:(NSRect)rect;
- (void)drawDropHighlightWithFrame:(NSRect)rect;
@property (weak, readonly, nonatomic) NSAttributedString *displayName;
@property (readonly, nonatomic) NSSize displayNameSize;
- (NSRect)drawDisplayNameWithFrame:(NSRect)inRect;
@property (weak, readonly, nonatomic) NSString *labelString;
@property (weak, readonly, nonatomic) NSMutableDictionary *labelAttributes;
@property (weak, readonly, nonatomic) NSDictionary *additionalLabelAttributes;
@property (readonly, nonatomic) BOOL cellIsSelected;
@property (readonly, nonatomic) BOOL drawGridBehindCell;
@property (weak, readonly, nonatomic) NSColor *backgroundColor;

@property (readwrite, nonatomic) BOOL shouldShowAlias;


@end
