//
//  DDGetOfflineFileAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGetOfflineFileAPI.h"

@implementation DDGetOfflineFileAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 4;
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
    return CMD_FILE_HAS_OFFLINE_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FILE_HAS_OFFLINE_RES;
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
        uint32_t fileCnt = [bodyData readInt];
        NSMutableArray *fileList = [[NSMutableArray alloc] init];
        
        if (fileCnt > 0) {
            for (uint32_t i = 0; i < fileCnt; i++) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                NSString *fromId = [bodyData readUTF];
                uint32_t fileId = [bodyData readInt];
                uint32_t fileSize = [bodyData readInt];
                NSString *filePath = [bodyData readUTF];
                [dict setObject:fromId forKey:@"fromId"];
                [dict setObject:[NSNumber numberWithInt:fileId] forKey:@"fileId"];
                [dict setObject:[NSNumber numberWithInt:fileSize] forKey:@"fileSize"];
                [dict setObject:filePath forKey:@"filePath"];
                [fileList addObject:dict];
            }
        }
        
        return fileList;
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
        
        [dataout writeInt:IM_PDU_HEADER_LEN];
        [dataout writeTcpProtocolHeader:MODULE_ID_FILETRANSFER cId:CMD_FILE_HAS_OFFLINE_REQ seqNo:seqNo];
        log4CInfo(@"serviceID:%i cmdID:%i --> get has offline file or not",MODULE_ID_FILETRANSFER,CMD_FILE_HAS_OFFLINE_REQ);
        return [dataout toByteArray];
    };
    return package;
}
@end
