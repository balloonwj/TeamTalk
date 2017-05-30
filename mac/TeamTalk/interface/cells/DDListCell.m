//
//  DDListCell.m
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListGroup.h"
#import "DDListOutlineView.h"
#import "AIBezierPathAdditions.h"
#import "DDListCell.h"
#import "DDListObject.h"

//#define	ORDERING_DEBUG

@implementation DDListCell


//Init
- (id)init
{
    if ((self = [super init]))
	{
        topSpacing =
		bottomSpacing =
        leftSpacing =
        rightSpacing = 0;
        
        topPadding =
		bottomPadding =
        leftPadding =
        rightPadding = 0;
		
		font = [NSFont systemFontOfSize:12];
		textColor = [NSColor blackColor];
		invertedTextColor = [NSColor whiteColor];
		
		useAliasesAsRequested = YES;
        
		
	}
    
    return self;
}

//Copy
- (id)copyWithZone:(NSZone *)zone
{
	DDListCell *newCell = [super copyWithZone:zone];
    
	newCell->proxyObject = nil;
	[newCell setProxyListObject:proxyObject];
    
	return newCell;
}

//Dealloc

//Set the list object being drawn
- (void)setProxyListObject:(DDProxyListObject *)inProxyObject
{
	if (proxyObject != inProxyObject) {
		proxyObject = inProxyObject;
	}
    
	isGroup = [[proxyObject listObject] isKindOfClass:[DDListGroup class]];
}

@synthesize isGroup, controlView;

//Return that this cell is draggable
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	return NSCellHitContentArea;
}

//Display options ------------------------------------------------------------------------------------------------------
#pragma mark Display options
//Font used to display label
- (void)setFont:(NSFont *)inFont
{
	if (inFont != font) {
		font = inFont;
	}
    
	//Calculate and cache the height of this font
	labelFontHeight = [[[NSLayoutManager alloc] init] defaultLineHeightForFont:[self font]];
	labelAttributes = nil;
}
- (NSFont *)font{
	return font;
}

@synthesize textAlignment, textColor, invertedTextColor;

//Cell sizing and padding ----------------------------------------------------------------------------------------------
#pragma mark Cell sizing and padding
//Default cell size just contains our padding and spacing
- (NSSize)cellSize
{
	return NSMakeSize(0, [self topSpacing] + [self topPadding] + [self bottomPadding] + [self bottomSpacing]);
}

- (CGFloat)cellWidth
{
	return [self leftSpacing] + [self leftPadding] + [self rightPadding] + [self rightSpacing];
}

//User-defined spacing offsets.  A cell may adjust these values to to obtain a more desirable default.
//These are offsets, they may be negative!  Spacing is the distance between cells (Spacing gaps are not filled).
- (void)setSplitVerticalSpacing:(int)inSpacing{
	self.topSpacing = inSpacing / 2;
	self.bottomSpacing = (inSpacing + 1) / 2;
}

//User-defined padding offsets.  A cell may adjust these values to to obtain a more desirable default.
//These are offsets, they may be negative!  Padding is the distance between cell edges and their content.
- (void)setSplitVerticalPadding:(int)inPadding{
	self.topPadding = inPadding / 2;
	self.bottomPadding = (inPadding + 1) / 2;
}

@synthesize rightPadding, leftPadding, topPadding, bottomPadding, indentation, rightSpacing, leftSpacing, topSpacing, bottomSpacing;

//Drawing --------------------------------------------------------------------------------------------------------------
#pragma mark Drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)inControlView{
    [self drawInteriorWithFrame:cellFrame inView:inControlView];
}
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)inControlView
{
	if ([proxyObject listObject]) {
		//Cell spacing
		cellFrame.origin.y += [self topSpacing];
		cellFrame.size.height -= [self bottomSpacing] + [self topSpacing];
		cellFrame.origin.x += [self leftSpacing];
		cellFrame.size.width -= [self rightSpacing] + [self leftSpacing];
		
		[self drawBackgroundWithFrame:cellFrame];
        
		//Padding
		cellFrame.origin.y += [self topPadding];
		cellFrame.size.height -= [self bottomPadding] + [self topPadding];
		cellFrame.origin.x += [self leftPadding];
		cellFrame.size.width -= [self rightPadding] + [self leftPadding];
        
		switch ([self textAlignment]) {
			case NSRightTextAlignment:
				//Right alignment indents on the right
				cellFrame.size.width -= [self indentation];
				break;
			default:
				//All other alignments indent on the left
				cellFrame.origin.x += [self indentation];
				cellFrame.size.width -= [self indentation];
				break;
		}
		[self drawContentWithFrame:cellFrame];
	}
}

/* Custom highlighting (This is a private cell method we're overriding that handles selection drawing)
 * Bubble and Mockie Cells depend upon drawSelectionWithFrame: being called from here; perhaps we could call that
 * from elsewhere.
 */
- (void)_drawHighlightWithFrame:(NSRect)cellFrame inView:(NSView *)inControlView
{
	//Cell spacing
	cellFrame.origin.y += [self topSpacing];
	cellFrame.size.height -= [self bottomSpacing] + [self topSpacing];
	cellFrame.origin.x += [self leftSpacing];
	cellFrame.size.width -= [self rightSpacing] + [self leftSpacing];
	
	[self drawSelectionWithFrame:cellFrame];
}

//Draw Selection
- (void)drawSelectionWithFrame:(NSRect)rect {}

//Draw the background of our cell
- (void)drawBackgroundWithFrame:(NSRect)rect {}

//Draw content of our cell
- (void)drawContentWithFrame:(NSRect)rect
{
	[self drawDisplayNameWithFrame:rect];
}

- (void)drawDropHighlightWithFrame:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
    
	//Ensure we don't draw outside our rect
	[[NSBezierPath bezierPathWithRect:rect] addClip];
	
	rect.size.width -= DROP_HIGHLIGHT_WIDTH_MARGIN;
	rect.origin.x += DROP_HIGHLIGHT_WIDTH_MARGIN / 2.0f;
	
	rect.size.height -= DROP_HIGHLIGHT_HEIGHT_MARGIN;
	rect.origin.y += DROP_HIGHLIGHT_HEIGHT_MARGIN / 2.0f;
    
	NSBezierPath	*path = [NSBezierPath bezierPathWithRoundedRect:rect radius:4.0f];
    
	[[[NSColor blueColor] colorWithAlphaComponent:0.2f] set];
	[path fill];
	
	[[[NSColor blueColor] colorWithAlphaComponent:0.8f] set];
	[path setLineWidth:2.0f];
	[path stroke];
    
	[NSGraphicsContext restoreGraphicsState];
}

/*!
 * @brief Return the attributed string to be displayed as the primary text of the cell
 */
- (NSAttributedString *)displayName
{
	NSDictionary *attributes = self.labelAttributes;
	NSString *labelString = self.labelString;
	if (![labelAttributes isEqualToDictionary:proxyObject.cachedLabelAttributes] || ![labelString isEqualToString:proxyObject.cachedDisplayNameString]) {
		proxyObject.cachedDisplayName = [[NSAttributedString alloc] initWithString:labelString
                                                                        attributes:attributes];
		proxyObject.cachedDisplayNameString = labelString;
		proxyObject.cachedLabelAttributes = attributes;
		proxyObject.cachedDisplayNameSize = NSZeroSize;
	}
	
	return proxyObject.cachedDisplayName;
}

- (NSSize) displayNameSize
{
	NSSize size = proxyObject.cachedDisplayNameSize;
	if(NSEqualSizes(size, NSZeroSize)) {
		size = [self.displayName size];
		proxyObject.cachedDisplayNameSize = size;
	}
    
	return size;
}

//Draw our display name
- (NSRect)drawDisplayNameWithFrame:(NSRect)inRect
{
	NSAttributedString	*displayName = self.displayName;
	NSSize				nameSize = self.displayNameSize;
	NSRect				rect = inRect;
    
	if (nameSize.width > rect.size.width) nameSize.width = rect.size.width;
	if (nameSize.height > rect.size.height) nameSize.height = rect.size.height;
    
	//Alignment
	switch ([self textAlignment]) {
		case NSCenterTextAlignment:
			rect.origin.x += (rect.size.width - nameSize.width) / 2.0f;
            break;
		case NSRightTextAlignment:
			rect.origin.x += (rect.size.width - nameSize.width);
            break;
		default:
            break;
	}
    
	//Draw (centered vertical)
	CGFloat half = ceil((rect.size.height - labelFontHeight) / 2.0f);
	[displayName drawInRect:NSMakeRect(rect.origin.x,
									   rect.origin.y + half,
									   rect.size.width,
									   nameSize.height)];
    
	//Adjust the drawing rect
	switch ([self textAlignment]) {
		case NSRightTextAlignment:
			inRect.size.width -= nameSize.width;
            break;
		case NSLeftTextAlignment:
			inRect.origin.x += nameSize.width;
			inRect.size.width -= nameSize.width;
            break;
		default:
            break;
	}
	
	return inRect;
}

//Display string for our list object
- (NSString *)labelString
{
	NSString *label =[[proxyObject listObject] longDisplayName];
    
    /*
    ([self shouldShowAlias] ?
						[[proxyObject listObject] longDisplayName] :
						([proxyObject listObject].formattedUID ? [proxyObject listObject].formattedUID : [[proxyObject listObject] longDisplayName]));
     */
     
	if (!label) {
		NSLog(@"Couldn't get a labelString for contact %@", [proxyObject listObject]);
		return @"";
	}
	return label;
}

@synthesize shouldShowAlias = useAliasesAsRequested;

//Additional attributes to apply to our label string (For Sub-Classes)
- (NSDictionary *)additionalLabelAttributes
{
	return nil;
}

//YES if our cell is currently selected
- (BOOL)cellIsSelected
{
	return ([self isHighlighted] &&
            [[controlView window] isKeyWindow] &&
            [[controlView window] firstResponder] == controlView);
}

//YES if a grid would be visible behind this cell (needs to be drawn)
- (BOOL)drawGridBehindCell
{
	return YES;
}

//The background color for this cell.  This will either be [controlView backgroundColor] or [controlView alternatingGridColor]
- (NSColor *)backgroundColor
{
	//We could just call backgroundColorForRow: but it's best to avoid doing a rowForItem lookup if there is no grid
    /*
	if ([controlView usesAlternatingRowBackgroundColors]) {
		return [controlView backgroundColorForRow:[controlView rowForItem:proxyObject]];
	} else {
		return [controlView backgroundColor];
	}
     */
    
    return [controlView backgroundColor];
}

#pragma mark Accessibility

- (NSArray *)accessibilityAttributeNames
{
	NSMutableArray *attributeNames = [[super accessibilityAttributeNames] mutableCopy];
	[attributeNames addObject:NSAccessibilityValueAttribute];
    
	return attributeNames;
}

@end