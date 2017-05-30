//
//  MTUnreadMessageManager.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTUnreadMessageManager : NSObject

- (void)setUnreadMessageCounnt:(NSUInteger)count forSessionID:(NSString*)sessionID;
- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID;
- (NSUInteger)getUnreadMessageCount;
- (void)clearUnreadMesageCountForSessionID:(NSString*)sessionID;
- (void)clearAllUnreadMessageCount;
- (void)addUnreadMesageCountForSessionID:(NSString*)sessionID;
-(NSString *)getLastUnreadSessionId;
@end
