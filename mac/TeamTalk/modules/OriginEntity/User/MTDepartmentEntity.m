//
//  MTDepartmentEntity.m
//  Duoduo
//
//  Created by zuoye on 15/3/17.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTDepartmentEntity.h"

@implementation MTDepartmentEntity
- (instancetype)initWithDepartmentInfo:(DepartInfo*)departInfo
{
    self = [super init];
    if (self)
    {
        _ID = departInfo.deptId;
        _name = [departInfo.deptName copy];
        _parentID = departInfo.parentDeptId;
        _priority = departInfo.priority;
        _state = departInfo.deptStatus;
    }
    return self;
}

- (instancetype)initWithID:(NSInteger)ID name:(NSString*)name parentID:(NSInteger)parentID priority:(NSInteger)priority state:(DepartmentStatusType)state
{
    self = [super init];
    if (self)
    {
        _ID = ID;
        _name = [name copy];
        _parentID = parentID;
        _priority = priority;
        _state = state;
    }
    return self;
}
@end
