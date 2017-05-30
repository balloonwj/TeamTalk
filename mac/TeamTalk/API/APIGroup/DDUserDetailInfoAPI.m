//
//  DDUserDetailInfoAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserDetailInfoAPI.h"
#import "IMBuddy.pb.h"
#import "MTUserEntity.h"

@implementation DDUserDetailInfoAPI
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
    return CMD_FRI_LIST_DETAIL_INFO_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_LIST_DETAIL_INFO_RES;
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
        IMUsersInfoRsp *userInfoRsp = [IMUsersInfoRsp parseFromData:data];
//        NSString* userID = [NSString stringWithFormat:@"%i",userInfoRsp.userId];
        NSArray* usersInfoList = userInfoRsp.userInfoList;
        NSMutableArray* userInfos = [[NSMutableArray alloc] init];
        for (UserInfo* userInfo in usersInfoList)
        {
            MTUserEntity* user = [[MTUserEntity alloc] initWithUserInfo:userInfo];
            [userInfos addObject:user];
        }
        return userInfos;

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
        IMUsersInfoReqBuilder *userInfoReqBuilder = [IMUsersInfoReq builder];
        int myUserID = [[DDClientState shareInstance].userID intValue];
        [userInfoReqBuilder setUserId:myUserID];
        
        NSArray* toRequestUserIDs = (NSArray*)object;
        NSMutableArray* userIDs = [[NSMutableArray alloc] init];
        for (NSString* userID in toRequestUserIDs)
        {
            int userIDInt = [userID intValue];
            [userIDs addObject:@(userIDInt)];
        }
        [userInfoReqBuilder setUserIdListArray:userIDs];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION
                                    cId:CMD_FRI_LIST_DETAIL_INFO_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[userInfoReqBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
