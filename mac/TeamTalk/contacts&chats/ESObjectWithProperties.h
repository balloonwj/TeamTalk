//
//  ESObjectWithProperties.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//


@class DDMutableOwnerArray;

typedef enum {
	NotifyNever = -9999,
	NotifyLater = NO,   /* 0 */
	NotifyNow = YES		/* 1 */
} NotifyTiming;

#define KEY_KEY		@"Key"
#define KEY_VALUE	@"Value"

@interface ESObjectWithProperties : NSObject {
	NSMutableDictionary		*propertiesDictionary;
	NSMutableSet			*changedProperties;		//Properties that have changed since the last notification
	
	NSMutableDictionary		*displayDictionary;		//A dictionary of values affecting this object's display
	
	NSMutableSet *proxyObjects;
}

//Setting properties
- (void)setValue:(id)value forProperty:(NSString *)key notify:(NotifyTiming)notify;
- (void)setValue:(id)value forProperty:(NSString *)key afterDelay:(NSTimeInterval)delay;
- (void)notifyOfChangedPropertiesSilently:(BOOL)silent;

//Getting properties
@property (readonly, nonatomic) NSDictionary *properties;
- (id)valueForProperty:(NSString *)key;
- (NSInteger)integerValueForProperty:(NSString *)key;
- (int)intValueForProperty:(NSString *)key;
- (BOOL)boolValueForProperty:(NSString *)key;
- (NSNumber *)numberValueForProperty:(NSString *)key;

//Properties: Specifically for subclasses
- (void)object:(id)inObject didChangeValueForProperty:(NSString *)key notify:(NotifyTiming)notify;
- (void)didModifyProperties:(NSSet *)keys silent:(BOOL)silent;
- (void)didNotifyOfChangedPropertiesSilently:(BOOL)silent;


//Display array
- (DDMutableOwnerArray *)displayArrayForKey:(NSString *)inKey;
- (DDMutableOwnerArray *)displayArrayForKey:(NSString *)inKey create:(BOOL)create;
- (id)displayArrayObjectForKey:(NSString *)inKey;

//Name
@property (readonly, nonatomic, retain) NSString *displayName;

@property (readonly, nonatomic) NSString *internalObjectID;

//Mutable owner array delegate method
- (void)mutableOwnerArray:(DDMutableOwnerArray *)inArray didSetObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority;

- (NSSet *)proxyObjects;
- (void)noteProxyObject:(id)proxyObject;
@end
