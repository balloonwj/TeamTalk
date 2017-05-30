//
//  DDListObject.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "ESObjectWithProperties.h"

// 对列表对象的抽象封装.
@interface DDListObject : ESObjectWithProperties{
    NSString *UID;
}

- (id)initWithUID:(NSString *)inUID;

@property (readonly, nonatomic) NSString *UID;
@property (weak, readonly, nonatomic) NSString *longDisplayName;

@end




@protocol DDContainingObject <NSObject, NSFastEnumeration>

@property (readonly, copy, nonatomic) NSArray *visibleContainedObjects;
@property (readonly, copy, nonatomic) NSArray *containedObjects;
- (NSUInteger) countOfContainedObjects;
@property (readonly, nonatomic) NSArray *uniqueContainedObjects;
@property (readwrite, nonatomic, getter=isExpanded) BOOL expanded;
@property (readonly, nonatomic, getter=isExpandable) BOOL expandable;

@property (readonly, nonatomic)  NSString *contentsBasedIdentifier;
@property (readonly, nonatomic) NSUInteger visibleCount;


- (BOOL)containsObject:(DDListObject *)inObject;

/*!
 * As NSArray's -objectAtIndex:, except that it only looks at visible objects contained in this object
 */
- (DDListObject *)visibleObjectAtIndex:(NSUInteger)index;

/*!
 * As NSArray's -indexOfObject:, except that it looks at visible objects contained in this object
 */
- (NSUInteger)visibleIndexOfObject:(DDListObject *)object;


//- (DDListObject *)objectWithService:(DDService *)inService UID:(NSString *)inUID;




@end