//
//  DDAbstractListController.m
//  Duoduo
//
//  Created by zuoye on 13-11-26.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDAbstractListController.h"
#import "DDListOutlineView.h"
#import "DDAutoScrollView.h"
#import "DDPerson.h"
#import "DDProxyListObject.h"
#import "ESObjectWithProperties.h"
#import "DDListGroup.h"
#import "DDListCell.h"


@interface DDAbstractListController ()
- (void)displayableContainedObjectsDidChange:(NSNotification *)notification;

@end

@implementation DDAbstractListController
@synthesize contactListView;

- (id)init {
    self = [super init];
    if (self) {
        _people = [[NSMutableArray alloc] init];
        DDPerson *boss = [[DDPerson alloc] initWithName:@"Yoda" age:900];
        [boss addChild:[[DDPerson alloc] initWithName:@"Stephan" age:20]];
        [boss addChild:[[DDPerson alloc] initWithName:@"Taylor" age:18]];
        [boss addChild:[[DDPerson alloc] initWithName:@"Jesse" age:19]];
        
        [(DDPerson *)boss.children[0] addChild:[[DDPerson alloc] initWithName:@"Lucas" age:18]];
        
        [_people addObject:boss];
    }
    return self;
}

- (void)setContactListRoot:(ESObjectWithProperties<DDContainingObject> *)newContactListRoot{
	if (contactList != newContactListRoot) {
		contactList = newContactListRoot;
	}
    
	[contactListView reloadData];
}

- (ESObjectWithProperties<DDContainingObject> *)contactListRoot{
	return contactList;
}

-(id)initWithContactListView:(DDListOutlineView *)inContactListView inScrollView:(DDAutoScrollView *)inScrollView_contactList delegate:(id<DDListControllerDelegate>)inDelegate{
    if ((self = [super init])) {
        contactListView = inContactListView;        //这货就是联系人列表了.
        scrollView_contactList = inScrollView_contactList;
        delegate = inDelegate;
        
        hideRoot = YES;
        
        
        //加各种观察者.
        NSLog(@" 加各种观察者..然后contactListView是:%@",contactListView);
        _people = [[NSMutableArray alloc] init];
        DDPerson *boss = [[DDPerson alloc] initWithName:@"Yoda" age:900];
        [boss addChild:[[DDPerson alloc] initWithName:@"Stephan" age:20]];
        [boss addChild:[[DDPerson alloc] initWithName:@"Taylor" age:18]];
        [boss addChild:[[DDPerson alloc] initWithName:@"Jesse" age:19]];
        
        [(DDPerson *)boss.children[0] addChild:[[DDPerson alloc] initWithName:@"Lucas" age:18]];
        
        [_people addObject:boss];
        
        [contactListView setDelegate:self];
        [contactListView setDataSource:self];


    }
    
    return self;
}

-(id)delegate{
    return delegate;
}

-(void)dealloc{
    [contactListView setDelegate:nil];
	[contactListView setDataSource:nil];
    
	scrollView_contactList = nil;
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHideRoot:(BOOL)inHideRoot{
	hideRoot = inHideRoot;
	[contactListView reloadData];
}




//Outline View data source ---------------------------------------------------------------------------------------------
#pragma mark Outline View data source

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)idx ofItem:(DDProxyListObject *)item {
    //return !item ? self.people[idx] : [item children][idx];
    
    DDProxyListObject *proxyListObject;
    
	if (item) {
		id<DDContainingObject> listObject = (id<DDContainingObject>)(item.listObject);
        //根据index从可见列表中取要显示的对象.
		proxyListObject = [DDProxyListObject proxyListObjectForListObject:[listObject visibleObjectAtIndex:idx]
															 inListObject:listObject];

	} else if (hideRoot) {
		/*
        if ([contactList isKindOfClass:[DDGroupChat class]]) {
			NSString *nick = [(DDGroupChat *)contactList visibleObjectAtIndex:idx];
			DDListObject *listObject = [(DDGroupChat *)contactList contactForNick:nick];
			
			proxyListObject = [DDProxyListObject proxyListObjectForListObject:listObject
																 inListObject:contactList
																	 withNick:nick];
		} else {
			proxyListObject = [DDProxyListObject proxyListObjectForListObject:[contactList visibleObjectAtIndex:idx]
																 inListObject:contactList];
		}
         */
        proxyListObject = [DDProxyListObject proxyListObjectForListObject:[contactList visibleObjectAtIndex:idx]
                                                             inListObject:contactList];
	} else
		proxyListObject = [DDProxyListObject proxyListObjectForListObject:contactList
															 inListObject:nil];
	return proxyListObject;
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(DDProxyListObject *)item
{
	NSInteger children;
    
	if (item) {
		id<DDContainingObject> listObject = (id<DDContainingObject>)(item.listObject);
        
		children = listObject.visibleCount;
	} else if (hideRoot)
		children = ((id<DDContainingObject>)contactList).visibleCount;
	else
		children = 1;
	
	return children;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(DDProxyListObject *)item
{
	if ([outlineView isKindOfClass:[DDListOutlineView class]]) {
		[(DDListCell *)cell setProxyListObject:item];
		[(DDListCell *)cell setControlView:(DDListOutlineView *)outlineView];
		[(DDListCell *)cell setIndentation:indentationPerLevel[[outlineView levelForItem:item]]];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(DDProxyListObject *)item{
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(DDProxyListObject *)item{

	return (!item || ([item.listObject conformsToProtocol:@protocol(DDContainingObject)] &&
					  ((id<DDContainingObject>)(item.listObject)).isExpandable));
}


@end
