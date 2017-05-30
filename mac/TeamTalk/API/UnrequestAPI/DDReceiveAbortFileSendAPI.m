//
//  DDReceiveAbortFileSendAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDReceiveAbortFileSendAPI.h"
#import "FileTransferEntity.h"

@implementation DDReceiveAbortFileSendAPI

/**
 *  数据包中的serviceID
 *
 *  @return serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_FILETRANSFER;
}

/**
 *  数据包中的commandID
 *
 *  @return commandID
 */
- (int)responseCommandID
{
    return CMD_FILE_ABORT;
}

/**
 *  解析数据包
 *
 *  @return 解析数据包的block
 */
- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData* object)
    {
        DataInputStream* bodyData = [DataInputStream dataInputStreamWithData:object];
        NSString *fromUserId = [bodyData readUTF];
        NSString *toUserId = [bodyData readUTF];
        NSString *filePath = [bodyData readUTF];
        DDLog(@"handleFileAbort, %@->%@", fromUserId, toUserId);
        FileTransferEntity* entity = [[FileTransferEntity alloc] init];
        entity.fromUserId = fromUserId;
        entity.toUserId = toUserId;
        entity.fileName = filePath;
        return entity;
    };
    return analysis;
}


@end
