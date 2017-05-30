//
//  DDBaseEntity.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDBaseEntity.h"

@implementation DDBaseEntity
-(NSUInteger)getOriginalID
{
    NSArray *array = [self.userId componentsSeparatedByString:@"_"];
    if (array[1]) {
        return array[1];
    }
    return 0;
}

@end
