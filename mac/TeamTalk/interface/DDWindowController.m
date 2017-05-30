//
//  DDWindowController.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//
#import "DDWindowController.h"
#import "AIWindowControllerAdditions.h"

@interface DDWindowController ()
+(void)updateScreenBoundariesRect:(id)sender;
@end

@implementation DDWindowController


+(void)updateScreenBoundariesRect:(id)sender{
    
}
- (void)showOnWindow:(id)parentWindow{
    
}
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    
}
- (IBAction)closeWindow:(id)sender{
    
}
- (BOOL)windowShouldClose:(id)sender{
    return YES;
}
- (NSString *)duoduoFrameAutosaveName{
 
    return nil;
}
- (NSString *)savedFrameString{
    
    
    return  nil;
}
- (NSRect)savedFrameFromString:(NSString *)frameString{
  
    
    NSRect		windowFrame = NSRectFromString(frameString);
	NSSize		minFrameSize = [[self window] minSize];
	NSSize		maxFrameSize = [[self window] maxSize];
	
	//Respect the min and max sizes
	if (windowFrame.size.width < minFrameSize.width) windowFrame.size.width = minFrameSize.width;
	if (windowFrame.size.height < minFrameSize.height) windowFrame.size.height = minFrameSize.height;
	if (windowFrame.size.width > maxFrameSize.width) windowFrame.size.width = maxFrameSize.width;
	if (windowFrame.size.height > maxFrameSize.height) windowFrame.size.height = maxFrameSize.height;
	
	//Don't allow the window to shrink smaller than its toolbar
//	NSRect 	contentFrame = [NSWindow contentRectForFrameRect:windowFrame
   //                                                 styleMask:[[self window] styleMask]];
    /*
	if (contentFrame.size.height < [[self window] toolbarHeight]) {
		windowFrame.size.height += [[self window] toolbarHeight] - contentFrame.size.height;
	}
     */
	
	//Make sure the window is visible on-screen
    /*
	if (NSMaxX(windowFrame) < NSMinX(screenBoundariesRect)) windowFrame.origin.x = NSMinX(screenBoundariesRect);
	if (NSMinX(windowFrame) > NSMaxX(screenBoundariesRect)) windowFrame.origin.x = NSMaxX(screenBoundariesRect) - NSWidth(windowFrame);
	if (NSMaxY(windowFrame) < NSMinY(screenBoundariesRect)) windowFrame.origin.y = NSMinY(screenBoundariesRect);
	if (NSMinY(windowFrame) > NSMaxY(screenBoundariesRect)) windowFrame.origin.y = NSMaxY(screenBoundariesRect) - NSHeight(windowFrame);
     */
	
	
	return NSIntegralRect(windowFrame);

}
- (void)windowDidLoad{
    
}
- (void)showWindowInFrontIfAllowed:(BOOL)inFront{
    id currentKeyWindowController = [[NSApp keyWindow] windowController];
	if (currentKeyWindowController && ![currentKeyWindowController shouldResignKeyWindowWithoutUserInput]) {
		//Prevent window from showing in front if key window controller disallows it
		inFront = NO;
	}
	if (inFront) {
		[self showWindow:nil];
	} else {
		[[self window] orderWindow:NSWindowBelow relativeTo:[[NSApp mainWindow] windowNumber]];
	}

}
@end
