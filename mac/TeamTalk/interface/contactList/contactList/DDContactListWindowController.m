//
//  DDContactListWindowController.m
//  Duoduo
//
//  Created by zuoye on 13-11-22.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDContactListWindowController.h"
#import "UserEntity.h"
#import "EGOImageView.h"

#define CONTACTLIST_WINDOW_NIB @"ContactListWindow"
#define TOOLBAR_CONTACT_LIST				@"ContactList:1.0"				//Toolbar identifier

@implementation DDContactListWindowController
@synthesize flickrPhotos;
@synthesize contactListView;


#pragma mark Table view methods

// return an instance of AILoginController
+ (DDContactListWindowController *)contactListWindowControllerWithOwner:(id)inOwner
{
	/* Release self in windowWillClose: */
    return [[self alloc] initWithOwner:inOwner windowNibName:CONTACTLIST_WINDOW_NIB];
}


// Internal --------------------------------------------------------------------------------
// init the login controller
- (id)initWithOwner:(id)inOwner windowNibName:(NSString *)windowNibName
{
	if ((self = [super initWithWindowNibName:windowNibName])) {
		//Retain our owner
        
		//Get the contact list
		//[self updateContactList];
        
	}
	return self;
}

-(void)updateContactList{
    
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [flickrPhotos count];
}



-(void)windowDidLoad{
    NSLog(@"临时联系人列表窗口完成加载 ....%@",[self flickrPhotos]);
    
//    [contactListView setTarget:self];
//    [contactListView setDoubleAction:@selector(doubleClickContactList:)];
//    [contactListView setAction:@selector(selectContactList:)];
}

//- (void) doubleClickContactList: (id)sender
//{
//    NSInteger rowNumber = [contactListView clickedRow];
//    NSLog(@"Double Clicked.%ld ",rowNumber);
//}
//- (void) selectContactList: (id)sender
//{
//     NSLog(@"select Clicked.d - %@ ",contactListView);
//  //  NSInteger rowNumber = [contactListView clickedRow];
//    //NSTableCellView *cellView =
//   
//}


-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    UserEntity *user = flickrPhotos[row];
    NSString *identifier =[tableColumn identifier];
    if ([identifier isEqualToString:@"MainCell"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        [cellView.textField setStringValue:user.name];
       // EGOImageView *temIV =[[EGOImageView alloc] initWithPlaceholderImage:[NSImage imageNamed:@"placeholder.png"]];
        //temIV.imageURL = [NSURL URLWithString:user.avatar];
		cellView.imageView.frame = CGRectMake(4.0f, 4.0f, 36.0f, 36.0f);
        return cellView;
    }
    return nil;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
}

@end
