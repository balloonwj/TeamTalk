//
//  MTDepartmentManager.m
//  Duoduo
//
//  Created by zuoye on 15/3/17.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTDepartmentManager.h"
#import "DDDepartmentInfoAPI.h"
#import "MTDepartmentEntity.h"
#import "MTDatabaseUtil.h"

@interface MTDepartmentManager(PrivateAPI)

- (void)p_loadLocalDepartments;
- (void)p_loadRemoteDepartments;
- (void)p_mergeLocalAndRemoteDepartments:(NSArray*)remoteDepartments;
- (void)p_addDepartment:(MTDepartmentEntity*)department;
- (void)p_sortDepartments;

@end

@implementation MTDepartmentManager
{
    NSMutableArray* _departments;
    NSMutableDictionary* _departmentsDic;
}
+ (instancetype)shareInstance
{
    static MTDepartmentManager* g_departmentManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_departmentManager = [[MTDepartmentManager alloc] init];
    });
    return g_departmentManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _departments = [[NSMutableArray alloc] init];
        [[DDClientState shareInstance] addObserver:self
                                        forKeyPath:DD_USER_STATE_KEYPATH
                                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                           context:nil];
    }
    return self;
}

- (NSArray*)departments
{
    return _departments;
}

- (MTDepartmentEntity*)getDepartmentForID:(NSInteger)ID
{
    MTDepartmentEntity* department = _departmentsDic[@(ID)];
    return department;
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH])
    {
        DDUserState oldUserState = [change[@"old"] intValue];
        DDUserState newUserState = [change[@"new"] intValue];
        if (oldUserState != newUserState && newUserState == DDUserOnline)
        {
            [self p_loadRemoteDepartments];
        }
        else if (oldUserState != DDUserLogining && newUserState == DDUserLogining)
        {
            [self p_loadLocalDepartments];
        }
    }
}

#pragma mark -
#pragma mark PrivateAPI
- (void)p_loadLocalDepartments
{
    _departments = [[NSMutableArray alloc] init];
    NSArray* departmentsInDB = [[MTDatabaseUtil instance] queryDepartments];
    _departments = [[NSMutableArray alloc] initWithArray:departmentsInDB];
    
    _departmentsDic = [[NSMutableDictionary alloc] init];
    [departmentsInDB enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTDepartmentEntity* department = obj;
        [_departmentsDic setObject:obj forKey:@(department.ID)];
    }];
}

- (void)p_loadRemoteDepartments
{
    DDDepartmentInfoAPI* departmentInfoAPI = [[DDDepartmentInfoAPI alloc] init];
    [departmentInfoAPI requestWithObject:@[@(0)] Completion:^(id response, NSError *error) {
        if (!error && [response isKindOfClass:[NSDictionary class]])
        {
            NSInteger lastUpdateTime = [response[@"lastUpdateTime"] intValue];
            NSArray* departments = response[@"departments"];
            [self p_mergeLocalAndRemoteDepartments:departments];
            [self p_sortDepartments];
        }
    }];
}

- (void)p_mergeLocalAndRemoteDepartments:(NSArray*)remoteDepartments
{
    [remoteDepartments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTDepartmentEntity* departmentEntity = (MTDepartmentEntity*)obj;
        [self p_addDepartment:departmentEntity];
    }];
}

- (void)p_addDepartment:(MTDepartmentEntity*)department
{
    __block NSUInteger index = INT_MAX;
    [_departments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MTDepartmentEntity* oldDepartment = (MTDepartmentEntity*)obj;
        if (oldDepartment.ID == department.ID)
        {
            index = idx;
            *stop = YES;
        }
    }];
    if (index != INT_MAX)
    {
        [_departments replaceObjectAtIndex:index withObject:department];
    }
    
    [_departmentsDic setObject:department forKey:@(department.ID)];
}

- (void)p_sortDepartments
{
    [_departments sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MTDepartmentEntity* department1 = (MTDepartmentEntity*)obj1;
        MTDepartmentEntity* department2 = (MTDepartmentEntity*)obj2;
        if (department1.priority > department2.priority)
        {
            return NSOrderedAscending;
        }
        else if (department1.priority < department2.priority)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

@end
