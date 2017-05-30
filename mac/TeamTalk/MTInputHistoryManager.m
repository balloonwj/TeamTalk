//
//  MTInputHistoryManager.m
//  Duoduo
//
//  Created by 独嘉 on 15/2/3.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTInputHistoryManager.h"

@implementation MTInputHistoryManager
{
    NSMutableDictionary* _inputHistory;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _inputHistory = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addInputHistory:(NSAttributedString *)historyText forSessionID:(NSString *)sessionID
{
    if ([[_inputHistory allKeys] containsObject:sessionID])
    {
        NSMutableArray* inputHistory = _inputHistory[sessionID];
        [inputHistory insertObject:[historyText copy] atIndex:0];
    }
    else
    {
        NSMutableArray* historyTexts = [[NSMutableArray alloc] init];
        [historyTexts addObject:[historyText copy]];
        [_inputHistory setObject:historyTexts forKey:sessionID];
    }
}

- (NSAttributedString*)getInputHistoryForSessionID:(NSString *)sessionID forIndex:(NSUInteger)index
{
    if ([[_inputHistory allKeys] containsObject:sessionID])
    {
        NSMutableArray* historyInputs = _inputHistory[sessionID];
        if ([historyInputs count] > index)
        {
            return historyInputs[index];
        }
        return nil;
    }
    return nil;
}

@end
