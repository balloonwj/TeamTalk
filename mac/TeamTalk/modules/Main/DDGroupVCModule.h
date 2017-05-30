//
//  DDGroupVCModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTGroupEntity.h"
typedef void(^LoadGroupCompletion)(NSArray* groups);
@interface DDGroupVCModule : NSObject
@property (nonatomic,retain)NSArray* groups;

- (void)loadGroups;
- (NSInteger)indexAtGroups:(MTGroupEntity*)group;
@end
