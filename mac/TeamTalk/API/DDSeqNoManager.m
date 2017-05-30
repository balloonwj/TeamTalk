//
//  DDSeqNoManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSeqNoManager.h"

@implementation DDSeqNoManager
{
    uint32_t _seqNo;
}
+ (instancetype)instance
{
    static DDSeqNoManager* g_seqNoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_seqNoManager = [[DDSeqNoManager alloc] init];
    });
    return g_seqNoManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _seqNo = 0;
    }
    return self;
}


- (uint32_t)seqNo
{
    _seqNo ++;
    return _seqNo;
}
@end
