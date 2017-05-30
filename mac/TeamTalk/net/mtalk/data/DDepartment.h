//
//  DDepartment.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-06.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDepartment : NSObject
@property(strong)NSString *ID;
@property(strong)NSString *parentID;
@property(strong)NSString *title;
@property(strong)NSString *description;
@property(strong)NSString *leader;
@property(assign)NSInteger status;
@property(assign)NSInteger count;
+(id)departmentFromDic:(NSDictionary *)dic;
@end
