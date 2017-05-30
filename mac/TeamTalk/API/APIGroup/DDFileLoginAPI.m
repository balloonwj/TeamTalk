//
//  DDFileLoginAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDFileLoginAPI.h"

@implementation DDFileLoginAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 2;
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
    return MODULE_ID_FILETRANSFER;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_FILE_LOGIN_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FILE_LOGIN_RES;
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
        DataInputStream *inputData = [DataInputStream dataInputStreamWithData:data];
        uint32_t result = [inputData readInt];
        DDLog(@"handleFileLoginRes, result=%d", result);
        return [NSNumber numberWithInt:result];
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
        NSString* userId = array[0];
        NSString* token = array[1];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        uint32_t totalLen = 8 + IM_PDU_HEADER_LEN +
        (uint32_t)[[userId dataUsingEncoding:NSUTF8StringEncoding] length] +
        (uint32_t)[[token dataUsingEncoding:NSUTF8StringEncoding] length];
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_FILETRANSFER cId:CMD_FILE_LOGIN_REQ seqNo:seqNo];
        [dataout writeUTF:userId];
        [dataout writeUTF:token];
        log4CInfo(@"serviceID:%i cmdID:%i --> login file server userID:%@ token:%@",
                  MODULE_ID_FILETRANSFER, CMD_FILE_LOGIN_REQ, userId,token);
        return [dataout toByteArray];
    };
    return package;
}
@end
