//
//  DDGetLastMessageIDAPI.m
//  Duoduo
//
//  Created by 独嘉 on 15/3/3.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "DDGetLastMessageIDAPI.h"
#import "IMMessage.pb.h"
@implementation DDGetLastMessageIDAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 8;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_MSG_GET_LASTEST_MSG_ID_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_MSG_GET_LASTEST_MSG_ID_RES;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMGetLatestMsgIdRsp* getLastestMsgIDRsp = [IMGetLatestMsgIdRsp parseFromData:data];
//        NSString* requestUserID = [NSString stringWithFormat:@"%i",getLastestMsgIDRsp.userId];
//        SessionType sessionType = getLastestMsgIDRsp.sessionType;
//        NSString* originID = [NSString stringWithFormat:@"%i",getLastestMsgIDRsp.sessionId];
        int lastMsgId = getLastestMsgIDRsp.latestMsgId;
        
        return @(lastMsgId);
    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint16_t seqNo)
    {
        IMGetLatestMsgIdReqBuilder *req = [IMGetLatestMsgIdReq builder];
        [req setUserId:[[DDClientState shareInstance].userID intValue]];
        
        NSArray* array = (NSArray*)object;
        SessionType sessionType = [array[0] intValue];
        int originID = [array[1] intValue];
        
        [req setSessionType:sessionType];
        [req setSessionId:originID];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:CMD_MSG_GET_LASTEST_MSG_ID_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
