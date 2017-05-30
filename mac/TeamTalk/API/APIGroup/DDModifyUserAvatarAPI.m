//
//  DDModifyUserAvatarAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-7-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDModifyUserAvatarAPI.h"

@implementation DDModifyUserAvatarAPI
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
    return ServiceIDSidBuddyList;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return ServiceIDSidBuddyList;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_FRI_MODIFY_USER_AVATAR_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_MODIFY_USER_AVATAR_RES;
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
        DataInputStream* bodyData = [DataInputStream dataInputStreamWithData:data];
        uint32_t result = [bodyData readInt];
        if (result == 0)
        {
            //修改成功
            return @(YES);
        }
        else
        {
            //修改失败
            return @(NO);
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
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        NSString* userID = object[0];
        NSString* url = object[1];
        int totalLen = IM_PDU_HEADER_LEN + 4 * 2 + strLen(userID) + strLen(url);
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:CMD_FRI_MODIFY_USER_AVATAR_REQ
                                  seqNo:seqNo];
        [dataout writeUTF:userID];
        [dataout writeUTF:url];
        return [dataout toByteArray];
    };
    return package;
}

@end
