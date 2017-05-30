//
//  MTDepartmentEntity.h
//  Duoduo
//
//  Created by zuoye on 15/3/17.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBuddy.pb.h"
@interface MTDepartmentEntity : NSObject
@property (nonatomic,assign)NSInteger ID;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,assign)NSInteger parentID;
@property (nonatomic,assign)NSInteger priority;
@property (nonatomic,assign)DepartmentStatusType state;
- (instancetype)initWithDepartmentInfo:(DepartInfo*)departInfo;

- (instancetype)initWithID:(NSInteger)ID name:(NSString*)name parentID:(NSInteger)parentID priority:(NSInteger)priority state:(DepartmentStatusType)state;
@end
