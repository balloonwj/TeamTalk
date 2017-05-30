//
//  MTDraftManager.m
//  Duoduo
//
//  Created by 独嘉 on 15/2/3.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTDraftManager.h"

@implementation MTDraftManager
{
    NSMutableDictionary* _draftDic;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _draftDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSAttributedString*)getDraftForSessionID:(NSString *)sessionID
{
    return _draftDic[sessionID];
}


- (void)setDraft:(NSAttributedString *)draft forSessionID:(NSString *)sessionID
{
    [_draftDic setObject:[draft copy] forKey:sessionID];
    NSAttributedString* session = _draftDic[sessionID];
}

@end
