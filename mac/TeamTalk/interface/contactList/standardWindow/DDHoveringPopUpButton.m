//
//  DDHoveringPopUpButton.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDHoveringPopUpButton.h"
#import "DDHoveringPopUpButtonCell.h"

@interface DDHoveringPopUpButton()
- (void)frameDidChange:(NSNotification *)inNotification;
@end


@implementation DDHoveringPopUpButton

+(void)initialize{
    if (self==[DDHoveringPopUpButton class]) {
       [self setCellClass:[DDHoveringPopUpButtonCell class]];
    }
}


- (void)initHoveringPopUpButton
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(frameDidChange:)
												 name:NSViewFrameDidChangeNotification
											   object:self];
	[self setPostsFrameChangedNotifications:YES];
    
	trackingTag = -1;
	[self resetCursorRects];
    
	highlightOnHoverAndClick = YES;
}

- (id)initWithFrame:(NSRect)inFrame
{
	if ((self = [super initWithFrame:inFrame])) {
		[self initHoveringPopUpButton];
	}
    
	return self;
}

- (void)awakeFromNib
{
	if ([[DDHoveringPopUpButton superclass] instancesRespondToSelector:@selector(awakeFromNib)]) {
        [super awakeFromNib];
	}
    
	[self initHoveringPopUpButton];
}

- (id)copyWithZone:(NSZone *)zone
{
	DDHoveringPopUpButton	*newButton = [[[self class] alloc] initWithFrame:[self frame]];
	
	[newButton setMenu:[[self menu] copy]];
	
	return newButton;
}

//silly NSControl...
- (void)setMenu:(NSMenu *)menu {
	[super setMenu:menu];
	[[self cell] setMenu:menu];
}

- (void)setDoubleAction:(SEL)inDoubleAction
{
	doubleAction = inDoubleAction;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
}

//Mouse Tracking -------------------------------------------------------------------------------------------------------
#pragma mark Mouse Tracking
//Custom mouse down tracking to display our menu and highlight
- (void)mouseDown:(NSEvent *)theEvent
{
	if (![self menu]) {
		if (doubleAction && (([theEvent clickCount] % 2) == 0)) {
			[[self target] performSelector:doubleAction
								withObject:self];
		} else {
			[super mouseDown:theEvent];
		}
        
	} else {
		if ([self isEnabled]) {
			[self highlight:YES];
            
			[self setNeedsDisplay:YES];
            
			//2 pt down, 1 pt to the left.
			NSPoint point = [self convertPoint:[self bounds].origin toView:nil];
			point.y -= NSHeight([self frame]) + 2;
			point.x -= 1;
			
			NSEvent *event = [NSEvent mouseEventWithType:[theEvent type]
												location:point
										   modifierFlags:[theEvent modifierFlags]
											   timestamp:[theEvent timestamp]
											windowNumber:[[theEvent window] windowNumber]
												 context:[theEvent context]
											 eventNumber:[theEvent eventNumber]
											  clickCount:[theEvent clickCount]
												pressure:[theEvent pressure]];
			[NSMenu popUpContextMenu:[self menu] withEvent:event forView:self];
			
			[self mouseUp:[[NSApplication sharedApplication] currentEvent]];
		}
	}
}

/*!
 * @brief Only pass on a highlight message if we're highlighting on click or this is turning off a highlight
 */
- (void)highlight:(BOOL)inFlag
{
	if (!inFlag || highlightOnHoverAndClick) {
		[super highlight:inFlag];
	}
}

//Remove highlight on mouse up
- (void)mouseUp:(NSEvent *)theEvent
{
	[self highlight:NO];
	[super mouseUp:theEvent];
}

//Ignore dragging
- (void)mouseDragged:(NSEvent *)theEvent
{
	//Empty
}

- (NSView *)hitTest:(NSPoint)aPoint
{
	NSRect	myFrame = [self frame];
	myFrame.size.width = [[self cell] trackingWidth];
    
	if (NSPointInRect(aPoint, myFrame)) {
		return [super hitTest:aPoint];
	} else {
		return nil;
	}
}

/*!
 * @brief Set the title
 */
- (void)setTitle:(NSString *)inTitle
{
	[[self cell] setTitle:inTitle];
	[self setNeedsDisplay:YES];
    
	[self resetCursorRects];
}

- (void)setFont:(NSFont *)inFont
{
	[[self cell] setFont:inFont];
	[self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)inImage
{
	[[self cell] setImage:inImage];
	[self setNeedsDisplay:YES];
	
	[self resetCursorRects];
}

- (void)setHighlightOnHoverAndClick:(BOOL)inHighlightOnHoverAndClick
{
	highlightOnHoverAndClick = inHighlightOnHoverAndClick;
	
	//If we are not going to highlight, ensure we're not currently doing so
	if (!highlightOnHoverAndClick) {
		[[self cell] setHovered:NO animate:NO];
		[self setNeedsDisplay:YES];
	}
}

#pragma mark Tracking rects
//Remove old tracking rects when we change superviews
- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	[super viewWillMoveToSuperview:newSuperview];
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	
	[self resetCursorRects];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	[super viewWillMoveToWindow:newWindow];
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	[self resetCursorRects];
}

- (void)frameDidChange:(NSNotification *)inNotification
{
	[self resetCursorRects];
}

- (NSRect)trackingRect
{
	return NSMakeRect(0, 0, [[self cell] trackingWidth], [self frame].size.height);
}

//Reset our cursor tracking
- (void)resetCursorRects
{
	//Stop any existing tracking
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	//Add a tracking rect if our superview and window are ready
	if ([self superview] && [self window]) {
		NSRect	myFrame = [self frame];
		NSRect	trackRect = [self trackingRect];
		
		if (trackRect.size.width > myFrame.size.width) {
			trackRect.size.width = myFrame.size.width;
		}
        
		NSPoint	localPoint = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]]
									   fromView:nil];
		BOOL	mouseInside = NSPointInRect(localPoint, trackRect);
        
		trackingTag = [self addTrackingRect:trackRect owner:self userData:nil assumeInside:mouseInside];
		if (mouseInside) {
			[self mouseEntered:nil];
		} else {
			[self mouseExited:nil];
		}
	}
}

//Cursor entered our view
- (void)mouseEntered:(NSEvent *)theEvent
{
	if (highlightOnHoverAndClick && ![[self cell] hovered]) {
		[[self cell] setHovered:YES animate:YES];
		[self setNeedsDisplay:YES];
	}
    
	[super mouseEntered:theEvent];
}


//Cursor left our view
- (void)mouseExited:(NSEvent *)theEvent
{
	if (highlightOnHoverAndClick && [[self cell] hovered]) {
		[[self cell] setHovered:NO animate:YES];
		[self setNeedsDisplay:YES];
	}
	
	[super mouseExited:theEvent];
}

@end
