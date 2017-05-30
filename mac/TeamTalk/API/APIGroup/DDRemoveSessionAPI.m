//
//  DDRemoveSessionAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRemoveSessionAPI.h"
#import "IMBuddy.pb.h"

@implementation DDRemoveSessionAPI

/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 5;
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
    return MODULE_ID_SESSION;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return REMOVE_SESSION_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return REMOVE_SESSION_RES;
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
        IMRemoveSessionRsp *rsp = [IMRemoveSessionRsp parseFromData:data];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        UInt32 sessionId = rsp.sessionId;
        SessionType sessionType = rsp.sessionType;
        UInt32 resultCode = rsp.resultCode;
        
        [dic setObject:@(sessionType) forKey:@"sessionType"];
        [dic setObject:@(sessionId) forKey:@"sessionId"];
        [dic setObject:@(resultCode) forKey:@"resultCode"];
        return dic;
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
     
        NSArray* array = (NSArray*)object;
        UInt32 sessionId= (UInt32)[array[0] intValue];
        SessionType sessionType = [array[1] intValue];
        IMRemoveSessionReqBuilder *removeSession = [IMRemoveSessionReq builder];
        [removeSession setUserId:0];
        [removeSession setSessionId:sessionId];
        [removeSession setSessionType:sessionType];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION
                                    cId:REMOVE_SESSION_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[removeSession build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}

@end
