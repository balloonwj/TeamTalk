//
//  DDGroupInfoAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupInfoAPI.h"
#import "MTGroupEntity.h"
#import "IMGroup.pb.h"
@implementation DDGroupInfoAPI
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
    return SERVICE_GROUP;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return SERVICE_GROUP;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_ID_GROUP_USER_LIST_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_USER_LIST_RES;
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
        IMGroupInfoListRsp* groupInfoRsp = [IMGroupInfoListRsp parseFromData:data];
        uint32_t userId = groupInfoRsp.userId;
        NSMutableDictionary *groupInfoAndReqUserId = [NSMutableDictionary new];
        [groupInfoAndReqUserId setObject:@(userId) forKey:@"reqUserId"];
        NSMutableArray *groupList = [[NSMutableArray alloc] init];
        for (GroupInfo *groupInfo in groupInfoRsp.groupInfoList) {
            MTGroupEntity *groupEntity = [[MTGroupEntity alloc] initWithGroupInfo:(GroupInfo *)groupInfo];
            [groupList addObject:groupEntity];
        }
        
        [groupInfoAndReqUserId setObject:groupList forKey:@"groupList"];
        return groupInfoAndReqUserId;
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
    Package package = (id)^(id object,uint32_t seqNo)
    {
        IMGroupInfoListReqBuilder *reqBuilder = [IMGroupInfoListReq builder];
        UInt32 reqUserId = [[object objectForKey:@"reqUserId"] intValue];
        [reqBuilder setUserId:reqUserId];
        NSMutableArray* groupVersionList = [object objectForKey:@"groupVersionList"];
        NSMutableArray* groupVersionListArray = [[NSMutableArray alloc] init];
        for (NSDictionary* groupVersionInfo in groupVersionList) {
            GroupVersionInfoBuilder* groupInfoReqBuilder = [GroupVersionInfo builder];
            UInt32 groupId = [[groupVersionInfo objectForKey:@"groupId"] intValue];
            UInt32 version = [[groupVersionInfo objectForKey:@"version"] intValue];
            [groupInfoReqBuilder setGroupId:groupId];
            [groupInfoReqBuilder setVersion:version];
            [groupVersionListArray addObject:groupInfoReqBuilder.build];
        }
        [reqBuilder setGroupVersionListArray:groupVersionListArray];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SERVICE_GROUP
                                    cId:CMD_ID_GROUP_USER_LIST_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
