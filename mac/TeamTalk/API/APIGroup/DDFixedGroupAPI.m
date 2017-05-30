//
//  DDFixedGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDFixedGroupAPI.h"
#import "MTGroupEntity.h"
#import "IMGroup.pb.h"
#import "DataOutputStream+Addition.h"
@implementation DDFixedGroupAPI
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
    return ServiceIDSidGroup;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return ServiceIDSidGroup;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return GroupCmdIDCidGroupNormalListRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return GroupCmdIDCidGroupNormalListResponse;
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
        IMNormalGroupListRsp *allGroupRsp = [IMNormalGroupListRsp parseFromData:data];
        NSMutableDictionary *groupIdAndVersion = [NSMutableDictionary new];
        NSMutableArray* groupList = [[NSMutableArray alloc] init];
        for (GroupVersionInfo *groupVersionInfo in allGroupRsp.groupVersionList) {
            NSString* groupId = [[NSNumber numberWithInt:groupVersionInfo.groupId] stringValue];
            NSString* version = [[NSNumber numberWithInt:groupVersionInfo.version] stringValue];
            NSMutableDictionary* groupVersion = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupId,@"groupId",version,@"version",nil];
            [groupList addObject:groupVersion];
        }
        [groupIdAndVersion setObject:groupList forKey:@"groupVersionList"];
        return groupIdAndVersion;
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
        IMNormalGroupListReqBuilder *req = [IMNormalGroupListReq builder];

        UInt32 reqUserId = [[object objectForKey:@"reqUserId"] intValue];
        [req setUserId:reqUserId];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
