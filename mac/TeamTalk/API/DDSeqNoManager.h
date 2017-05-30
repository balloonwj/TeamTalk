//
//  DDSeqNoManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSeqNoManager : NSObject
+ (instancetype)instance;
- (uint32_t)seqNo;
@end
