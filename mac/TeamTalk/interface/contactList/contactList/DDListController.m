//
//  DDListController.m
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListController.h"
#import "DDPerson.h"
@implementation DDListController

- (id)initWithContactList:(id<DDContainingObject>)aContactList
			inOutlineView:(DDListOutlineView *)inContactListView
			 inScrollView:(DDAutoScrollView *)inScrollView_contactList
				 delegate:(id<DDListControllerDelegate>)inDelegate{
    
  //  NSParameterAssert(aContactList != nil);
    if ((self = [self initWithContactListView:inContactListView inScrollView:inScrollView_contactList delegate:inDelegate])) {
    
    
    }
    
    return self;
}


-(void)close{
    
}

-(void)dealloc{
    
}

//Content Updating -----------------------------------------------------------------------------------------------------
#pragma mark Content Updating

- (id<DDContainingObject>)contactList
{
	return (id<DDContainingObject>)contactList;
}

- (void)reloadListObject:(NSNotification *)notification{
	DDListObject *object = notification.object;
	
    /*
	//Treat a nil object as equivalent to the whole contact list
	if (!object || (object == (DDListObject *)contactList)) {
		[contactListView reloadData];
	} else {
		for (AIProxyListObject *proxyObject in object.proxyObjects) {
            if ([(AIListObject<AIContainingObject> *)proxyObject.listObject isExpanded])
                [contactListView reloadItem:proxyObject reloadChildren:YES];
            else
                [contactListView reloadItem:proxyObject reloadChildren:NO];
        }
	}
     */
}

//Outline View data source ---------------------------------------------------------------------------------------------
#pragma mark Outline View data source


#pragma mark NSOutlineView Data Source Methods

/*

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return !item ? [self.people count] : [[item children] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return !item ? YES : [[item children] count] != 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return !item ? self.people[index] : [item children][index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSLog(@" >>>> objectValueForTableColumn: %@",item);
    if ([[tableColumn identifier] isEqualToString:@"name"])
        return [item name];
    else if ([[tableColumn identifier] isEqualToString:@"age"])
        return @([item age]);
    return @"Nobody's Here!";
}

 */

@end
