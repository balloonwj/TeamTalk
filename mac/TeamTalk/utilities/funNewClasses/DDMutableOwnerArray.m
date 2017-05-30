//
//  DDMutableOwnerArray.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDMutableOwnerArray.h"


@interface DDMutableOwnerArray ()
- (id)_objectWithHighestPriority;
- (void)_moveObjectToFront:(int)objectIndex;
- (void)_createArrays;
- (void)_destroyArrays;
- (void)mutableOwnerArray:(DDMutableOwnerArray *)mutableOwnerArray didSetObject:(id)anObject withOwner:(id)inOwner;
@end

@implementation DDMutableOwnerArray

//Init
- (id)init
{
	if ((self = [super init])) {
		contentArray = nil;
		ownerArray = nil;
		priorityArray = nil;
		valueIsSortedToFront = NO;
		delegate = nil;
	}
    
	return self;
}

//Dealloc
- (void)dealloc
{
	delegate = nil;
	
	[self _destroyArrays];
}


- (NSString *)description
{
	NSMutableString	*desc = [[NSMutableString alloc] initWithFormat:@"<%@: %p: ", NSStringFromClass([self class]), self];
	NSUInteger	i = 0;
	
	for (id object in self) {
		[desc appendFormat:@"(%@:%@:%@)%@", [ownerArray objectAtIndex:i], object, [priorityArray objectAtIndex:i], (object == [contentArray lastObject] ? @"" : @", ")];
		i++;
	}
	[desc appendString:@">"];
	
	return desc;
}


//Value Storage --------------------------------------------------------------------------------------------------------
#pragma mark Value Storage

- (void)setObject:(id)anObject withOwner:(id)inOwner
{
	[self setObject:anObject withOwner:inOwner priorityLevel:Medium_Priority];
}

- (void)setObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority
{
    NSUInteger	ownerIndex;
	//Keep priority in bounds
	if ((priority < Highest_Priority) || (priority > Lowest_Priority)) priority = Medium_Priority;
    
	//Remove any existing objects from this owner
	ownerIndex = [ownerArray indexOfObject:inOwner];
	if (ownerArray && (ownerIndex != NSNotFound)) {
		[ownerArray removeObjectAtIndex:ownerIndex];
		[contentArray removeObjectAtIndex:ownerIndex];
		[priorityArray removeObjectAtIndex:ownerIndex];
	}
	
	//Add the new object
	if (anObject) {
		//If we haven't created arrays yet, do so now
		if (!ownerArray) [self _createArrays];
		
		//Add the object
		[ownerArray addObject:inOwner];
		[contentArray addObject:anObject];
		[priorityArray addObject:[NSNumber numberWithFloat:priority]];
	}
    
	//Our array may no longer have the return value sorted to the front, clear this flag so it can be sorted again
	valueIsSortedToFront = NO;
	
	if (delegate && delegateRespondsToDidSetObjectWithOwnerPriorityLevel) {
		[delegate mutableOwnerArray:self didSetObject:anObject withOwner:inOwner priorityLevel:priority];
	}
}

//The method the delegate would implement, here to make the compiler happy.
- (void)mutableOwnerArray:(DDMutableOwnerArray *)mutableOwnerArray didSetObject:(id)anObject withOwner:(id)inOwner {};

//Value Retrieval ------------------------------------------------------------------------------------------------------
#pragma mark Value Retrieval

- (id)objectValue
{
    return ((ownerArray && [ownerArray count]) ? [self _objectWithHighestPriority] : nil);
}

- (NSNumber *)numberValue
{
	NSUInteger count;
	if (ownerArray && (count = [ownerArray count])) {
		//If we have more than one object and the object we want is not already in the front of our arrays,
		//we need to find the object with largest int value and move it to the front
		if (count != 1 && !valueIsSortedToFront) {
			NSNumber 	*currentMax = [NSNumber numberWithInt:0];
			int			indexOfMax = 0;
			int			idx = 0;
			
			//Find the object with the largest int value
			for (idx = 0;idx < count;idx++) {
				NSNumber	*value = [contentArray objectAtIndex:idx];
                
				if ([value compare:currentMax] == NSOrderedDescending) {
					currentMax = value;
					indexOfMax = idx;
				}
			}
			
			//Move the object to the front, so we don't have to find it next time
			[self _moveObjectToFront:indexOfMax];
			
			return currentMax;
		} else {
			return [contentArray objectAtIndex:0];
		}
	}
	return 0;
}

- (NSInteger)intValue
{
	NSUInteger count;
	if (ownerArray && (count = [ownerArray count])) {
		//If we have more than one object and the object we want is not already in the front of our arrays,
		//we need to find the object with largest int value and move it to the front
		if (count != 1 && !valueIsSortedToFront) {
			NSInteger 	currentMax = 0;
			int		indexOfMax = 0;
			int		idx = 0;
			
			//Find the object with the largest int value
			for (idx = 0;idx < count;idx++) {
				NSInteger	value = [[contentArray objectAtIndex:idx] integerValue];
				
				if (value > currentMax) {
					currentMax = value;
					indexOfMax = idx;
				}
			}
			
			//Move the object to the front, so we don't have to find it next time
			[self _moveObjectToFront:indexOfMax];
			
			return currentMax;
		} else {
			return [[contentArray objectAtIndex:0] integerValue];
		}
	}
	return 0;
}

- (double)doubleValue
{
	NSUInteger count;
	if (ownerArray && (count = [ownerArray count])) {
		
		//If we have more than one object and the object we want is not already in the front of our arrays,
		//we need to find the object with largest double value and move it to the front
		if (count != 1 && !valueIsSortedToFront) {
			double  currentMax = 0;
			int		indexOfMax = 0;
			int		idx = 0;
			
			//Find the object with the largest double value
			for (idx = 0;idx < count;idx++) {
				double	value = [[contentArray objectAtIndex:idx] doubleValue];
				
				if (value > currentMax) {
					currentMax = value;
					indexOfMax = idx;
				}
			}
			
			//Move the object to the front, so we don't have to find it next time
			[self _moveObjectToFront:indexOfMax];
			
			return currentMax;
		} else {
			return [[contentArray objectAtIndex:0] doubleValue];
		}
	}
	
	return 0;
}

- (NSDate *)date
{
	NSInteger count;
	if (ownerArray && (count = [ownerArray count])) {
		//If we have more than one object and the object we want is not already in the front of our arrays,
		//we need to find the object with largest double value and move it to the front
		if (count != 1 && !valueIsSortedToFront) {
			NSDate  *currentMax = nil;
			int		indexOfMax = 0;
			int		idx = 0;
			
			//Find the object with the earliest date
			for (idx = 0;idx < count;idx++) {
				NSDate	*value = [contentArray objectAtIndex:idx];
				
				if (!currentMax || [currentMax timeIntervalSinceDate:value] > 0) {
					currentMax = value;
					indexOfMax = idx;
				}
			}
			
			//Move the object to the front, so we don't have to find it next time
			[self _moveObjectToFront:indexOfMax];
			
			return currentMax;
		} else {
			return [contentArray objectAtIndex:0];
		}
	}
	return nil;
}

- (id)_objectWithHighestPriority
{
	//If we have more than one object and the object we want is not already in the front of our arrays,
	//we need to find the object with highest priority and move it to the front
	if ([priorityArray count] != 1 && !valueIsSortedToFront) {
		CGFloat			currentMax = Lowest_Priority;
		int				indexOfMax = 0;
		int				idx = 0;
		
		//Find the object with highest priority
		for (NSNumber *priority in priorityArray) {
			float	value = [priority floatValue];
			if (value < currentMax) {
				currentMax = value;
				indexOfMax = idx;
			}
			idx++;
		}
        
		//Move the object to the front, so we don't have to find it next time
		[self _moveObjectToFront:indexOfMax];
	}
    
	return [contentArray objectAtIndex:0];
}

//Move an object to the front of our arrays
- (void)_moveObjectToFront:(int)objectIndex
{
	if (objectIndex != 0) {
		[contentArray exchangeObjectAtIndex:objectIndex withObjectAtIndex:0];
		[ownerArray exchangeObjectAtIndex:objectIndex withObjectAtIndex:0];
		[priorityArray exchangeObjectAtIndex:objectIndex withObjectAtIndex:0];
	}
	valueIsSortedToFront = YES;
}


//Returns an object with the specified owner
- (id)objectWithOwner:(id)inOwner
{
    if (ownerArray && contentArray) {
        NSUInteger	idx = [ownerArray indexOfObject:inOwner];
        if (idx != NSNotFound) return [contentArray objectAtIndex:idx];
    }
    
    return nil;
}

- (float)priorityOfObjectWithOwner:(id)inOwner
{
	if (ownerArray && priorityArray) {
        NSUInteger	idx = [ownerArray indexOfObject:inOwner];
		if (idx != NSNotFound) return [[priorityArray objectAtIndex:idx] floatValue];
	}
	return 0.0f;
}

- (id)ownerWithObject:(id)inObject
{
    if (ownerArray && contentArray) {
        NSUInteger	idx = [contentArray indexOfObject:inObject];
        if (idx != NSNotFound) return [ownerArray objectAtIndex:idx];
    }
    
    return nil;
}

- (float)priorityOfObject:(id)inObject
{
	if (contentArray && priorityArray) {
        NSUInteger	idx = [contentArray indexOfObject:inObject];
		if (idx != NSNotFound) return [[priorityArray objectAtIndex:idx] floatValue];
	}
	return 0.0f;
}

- (NSEnumerator *)objectEnumerator
{
	return [contentArray objectEnumerator];
}

@synthesize allValues = contentArray;

- (NSUInteger)count
{
    return [contentArray count];
}

//Array creation / Destruction -----------------------------------------------------------------------------------------
#pragma mark Array creation / Destruction
//We don't actually create our arrays until needed.  There are many places where a mutable owner array
//is created and not actually used to store anything, so this saves us a bit of ram.
//Create our storage arrays
- (void)_createArrays
{
	contentArray = [[NSMutableArray alloc] init];
	priorityArray = [[NSMutableArray alloc] init];
	ownerArray = [[NSMutableArray alloc] init];
}

//Destroy our storage arrays
- (void)_destroyArrays
{
	contentArray = nil;
	priorityArray = nil;
	ownerArray = nil;
}

//Delegation -----------------------------------------------------------------------------------------
#pragma mark Delegation
- (void)setDelegate:(id)inDelegate
{
	delegate = inDelegate;
	
	delegateRespondsToDidSetObjectWithOwnerPriorityLevel = [delegate respondsToSelector:@selector(mutableOwnerArray:didSetObject:withOwner:priorityLevel:)];
}

- (id)delegate
{
	return delegate;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len;
{
	return [contentArray countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end