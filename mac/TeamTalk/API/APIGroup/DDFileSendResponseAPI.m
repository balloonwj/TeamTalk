//
//  DDFileSendResponseAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDFileSendResponseAPI.h"

@implementation DDFileSendResponseAPI
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
    return CMD_FILE_RESPONSE;
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
        NSString* fileName = array[2];
        int acceptFlag = [array[3] intValue];
        NSString* listenIp = nil;
        int listenPort = 0;
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 * 5 + 2 +
        strLen(fromUserId) + strLen(toUserId) + strLen(fileName);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_FILETRANSFER cId:CMD_FILE_RESPONSE seqNo:seqNo];
        [dataout writeUTF:fromUserId];
        [dataout writeUTF:toUserId];
        [dataout writeUTF:fileName];
        [dataout writeInt:acceptFlag];
        [dataout writeUTF:listenIp];
        [dataout writeShort:listenPort];
        log4CInfo(@"serviceID:%i cmdID:%i --> send file get response from user:%@ to user:%@ fileName:%@ acceptType:%i listenIP:%@ listenPort:%i",MODULE_ID_FILETRANSFER,CMD_FILE_RESPONSE,fromUserId,toUserId,fileName,acceptFlag,listenIp,listenPort);
        return [dataout toByteArray];
    };
    return package;
}
@end
