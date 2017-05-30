//
//  DDListWindowController.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListWindowController.h"

@interface DDListWindowController ()

@end

@implementation DDListWindowController


+ (void)initialize
{
	if ([self isEqual:[DDListWindowController class]]) {
		/*
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updateScreenSlideBoundaryRect:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];
		
		[self updateScreenSlideBoundaryRect:nil];
         */
	}
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad{
    contactListController = [[[self listControllerClass] alloc] initWithContactList:[self contactList]
																	  inOutlineView:contactListView
																	   inScrollView:scrollView_contactList
																		   delegate:self];
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (id<DDContainingObject> )contactList
{
	return (contactListRoot ? contactListRoot : [contactListController contactList]);
}

+ (DDListWindowController *)listWindowControllerForContactList:(id<DDContainingObject>)contactList
{
	return [[self alloc] initWithContactList:contactList];
}
- (id)initWithContactList:(id<DDContainingObject>)contactList
{
	if ((self = [self initWithWindowNibName:[[self class] nibName]])) {
		preventHiding = NO;
		previousAlpha = 0;
        /*
		typeToFindEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:@"AIDisableContactListTypeToFind"];
        
         
		[NSBundle loadNibNamed:@"Filter Bar" owner:self];
		*/
         
		[self setContactList:contactList];
	}
	
	return self;
}


- (Class)listControllerClass{
	return [DDListController class];
}

- (void)dealloc{
//    [contactListController close];
}

+ (NSString *)nibName
{
    return @"";
}

- (void)setContactList:(id<DDContainingObject>)inContactList
{
	if (inContactList != contactListRoot) {
		contactListRoot = inContactList;
	}
}

@end
