//
//  MTDraftManager.h
//  Duoduo
//
//  Created by 独嘉 on 15/2/3.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDraftManager : NSObject

/**
 *  获取指定session ID的草稿
 *
 *  @param sessionID 指定session ID
 *
 *  @return 富文本草稿
 */
- (NSAttributedString*)getDraftForSessionID:(NSString*)sessionID;

/**
 *  设置指定session ID的草稿
 *
 *  @param draft     草稿
 *  @param sessionID 指定sessionID
 */
- (void)setDraft:(NSAttributedString*)draft forSessionID:(NSString*)sessionID;

@end
