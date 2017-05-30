//
//  DDContactListImagePicker.m
//  Duoduo
//
//  Created by maye on 13-11-14.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDContactListImagePicker.h"
#import "AIBezierPathAdditions.h"

#define ARROW_WIDTH		8
#define ARROW_HEIGHT	(ARROW_WIDTH/2.0)
#define ARROW_XOFFSET	2
#define ARROW_YOFFSET	3

@interface DDContactListImagePicker ()
-(void)frameDidChange:(NSNotification *)inNotification;

@end

@implementation DDContactListImagePicker

-(void)configureTracking{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
    [self setPostsFrameChangedNotifications:YES];
    
    trackingTag = -1;
    [self resetCursorRects];
    [self setPresentPictureTakerAsSheet:NO];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureTracking];
        imageMenu = nil;
        maxSize = NSMakeSize(256.0f, 256.0f);
        shouldUpdateRecentRepository = YES;
    }
    return self;
}

-(void) awakeFromNib{
    if ([[self superclass] instanceMethodSignatureForSelector:@selector(awakeFromNib)]) {
        [super awakeFromNib];
    }
    
    [self configureTracking];
    maxSize = NSMakeSize(256.0f, 256.0f);
	shouldUpdateRecentRepository = YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
}

#pragma mark Drawing
- (void)drawRect:(NSRect)inRect
{
	
	[NSGraphicsContext saveGraphicsState];
    
	inRect = NSInsetRect(inRect, 1, 1);
    
	NSBezierPath	*clipPath = [NSBezierPath bezierPathWithRoundedRect:inRect radius:3];
    
	[[NSColor windowFrameColor] set];
	[clipPath setLineWidth:1];
	[clipPath stroke];
    
	// Ensure we have an even/odd winding rule in effect
	[clipPath setWindingRule:NSEvenOddWindingRule];
	[clipPath addClip];
	
	[super drawRect:inRect];
	
	if (hovered) {
		[[[NSColor blackColor] colorWithAlphaComponent:0.40f] set];
		[clipPath fill];
        
		// Draw the arrow
		NSBezierPath	*arrowPath = [NSBezierPath bezierPath];
		NSRect			frame = [self frame];
		[arrowPath moveToPoint:NSMakePoint(frame.size.width - ARROW_XOFFSET - ARROW_WIDTH,
										   (ARROW_YOFFSET + (CGFloat)ARROW_HEIGHT))];
		[arrowPath relativeLineToPoint:NSMakePoint(ARROW_WIDTH, 0)];
		[arrowPath relativeLineToPoint:NSMakePoint(-(ARROW_WIDTH/2.0f), -((CGFloat)ARROW_HEIGHT))];
		
		[[NSColor whiteColor] set];
		[arrowPath fill];
	}
    
	[NSGraphicsContext restoreGraphicsState];
}

#pragma mark Mouse movement

-(void)setHovered:(BOOL)inHovered{
    hovered = inHovered;
    [self setNeedsDisplay:YES];
}

-(void)mouseEntered:(NSEvent *)inEvent{
    [self setHovered:YES];
    [super mouseEntered:inEvent];
}

-(void)mouseExited:(NSEvent *)inEvent{
    [self setHovered:NO];
    [super mouseExited:inEvent];
}
-(void)displayPicturePopUpForEvent:(NSEvent *)theEvent{
    NSLog(@"+++++displayPicturePopUpForEvent need to  implement.");
    //[DDContactList]
}

#pragma mark Tracking rects

// Remove old tracking rects when we change superviews
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

// Reset our cursor tracking
- (void)resetCursorRects
{
	// Stop any existing tracking
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	// Add a tracking rect if our superview and window are ready
	if ([self superview] && [self window]) {
		NSRect	myFrame = [self frame];
		NSRect	trackRect = NSMakeRect(0, 0, myFrame.size.width, myFrame.size.height);
		
		if (trackRect.size.width > myFrame.size.width) {
			trackRect.size.width = myFrame.size.width;
		}
		
		NSPoint	localPoint = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]]
									   fromView:nil];
		BOOL	mouseInside = NSPointInRect(localPoint, myFrame);
        
		trackingTag = [self addTrackingRect:trackRect owner:self userData:nil assumeInside:mouseInside];
		if (mouseInside) [self mouseEntered:nil];
	}
}


@end
