//
//  DDUserOnlineStateAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserOnlineStateAPI.h"
#import "IMBuddy.pb.h"
#import "IMBaseDefine.pb.h"

@implementation DDUserOnlineStateAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 10;
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
    return CMD_FRI_LIST_STATE_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_LIST_STATE_RES;
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
        IMUsersStatRsp *rsp = [IMUsersStatRsp parseFromData:data];
        return rsp;
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
//        UserStatBuilder *userBuilder = [UserStat builder];
//        [userBuilder setUserId:656];
//        [userBuilder setStatus:UserStatTypeUserStatusOnline];
        
        IMUsersStatReqBuilder *reqBuilder = [IMUsersStatReq builder];
        [reqBuilder setUserId:0];
        NSArray* userList = [[NSArray alloc]initWithObjects:@(656), nil];
        [reqBuilder setUserIdListArray:userList];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION
                                    cId:CMD_FRI_LIST_STATE_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
