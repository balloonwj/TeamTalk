//
//  MTDepartmentManager.h
//  Duoduo
//
//  Created by zuoye on 15/3/17.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDepartmentEntity.h"
@interface MTDepartmentManager : NSObject

+ (instancetype)shareInstance;

- (NSArray*)departments;

- (MTDepartmentEntity*)getDepartmentForID:(NSInteger)ID;
@end
