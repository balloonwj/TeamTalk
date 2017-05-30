//
//  DDSetting+OffLineReadMsgManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-27.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSetting.h"

@interface DDSetting (OffLineReadMsgManager)
- (void)addOffLineReadMsgSessionID:(NSString*)sessionID;
- (void)sendHadReadInOffStatePack;
@end
