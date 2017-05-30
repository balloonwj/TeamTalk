//
//  DDListWindowController.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDWindowController.h"
#import "DDListController.h"
#import "DDListObject.h"
#import "DDAutoScrollView.h"
#import "DDAnimatingListOutlineView.h"

#warning 这里跟很多个超类有着错综复杂的关系...
@interface DDListWindowController : DDWindowController<DDListControllerDelegate>{
    DDListObject<DDContainingObject>  *contactListRoot;
    
    BOOL                                borderless;
	
	NSSize								minWindowSize;
	IBOutlet DDAutoScrollView			*scrollView_contactList;
    IBOutlet DDAnimatingListOutlineView	*contactListView;
    DDListController					*contactListController;
    
    // used by the "show contact list" event behavior to prevent the contact list
	// from hiding during the amount of time it is to be shown
	BOOL								preventHiding;
	BOOL								overrodeWindowLevel;
    
    CGFloat								previousAlpha;
    
    NSRect								oldFrame;
	NSScreen							*currentScreen;
	NSRect								currentScreenFrame;
}


- (void)setContactList:(id<DDContainingObject>)contactList;

+ (DDListWindowController *)listWindowControllerForContactList:(id<DDContainingObject>)contactList;

@end
