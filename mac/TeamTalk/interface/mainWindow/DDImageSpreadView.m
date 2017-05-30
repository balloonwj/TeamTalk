//
//  DDmageSpreadView.m
//  Duoduo
//
//  Created by zuoye on 13-11-29.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDImageSpreadView.h"

@implementation DDImageSpreadView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.preferredBounds = NSMakeRect(0, 0, 301, 126);
    }
    return self;
}

/*
-(void)setFrameSize:(NSSize)newSize{
    [super setFrameSize:newSize];
    //[self setBounds:self.preferredBounds];
}
*/

-(void)awakeFromNib{
    self.backgroundImage=[NSImage imageNamed:@"toolbar_bg_theme_gray"];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	//[super drawRect:dirtyRect];
	/*
    NSImage *image=[NSImage imageNamed:@"toolbar_bg_theme_gray"];
    [[NSColor blueColor] set];
    //[[NSColor colorWithPatternImage:image] set];
    NSRectFill(dirtyRect);
     */
    NSSize isize = [self.backgroundImage size];
    [self.backgroundImage drawInRect:[self bounds] fromRect:NSMakeRect(0.0, 0.0,
                                                          isize.width, isize.height) operation: NSCompositeCopy fraction:1.0];
    

    /*
    [image drawInRect:NSMakeRect(0, 0, width, height)
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1];
     
     */
}


@end
