//
//  DDAddChatGroup.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAddChatGroup : NSObject
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSMutableArray* users;
@property (nonatomic,retain)DDAddChatGroup* groups;
@property (nonatomic,assign)NSInteger priority;
@property (nonatomic,assign)NSInteger departmentID;
@property (nonatomic,assign)NSInteger parentDepartmentID;
@end
