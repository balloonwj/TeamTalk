//
//  DDIntranetMessageEntity.m
//  Duoduo
//
//  Created by 独嘉 on 14-7-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetMessageEntity.h"

@implementation DDIntranetMessageEntity
- (id)initWithAuthor:(NSString*)author content:(NSString*)content time:(NSUInteger)time fromUserID:(NSString*)fromUserID
{
    self = [super init];
    if (self)
    {
        _author = [author copy];
        _content = [content copy];
        _time = time;
        _fromUserID = [fromUserID copy];
    }
    return self;
}
@end
