//
//  DDUserMsgReceivedACKAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserMsgReceivedACKAPI.h"

@implementation DDUserMsgReceivedACKAPI

/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 0;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return MODULE_ID_SESSION;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return 0;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_MSG_DATA_ACK;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return 0;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    return nil;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        NSArray* array = (NSArray*)object;
        
        NSString* fromUserId = array[0];
        int theSeqNo = [array[1] intValue];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 * 2 + strLen(fromUserId);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION cId:CMD_MSG_DATA_ACK seqNo:seqNo];
        
        [dataout writeInt:(int32_t)theSeqNo];
        [dataout writeUTF:fromUserId];
        
        log4CInfo(@"serviceID:%i cmdID:%i --> send msgData ACK from userID:%@",MODULE_ID_SESSION,CMD_MSG_DATA_ACK,fromUserId);
        
        return [dataout toByteArray];
    };
    return package;
}

@end
