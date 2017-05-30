//
//  DDHoveringPopUpButtonCell.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDHoveringPopUpButtonCell.h"
#import "AIBezierPathAdditions.h"
#import "AIImageDrawingAdditions.h"
#import "AIParagraphStyleAdditions.h"

#define LEFT_MARGIN		5
#define IMAGE_MARGIN	4
#define ARROW_WIDTH		8
#define ARROW_HEIGHT	(ARROW_WIDTH/2.0f)
#define ARROW_XOFFSET	5
#define RIGHT_MARGIN	5


@implementation DDHoveringPopUpButtonCell
- (void)commonInit
{
	title = nil;
	currentImage = nil;
	textSize = NSZeroSize;
	imageSize = NSZeroSize;
	hovered = NO;
	hoveredFraction = 0.0f;
    
	statusParagraphStyle = [NSMutableParagraphStyle styleWithAlignment:NSLeftTextAlignment
                                                         lineBreakMode:NSLineBreakByTruncatingTail];
	
	statusAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        statusParagraphStyle, NSParagraphStyleAttributeName,
                        [NSFont systemFontOfSize:10], NSFontAttributeName,
                        nil];
}

- (id)initTextCell:(NSString *)str
{
	if ((self = [super initTextCell:str])) {
		[self commonInit];
	}
	
	return self;
}
- (id)initImageCell:(NSImage *)image
{
	if ((self = [super initImageCell:image])) {
		[self commonInit];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	DDHoveringPopUpButtonCell	*newCell = [[self class] alloc];
    
	switch ([self type]) {
		case NSImageCellType:
			newCell = [newCell initImageCell:[self image]];
			break;
		case NSTextCellType:
			newCell = [newCell initTextCell:[self stringValue]];
			break;
		default:
			newCell = [newCell init]; //and hope for the best
			break;
	}
	
	[newCell setMenu:[[self menu] copy]];
	
	return newCell;
}

- (void)dealloc
{
	/* Super's implementation calls setImage:nil in 10.4; we shouldn't depend on this implementation detail but should
	 * set our ivars to nil to ensure we don't double-release.
	 */
	title = nil;
	currentImage = nil;
    
    
}

- (void)setTitle:(NSString *)inTitleString
{
    
	//Strip out all newlines
	inTitleString = [inTitleString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]];
    
	if (inTitleString && [inTitleString length]) {
		title = [[NSMutableAttributedString alloc] initWithString:inTitleString
													   attributes:statusAttributes];
		textSize = [title size];
	} else {
		title = nil;
		textSize = NSZeroSize;
	}
}

- (void)setFont:(NSFont *)inFont
{
	NSString *oldTitleString = [[title string] copy];
    
	[statusAttributes setObject:inFont
						 forKey:NSFontAttributeName];
	[self setTitle:oldTitleString];
	
	[super setFont:inFont];
}

-(void)setImage:(NSImage *)inImage
{
	if (inImage != currentImage) {
		currentImage = inImage;
		
		imageSize = [currentImage size];
	}
}

- (void)fadeHovered:(NSControl *)currentControlView
{
	if (hovered) {
		if (hoveredFraction < 1.0) hoveredFraction += 0.05f;
	} else {
		if (hoveredFraction > 0.0) hoveredFraction -= 0.05f;
	}
    
	[currentControlView setNeedsDisplay:YES];
    
	if ((hoveredFraction > 0.0) &&
		(hoveredFraction < 1.0)) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(fadeHovered:)
												   object:currentControlView];
		
		[self performSelector:@selector(fadeHovered:)
				   withObject:currentControlView
				   afterDelay:0];
	}
}

- (void)setHovered:(BOOL)inHovered animate:(BOOL)animate
{
	if (animate && (hovered != inHovered)) {
		hovered = inHovered;
        
		hoveredFraction = (hovered ? 0.80f : 0.20f);
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(fadeHovered:)
												   object:[self controlView]];
		[self performSelector:@selector(fadeHovered:)
				   withObject:[self controlView]
				   afterDelay:0];
	} else {
		hovered = inHovered;
        
		hoveredFraction = (hovered ? 1.0f : 0.0f);
		[[self controlView] setNeedsDisplay:YES];
	}
}

- (BOOL)hovered
{
	return hovered;
}

#pragma mark Drawing

//for some unknown reason, NSButtonCell's -drawWithFrame:inView: draws a basic ridge border on the bottom-right if we do not override it.
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (CGFloat)trackingWidth
{
	CGFloat trackingWidth;
	
	trackingWidth = LEFT_MARGIN + [title size].width + RIGHT_MARGIN;
	if ([self menu]) {
		trackingWidth += ARROW_XOFFSET + ARROW_WIDTH;
	}
	if (currentImage) {
		trackingWidth += imageSize.width + IMAGE_MARGIN;
	}
	
	return trackingWidth;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect	textRect;
	NSColor	*drawingColor;
	NSMenu	*myMenu = [self menu];
	CGFloat	maxTextWidth;
    
	[statusParagraphStyle setMaximumLineHeight:cellFrame.size.height];
    
	textRect = NSMakeRect(cellFrame.origin.x + LEFT_MARGIN,
						  cellFrame.origin.y + ((cellFrame.size.height - textSize.height) / 2),
						  textSize.width,
						  textSize.height);
	maxTextWidth = (cellFrame.size.width - LEFT_MARGIN - RIGHT_MARGIN);
    
	if (currentImage) {
		textRect.origin.x += (imageSize.width + IMAGE_MARGIN);
		maxTextWidth -= (imageSize.width + IMAGE_MARGIN);
	}
    
	if (myMenu) {
		maxTextWidth -= (ARROW_XOFFSET + ARROW_WIDTH);
	}
    
	if (textRect.size.width > maxTextWidth) {
		textRect.size.width = maxTextWidth;
	}
    
	if (hovered || (hoveredFraction > 0.0)) {
		//Draw our hovered / highlighted background first
		NSBezierPath	*path;
		
		CGFloat backgroundWidth = LEFT_MARGIN + textRect.size.width + RIGHT_MARGIN;
		
		if (myMenu) {
			backgroundWidth += (ARROW_XOFFSET + ARROW_WIDTH);
		}
		if (currentImage) {
			backgroundWidth += imageSize.width + IMAGE_MARGIN;
		}
        
		path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(cellFrame.origin.x,
																  cellFrame.origin.y,
																  backgroundWidth,
																  cellFrame.size.height)
												radius:10];
		
		if ([self isHighlighted]) {
			[[[NSColor darkGrayColor] colorWithAlphaComponent:hoveredFraction] set];
            
		} else {
			[[[NSColor grayColor]  colorWithAlphaComponent:hoveredFraction] set];
		}
        
		[path fill];
		
		if (hovered) {
			drawingColor = [NSColor whiteColor];
		} else {
			drawingColor = [NSColor blackColor];
		}
	} else {
		drawingColor = [NSColor blackColor];
	}
	
	if (currentImage) {
		[currentImage drawInRect:NSMakeRect(cellFrame.origin.x + LEFT_MARGIN,
											cellFrame.origin.y,
											imageSize.width + IMAGE_MARGIN,
											cellFrame.size.height)
						  atSize:imageSize
						position:IMAGE_POSITION_LEFT
						fraction:1.0f];
	}
    
	[statusAttributes setObject:drawingColor
						 forKey:NSForegroundColorAttributeName];
	[title setAttributes:statusAttributes
				   range:NSMakeRange(0, [title length])];
	[title drawInRect:textRect];
	
	//Draw the arrow
	if (myMenu) {
		NSBezierPath *arrowPath = [NSBezierPath bezierPath];
        
		[arrowPath moveToPoint:NSMakePoint(NSMaxX(textRect) + ARROW_XOFFSET,
										   (NSMaxY(cellFrame) / 2) - (ARROW_HEIGHT / 2))];
		[arrowPath relativeLineToPoint:NSMakePoint(ARROW_WIDTH, 0)];
		[arrowPath relativeLineToPoint:NSMakePoint(-(ARROW_WIDTH/2), (ARROW_HEIGHT))];
        
		[drawingColor set];
		[arrowPath fill];
	}
}

- (BOOL)isOpaque
{
    return NO;
}

@end
