//
//  DDListObject.m
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListObject.h"

#define DisplayName			@"Display Name"
#define LongDisplayName		@"Long Display Name"
#define Key					@"Key"
#define Group				@"Group"
#define DisplayServiceID	@"DisplayServiceID"
#define AlwaysVisible		@"alwaysVisible"


@implementation DDListObject
@synthesize UID;


-(id)initWithUID:(NSString *)inUID{
    if ((self = [super init])) {
        UID=inUID;
    }
    
    return self;
}



- (NSString *)longDisplayName
{
    NSString	*outName = [self displayArrayObjectForKey:LongDisplayName];
	
    return outName ? outName : self.displayName;
}
@end
