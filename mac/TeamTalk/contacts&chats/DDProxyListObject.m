//
//  DDProxyListObject.m
//  Duoduo
//
//  Created by zuoye on 13-11-27.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDProxyListObject.h"
#import "DDListObject.h"
#import "ESObjectWithProperties.h"


@interface NSObject (PublicAPIMissingFromHeadersAndDocsButInTheReleaseNotesGoshDarnit)
- (id)forwardingTargetForSelector:(SEL)aSelector;
@end

@implementation DDProxyListObject

@synthesize key, cachedDisplayName, cachedDisplayNameString, cachedLabelAttributes, cachedDisplayNameSize;
@synthesize listObject, containingObject, nick;


static inline NSMutableDictionary *_getProxyDict() {
    static NSMutableDictionary *proxyDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDict = [[NSMutableDictionary alloc] init];
    });
    return proxyDict;
}

#define proxyDict _getProxyDict()

+ (DDProxyListObject *)existingProxyListObjectForListObject:(DDListObject *)inListObject
											   inListObject:(ESObjectWithProperties <DDContainingObject>*)inContainingObject
{
	NSString *key = (inContainingObject ?
					 [NSString stringWithFormat:@"%@-%@", inListObject.internalObjectID, inContainingObject.internalObjectID] :
					 inListObject.internalObjectID);
	
	return [proxyDict objectForKey:key];
}

+ (DDProxyListObject *)proxyListObjectForListObject:(DDListObject *)inListObject
									   inListObject:(ESObjectWithProperties <DDContainingObject>*)inContainingObject
{
	return [self proxyListObjectForListObject:inListObject inListObject:inContainingObject withNick:nil];
}

+ (DDProxyListObject *)proxyListObjectForListObject:(DDListObject *)inListObject
									   inListObject:(ESObjectWithProperties <DDContainingObject>*)inContainingObject
										   withNick:(NSString *)inNick
{
	DDProxyListObject *proxy;
	NSString *key = (inContainingObject ?
					 [NSString stringWithFormat:@"%@-%@", inListObject.internalObjectID, inContainingObject.internalObjectID] :
					 inListObject.internalObjectID);
	
	if (inNick) {
		key = [key stringByAppendingFormat:@"-%@", inNick];
	}
    
	proxy = [proxyDict objectForKey:key];
    
	if (proxy && proxy.listObject != inListObject) {
        /* This is generally a memory management failure; AIContactController stopped tracking a list object, but it never deallocated and
		 * so never called [AIProxyListObject releaseProxyObject:]. -evands 8/28/11
		 */
	//	AILogWithSignature(@"%@ was leaked! Meh. We'll recreate the proxy for %@.", proxy.listObject, proxy.key);
		[self releaseProxyObject:proxy];
		proxy = nil;
	}
    
	if (!proxy) {
		proxy = [[DDProxyListObject alloc] init];
		proxy.listObject = inListObject;
		proxy.containingObject = inContainingObject;
		proxy.key = key;
		proxy.nick = inNick;
		[inListObject noteProxyObject:proxy];
		[proxyDict setObject:proxy
					  forKey:key];
	}
    
	return proxy;
}

- (void)flushCache
{
	self.cachedDisplayName = nil;
	self.cachedDisplayNameString = nil;
	self.cachedLabelAttributes = nil;
}

/*!
 * @brief Called when an AIListObject is done with an AIProxyListObject to remove it from the global dictionary
 *
 * This should be called only by AIListObject when it deallocates, for each of its proxy objects
 */
+ (void)releaseProxyObject:(DDProxyListObject *)proxyObject
{
	proxyObject.listObject = nil;
	[proxyObject flushCache];
	[proxyDict removeObjectForKey:proxyObject.key];
}

- (void)dealloc
{
    [self flushCache];
}

/* Pretend to be our listObject. I suspect being an NSProxy subclass could do this more cleanly, but my initial attempt
 * failed and this works fine.
 */
- (Class)class
{
	return [[self listObject] class];
}

- (BOOL)isKindOfClass:(Class)class
{
	return [[self listObject] isKindOfClass:class];
}

- (BOOL)isMemberOfClass:(Class)class
{
	return [[self listObject] isMemberOfClass:class];
}

- (BOOL)isEqual:(id)inObject
{
	return [[self listObject] isEqual:inObject];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return [self listObject];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<DDProxyListObject %p -> %@>", self, [self listObject]];
}

@end
