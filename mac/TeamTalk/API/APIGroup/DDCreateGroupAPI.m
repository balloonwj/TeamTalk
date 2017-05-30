//
//  DDCreateGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDCreateGroupAPI.h"
#import "MTGroupEntity.h"
#import "IMGroup.pb.h"
#import "DataOutputStream+Addition.h"

@implementation DDCreateGroupAPI
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
    return CMD_ID_GROUP_CREATE_TMP_GROUP_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_CREATE_TMP_GROUP_RES;
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
        IMGroupCreateRsp *rsp = [IMGroupCreateRsp parseFromData:data];
        uint32_t result = rsp.resultCode;
        MTGroupEntity* group = nil;
        if (result != 0)
        {
            return group;
        }
        else
        {
            NSString* creatorId = [NSString stringWithFormat:@"%d",rsp.userId];
            NSString *groupId = [NSString stringWithFormat:@"%d", rsp.groupId];
            NSString *groupName = rsp.groupName;
            NSInteger userCnt =[rsp.userIdList count];
            
            NSMutableArray* groupUserIds = [[NSMutableArray alloc] init];
            
            for (uint32_t i = 0; i < userCnt; i++) {
                NSInteger userIdFromServer = [rsp.userIdList[i] integerValue];
                NSString* userId = [NSString stringWithFormat:@"%ld", userIdFromServer];
                [groupUserIds addObject:userId];
            }
            group = [[MTGroupEntity alloc] initWithGroupID:groupId groupType:DDTmpGroupType name:groupName avatar:@"" creatorId:creatorId shieldStatus:NO groupUserIds:groupUserIds version:1];
            return group;
        }
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
        NSString* groupName = array[0];
        NSString* groupAvatar = array[1];
        NSArray* groupUserList = array[2];
        
        IMGroupCreateReqBuilder *req = [IMGroupCreateReq builder];
        [req setUserId:0];
        [req setGroupName:groupName];
        [req setGroupAvatar:groupAvatar];
        [req setGroupType:GroupTypeGroupTypeTmp];
        NSMutableArray *originalID = [NSMutableArray new];
        for (NSString *localID in groupUserList) {
            int groupId = [localID intValue];
            [originalID addObject: @(groupId)];
        }
        [req setMemberIdListArray:originalID];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SERVICE_GROUP
                                    cId:CMD_ID_GROUP_CREATE_TMP_GROUP_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;}
@end
