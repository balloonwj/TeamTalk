//
//  DDSetting+OffLineReadMsgManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-27.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

static NSString* const kOffStateReadSession = @"offStateReadSession";
#import "DDSetting+OffLineReadMsgManager.h"
#import "MTSessionModule.h"

@implementation DDSetting (OffLineReadMsgManager)

- (void)addOffLineReadMsgSessionID:(NSString*)sessionID
{
    NSArray* offStateReadSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kOffStateReadSession];
    NSMutableArray* newOffStateReadSessions = [[NSMutableArray alloc] initWithArray:offStateReadSessions];
    [newOffStateReadSessions addObject:sessionID];
    [[NSUserDefaults standardUserDefaults] setObject:newOffStateReadSessions forKey:kOffStateReadSession];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sendHadReadInOffStatePack
{
//    NSArray* readList = [[NSUserDefaults standardUserDefaults] objectForKey:kOffStateReadSession];
//    DDSessionModule* sessionModule = getDDSessionModule();
//    for (NSString* sessionID in readList)
//    {
//        SessionEntity* session = [sessionModule getSessionBySId:sessionID];
//        [sessionModule tcpSendReadedAck:session];
//    }
}


@end
