//
//  DDListGroup.m
//  Duoduo
//
//  Created by zuoye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListGroup.h"
#import "DDContactObserverManager.h"


@interface DDListObject ()
- (void)setContainingGroup:(DDListGroup *)inGroup;
@end

@interface DDListGroup ()
- (void) rebuildVisibleCache;
@end


@implementation DDListGroup
@synthesize visibleCount;
@synthesize contactList;

-(id)initWithUID:(NSString *)inUID{
    if ((self=[super initWithUID:inUID] )) {
        _visibleObjects = [[NSMutableArray alloc] init];
		_containedObjects = [[NSMutableArray alloc] init];
    }
    
    /*
    if ((self = [super initWithUID:inUID service:nil])) {
		_visibleObjects = [[NSMutableArray alloc] init];
		_containedObjects = [[NSMutableArray alloc] init];
		expanded = YES;
		[[DDContactObserverManager sharedManager] registerListObjectObserver:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildVisibleCache) name:CONTACT_VISIBILITY_OPTIONS_CHANGED_NOTIFICATION object:nil];
	}
     */
	
	return self;
}

-(NSUInteger)visibleIndexOfObject:(DDListObject *)object{
    return [_visibleObjects indexOfObject:object];
}


- (void)dealloc
{
	//[[DDContactObserverManager sharedManager] unregisterListObjectObserver:self];
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
