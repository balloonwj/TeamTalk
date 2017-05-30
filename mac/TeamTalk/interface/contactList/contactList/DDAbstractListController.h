//
//  DDAbstractListController.h
//  Duoduo
//
//  Created by zuoye on 13-11-26.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>




@class DDAutoScrollView,DDListOutlineView,ESObjectWithProperties,DDListContactCell,DDListGroupCell,DDListObject;
@protocol DDContainingObject;

@protocol DDListControllerDelegate
- (IBAction)performDefaultActionOnSelectedObject:(DDListObject *)selectedObject sender:(NSOutlineView *)sender;
@end

//更新联系人列表
@interface DDAbstractListController : NSObject<NSOutlineViewDataSource,NSOutlineViewDelegate>{
    DDAutoScrollView					*scrollView_contactList;
	DDListOutlineView				*contactListView;
    
	DDListContactCell				*contentCell;
	DDListGroupCell					*groupCell;
    id	delegate;
	ESObjectWithProperties<DDContainingObject> *contactList;
    BOOL									configuredViewsAndTooltips;
    BOOL									hideRoot;
    int									indentationPerLevel[9];
}

@property (readonly, nonatomic) DDListOutlineView *contactListView;


- (id)initWithContactListView:(DDListOutlineView *)inContactListView inScrollView:(DDAutoScrollView *)inScrollView_contactList delegate:(id<DDListControllerDelegate>)inDelegate;
- (id)delegate;

- (void)setContactListRoot:(ESObjectWithProperties<DDContainingObject> *)newContactListRoot;
- (void)reloadData;
- (void)setHideRoot:(BOOL)inHideRoot;

#pragma just for test
@property (copy) NSMutableArray *people;

@end
