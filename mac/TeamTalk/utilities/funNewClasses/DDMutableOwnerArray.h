//
//  DDMutableOwnerArray.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//


#define Highest_Priority  	0.0f
#define High_Priority  		0.25f
#define Medium_Priority  	0.5f
#define Low_Priority  		0.75f
#define Lowest_Priority  	1.0f

@class DDMutableOwnerArray;

//Delegate protocol for documentation purposes; it is not necessary to declare conformance to this protocol.
@protocol DDMutableOwnerArrayDelegate
- (void)mutableOwnerArray:(DDMutableOwnerArray *)inArray didSetObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority;
@end

/*!
 * @class AIMutableOwnerArray
 * @brief An container object that keeps track of who owns each of its objects.
 *
 * Every object in the \c AIMutableOwnerArray has an associated owner.  The best use for this class is when
 * multiple pieces of code may be trying to control the same thing.  For instance, if there are several events that can
 * cause something to change colors, by using an owner-array it is possible to prevent conflicts and determine an
 * average color based on all the values.  It's also easy for a specific owner to remove the value they contributed,
 * or replace it with another.
 *
 * An owner can only own one object in a given \c AIMutableOwnerArray.
 *
 * Floating point priority levels can be used to dictate the ordering of objects in the array.
 * Lower numbers have higher priority.
 */
@interface DDMutableOwnerArray : NSObject <NSFastEnumeration> {
	NSMutableArray	*contentArray;
	NSMutableArray	*ownerArray;
	NSMutableArray	*priorityArray;
	
	BOOL			valueIsSortedToFront;
	
	id				delegate;
	BOOL			delegateRespondsToDidSetObjectWithOwnerPriorityLevel;
}

#pragma mark Value Storage

/*!
 * @brief Store an object with an owner at default (medium) priority
 *
 * Calls <code>setObject:withOwner:priorityLevel:</code> with a priorityLevel of Medium_Priority.
 * Pass nil to remove the object
 */
- (void)setObject:(id)anObject withOwner:(id)inOwner;
/*!
 * @brief Store an object with an owner and a priority
 *
 *	<p>Stores an object in the array with a specified owner at a given priority</p>
 *	@param anObject An object to store
 *	@param inOwner The owner of the object
 *  @param priority priority is a float from 0.0 to 1.0, with 0.0 the highest-priority (earliest in the array). Possible preset values are:
 *			- Highest_Priority
 *			- High_Priority
 *			- Medium_Priority
 *			- Low_Priority
 *			- Lowest_Priority
 */
- (void)setObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority;

#pragma mark Value Retrieval

/*!
 * @brief Highest priority object
 *
 * @result The object with the highest priority, performing no other comparison
 */
@property (weak, readonly, nonatomic) id objectValue;
/*!
 * @brief Greatest NSNumber value
 *
 * Assumes the \c AIMutableOwnerArray contains \c NSNumber instances
 * @result Returns the greatest (highest value) contained \c NSNumber value.
 */
@property (weak, readonly, nonatomic) NSNumber *numberValue;
/*!
 * @brief Greatest integer value
 *
 * Assuming the \c AIMutableOwnerArray contains \c NSNumber instances, returns the \c intValue of the greatest (highest-valued) one.
 * @return  Returns the greatest contained integer value.
 */
@property (readonly, nonatomic) NSInteger intValue;
/*!
 * @brief Greatest double value
 *
 * Assuming the \c AIMutableOwnerArray contains \c NSNumber instances, returns the \c doubleValue of the greatest (highest-valued) one.
 * @return  Returns the greatest contained double value.
 */
@property (readonly, nonatomic) double doubleValue;
/*!
 * @brief Earliest date
 *
 * Assuming the \c AIMutableOwnerArray contains \c NSDate instances, returns the earliest one.
 * @return  Returns the earliest contained date.
 */
@property (weak, readonly, nonatomic) NSDate *date;
/*!
 * @brief Retrieve object by owner
 *
 * Retrieve the object within the \c AIMutableOwnerArray owned by the specified owner.
 * @param inOwner The owner
 * @return  Returns the object owned by \a inOwner.
 */
- (id)objectWithOwner:(id)inOwner;
/*!
 * @brief Retrieve priority by owner
 *
 * Retrieve the priority of the object within the \c AIMutableOwnerArray owned by the specified owner.
 * @param inOwner An owner
 * @return  Returns the priority of the object owned by \a inOwner, or 0 if no object is owned by the owner.
 */
- (float)priorityOfObjectWithOwner:(id)inOwner;
/*!
 * @brief Retrieve owner by object
 *
 * Retrieve the owner within the \c AIMutableOwnerArray which owns the specified object.  If multiple owners own a single object, returns the one with the highest priority.
 * @param anObject An object
 * @return  Returns the owner which owns \a inObject.
 */
- (id)ownerWithObject:(id)anObject;
/*!
 * @brief Retrieve priority by object
 *
 * Retrieve the priority of an object within the \c AIMutableOwnerArray.
 * @param inObject An object
 * @return Returns the priority of the object, or 0 if the object is not in the array.
 */
- (float)priorityOfObject:(id)inObject;
/*!
 * @brief Retrieve enumerator for objects
 *
 * Retrieve an \c NSEnumerator for all objects in the \c AIMutableOwnerArray. Order is not guaranteed.
 * @return  Returns \c NSEnumerator for all objects.
 */
@property (weak, readonly, nonatomic) NSEnumerator *objectEnumerator;
/*!
 * @brief Retrieve array of values
 *
 * Retrieve an \c NSArray for all objects in the \c AIMutableOwnerArray. Order is not guaranteed.
 * @return  Returns \c NSArray for all objects.
 */
@property (readonly, nonatomic) NSArray *allValues;
/*!
 * @brief Retrieve number of objects
 *
 * Retrieve the number of objects in the \c AIMutableOwnerArray.
 * @return  Returns an unsigned of the number of objects.
 */
@property (readonly, nonatomic) NSUInteger count;

//Delegation
/*!
 * @brief Delegate
 *
 * The delegate may implement:<br>
 * <code>- (void)mutableOwnerArray:(AIMutableOwnerArray *)inArray didSetObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority</code><br>
 * to be notified with the \c AIMutableOwnerArray is modified.
 * @param inDelegate The delegate
 */
@property (readwrite, nonatomic, weak) id delegate;

@end