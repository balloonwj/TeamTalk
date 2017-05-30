//
//  EmotionCellView.m
//  Duoduo
//
//  Created by jianqing.du on 14-1-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "EmotionCellView.h"
#import "EmotionViewController.h"


@implementation EmotionCellView {
    BOOL drawRect;
    NSBezierPath *path;
}

@synthesize emotionFile;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self.imageView setEnabled:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    if (drawRect && self.imageView.objectValue) {
        NSRect bounds = [self bounds];

        [[NSColor blueColor] set];
        [path removeAllPoints];
        [path appendBezierPathWithRect:bounds];
        [path stroke];
    } else {
        [path removeAllPoints];
        [path stroke];
    }
}

- (void)awakeFromNib
{
    NSTrackingArea *trackArea =
    [[NSTrackingArea alloc] initWithRect:[self bounds]
                                 options:NSTrackingMouseEnteredAndExited |  NSTrackingActiveInKeyWindow
                                   owner:self
                                userInfo:nil];
    [self addTrackingArea:trackArea];
    
    path = [NSBezierPath bezierPath];
    [path setLineWidth:1.5];
}

-(IBAction)buttonClick:(id)sender
{
    [self.delegate selectEmotion:self];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    drawRect = YES;
    [self setNeedsDisplay:YES];
    [self.delegate mouseEnterEmotion:self];
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    drawRect = NO;
    [self setNeedsDisplay:YES];
    [self.delegate mouseExitEmotion:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    DDLog(@"move down in cell view");
    [super mouseDown:theEvent];
    [self.delegate selectEmotion:self];
}


@end
