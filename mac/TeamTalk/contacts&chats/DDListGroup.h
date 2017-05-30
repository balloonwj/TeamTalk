//
//  DDListGroup.h
//  Duoduo
//
//  Created by zuoye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDListObject.h"
#import "DDContactObserverManager.h"

@class DDContactList;

//联系人里一组用户. duoduo 暂时只有一组用户.
@interface DDListGroup : DDListObject<DDContainingObject,DDListObjectObserver>{
    NSMutableArray		*_visibleObjects;
	NSMutableArray		*_containedObjects;	//Manually ordered array of contents
	BOOL									expanded;			//Exanded/Collapsed state of this object
	BOOL									loadedExpanded;
}
- (id)initWithUID:(NSString *)inUID;

//Object Storage
- (DDListObject *)objectWithServiceUID:(NSString *)inUID;

//Sorting (PRIVATE: For contact controller only)
- (void)sortListObject:(DDListObject *)inObject;
- (void)sort;

//Visibility
@property (readonly, nonatomic) NSUInteger visibleCount;

@property (weak, readonly, nonatomic) DDContactList *contactList;
@end
