//
//  DDProxyListObject.h
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

@class ESObjectWithProperties,DDListObject;
@protocol DDContainingObject;

@interface DDProxyListObject : NSObject {
	DDListObject *__weak listObject;
    ESObjectWithProperties <DDContainingObject> *__weak containingObject;
	NSString *key;
	NSString *cachedDisplayNameString;
	NSAttributedString *cachedDisplayName;
	NSDictionary *cachedLabelAttributes;
	NSSize cachedDisplayNameSize;
	NSString *nick;
}
@property (nonatomic, copy) NSDictionary *cachedLabelAttributes;
@property (nonatomic, strong) NSString *cachedDisplayNameString;
@property (nonatomic, strong) NSAttributedString *cachedDisplayName;
@property (nonatomic) NSSize cachedDisplayNameSize;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *nick;

@property (nonatomic, weak) DDListObject *listObject;
@property (nonatomic, weak) ESObjectWithProperties <DDContainingObject> * containingObject;

+ (DDProxyListObject *)proxyListObjectForListObject:(ESObjectWithProperties *)inListObject
									   inListObject:(ESObjectWithProperties<DDContainingObject> *)containingObject;

+ (DDProxyListObject *)existingProxyListObjectForListObject:(ESObjectWithProperties *)inListObject
											   inListObject:(ESObjectWithProperties <DDContainingObject>*)inContainingObject;

+ (DDProxyListObject *)proxyListObjectForListObject:(DDListObject *)inListObject
									   inListObject:(ESObjectWithProperties <DDContainingObject>*)inContainingObject
										   withNick:(NSString *)inNick;

/*!
 * @brief Called when an AIListObject is done with an AIProxyListObject to remove it from the global dictionary
 */
+ (void)releaseProxyObject:(DDProxyListObject *)proxyObject;

/*!
 * @brief Clear out cached display information; should be called when the AIProxyListObject may be used later
 */
- (void)flushCache;

@end