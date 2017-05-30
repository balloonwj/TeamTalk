//
//  DDStandardListWindowController.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDStandardListWindowController.h"

#define TOOLBAR_CONTACT_LIST				@"ContactList:1.0"				//Toolbar identifier

@interface DDStandardListWindowController ()
- (void)_configureToolbar;
@end

@implementation DDStandardListWindowController

-(id)init{
    self = [super init];
    if (self) {
        NSLog(@" DDSta init....");
    }
    
    
    [self showWindow:nil];
    NSLog(@" ...super window:%@",[self window]);
    return self;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];

    NSLog(@"------>>windowDidLoad....");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[self window] setMinSize:NSMakeSize(135, 60)];
    
    //骚年,给你加个头像如何? 骨德.
    [self _configureToolbar];
}

-(void)updateImagePicker{
    
}


- (void)setPreventHiding:(BOOL)newPreventHiding {
	preventHiding = newPreventHiding;
}

- (void)endWindowSlidingDelay
{
	[self setPreventHiding:NO];
}

- (void)delayWindowSlidingForInterval:(NSTimeInterval)inDelayTime
{
	[self setPreventHiding:YES];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(endWindowSlidingDelay)
											   object:nil];
	[self performSelector:@selector(endWindowSlidingDelay)
			   withObject:nil
			   afterDelay:inDelayTime];
}

- (void)showWindowInFrontIfAllowed:(BOOL)inFront
{
	//Always show for three seconds at least if we're told to show
	[self delayWindowSlidingForInterval:3];
    
	//Call super to actually do the showing
	[super showWindowInFrontIfAllowed:inFront];
	
	NSWindow	*window = [self window];
	
    /*
	if ([self windowSlidOffScreenEdgeMask] != AINoEdges) {
		[self slideWindowOnScreenWithAnimation:NO];
	}
	
	windowSlidOffScreenEdgeMask = AINoEdges;
	*/
    
	currentScreen = [window screen];
	currentScreenFrame = [currentScreen frame];
    
	if ([[NSScreen screens] count] &&
		(currentScreen == [[NSScreen screens] objectAtIndex:0])) {
		currentScreenFrame.size.height -= [[NSApp mainMenu] menuBarHeight];
	}
    
	//Ensure the window is displaying at the proper level and expos√© setting
	//[self setWindowLevel:levelForAIWindowLevel(windowLevel)];
}



#pragma mark Table view methods



#pragma mark Toolbar
//Install our toolbar
- (void)_configureToolbar
{
    NSLog(@" 配置工具栏..%@",[self window]);
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:TOOLBAR_CONTACT_LIST];
	
	[toolbar setAutosavesConfiguration:YES];
    [toolbar setDelegate:self];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setAllowsUserCustomization:NO];
	
	@try
	{
		[[self window] setToolbar:toolbar];
	}
	@catch(id exc)
	{
		NSLog(@"Warning: While setting the contact list's toolbar, exception %@ was thrown.", exc);
	}
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObject:@"StatusAndIcon"];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObject:@"StatusAndIcon"];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *statusAndIconItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"StatusAndIcon"];
	[statusAndIconItem setMinSize:NSMakeSize(100, [view_statusAndImage bounds].size.height)];
	[statusAndIconItem setMaxSize:NSMakeSize(100000, [view_statusAndImage bounds].size.height)];
	[statusAndIconItem setView:view_statusAndImage];
	
	return statusAndIconItem;
}

/*!
 * @brief Nib name
 */
+ (NSString *)nibName
{
    return @"ContactListWindow";
}

@end
