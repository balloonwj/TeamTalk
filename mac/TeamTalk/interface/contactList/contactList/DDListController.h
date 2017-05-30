//
//  DDListController.h
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDAbstractListController.h"

@interface DDListController : DDAbstractListController{
    
}


- (id)initWithContactList:(id<DDContainingObject>)aContactList
			inOutlineView:(DDListOutlineView *)inContactListView
			 inScrollView:(DDAutoScrollView *)inScrollView_contactList
				 delegate:(id<DDListControllerDelegate>)inDelegate;

- (id<DDContainingObject>) contactList;


- (void)reloadListObject:(NSNotification *)notification;

@end
