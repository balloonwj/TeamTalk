//
//  DDSendOffLineFileAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSendOffLineFileAPI.h"

@implementation DDSendOffLineFileAPI
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
    return MODULE_ID_FILETRANSFER;
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
    return CMD_FILE_UPLOAD_OFFLINE_NOTIFY;
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
    Package package = (id)^(id object,uint16_t seqNo)
    {
        NSArray* array = (NSArray*)object;
        NSString* fromUserId = array[0];
        NSString* toUserId = array[1];
        NSString* filePath = array[2];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 * 3 +
        strLen(fromUserId) + strLen(toUserId) + strLen(filePath);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_FILETRANSFER cId:CMD_FILE_UPLOAD_OFFLINE_NOTIFY seqNo:seqNo];
        [dataout writeUTF:fromUserId];
        [dataout writeUTF:toUserId];
        [dataout writeUTF:filePath];
        
        log4CInfo(@"serviceID:%i cmdID:%i --> uoload offline file from user:%@ to user:%@ filePath:%@",MODULE_ID_FILETRANSFER,CMD_FILE_UPLOAD_OFFLINE_NOTIFY,fromUserId,toUserId,filePath);
        
        return [dataout toByteArray];
    };
    return package;
}
@end
