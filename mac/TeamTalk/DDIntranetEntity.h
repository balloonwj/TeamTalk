//
//  DDIntranetEntity.h
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDIntranetEntity : NSObject
@property (nonatomic,assign)NSInteger ID;
@property (nonatomic,assign)NSUInteger createdTime;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,assign)NSInteger priority;
@property (nonatomic,retain)NSString* itemURL;
@property (nonatomic,assign)NSInteger status;
- (id)initWithInfo:(NSDictionary*)info;
@end
