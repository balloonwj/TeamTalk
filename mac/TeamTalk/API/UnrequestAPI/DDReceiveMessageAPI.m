//
//  DDReceiveAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDReceiveMessageAPI.h"
#import "MTMessageEntity.h"
#import "IMMessage.pb.h"
#import "MTSessionEntity.h"
@implementation DDReceiveMessageAPI
/**
 *  数据包中的serviceID
 *
 *  @return serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}


/**
 *  数据包中的commandID
 *
 *  @return commandID
 */
- (int)responseCommandID
{
    return CMD_MSG_DATA;
}

/**
 *  解析数据包
 *
 *  @return 解析数据包的block
 */
- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData* data)
    {
        IMMsgData *msgRsp = [IMMsgData parseFromData:data];
        
        MTMessageEntity *message = [[MTMessageEntity alloc] initWithMessageData:msgRsp];
        
        
        return message;
    };
    return analysis;
}

@end
