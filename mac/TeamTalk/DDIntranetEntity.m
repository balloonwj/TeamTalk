//
//  DDIntranetEntity.m
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetEntity.h"

@implementation DDIntranetEntity
- (id)initWithInfo:(NSDictionary*)info
{
    self = [super init];
    if (self)
    {
        _ID = [info[@"id"] integerValue];
        _name = info[@"itemName"];
        _priority = [info[@"itemPriority"] integerValue];
        _createdTime = [info[@"created"] integerValue];
        _itemURL = info[@"itemUrl"];
        _status = [info[@"status"] integerValue];
    }
    return self;
}
@end
