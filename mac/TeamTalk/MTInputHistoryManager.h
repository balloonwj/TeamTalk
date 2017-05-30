//
//  MTInputHistoryManager.h
//  Duoduo
//
//  Created by 独嘉 on 15/2/3.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTInputHistoryManager : NSObject


/**
 *  添加历史发送文本
 *
 *  @param historyText 历史发送文本
 */
- (void)addInputHistory:(NSAttributedString*)historyText forSessionID:(NSString*)sessionID;

/**
 *  获取指定索引位置的历史文本
 *
 *  @param historyText 历史文本
 *  @param index       索引
 */
- (NSAttributedString*)getInputHistoryForSessionID:(NSString *)sessionID forIndex:(NSUInteger)index;

@end
