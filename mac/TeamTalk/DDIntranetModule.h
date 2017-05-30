//
//  DDIntranetModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDIntranetEntity.h"

typedef void(^DDIntranetLoadCompletion)();

@interface DDIntranetModule : NSObject
@property(nonatomic,retain)NSMutableArray* intranets;

- (void)loadIntranetsCompletion:(DDIntranetLoadCompletion)completion;
@end
