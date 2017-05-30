//
//  DDSendMessageAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSendMessageAPI.h"
#import "IMMessage.pb.h"
#import "security.h"
#include <iostream>

@implementation DDSendMessageAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 8;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_MSG_DATA;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_MSG_DATA_ACK;
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
        IMMsgDataAck *allMessageRsp = [IMMsgDataAck parseFromData:data];
        NSUInteger mesageServerID = allMessageRsp.msgId;
        return @(mesageServerID);
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
        IMMsgDataBuilder *req = [IMMsgData builder];
        NSArray* array = (NSArray*)object;
        MsgType msgType;
        switch ([array[2] intValue]) {
            case SessionTypeSessionTypeGroup:
                msgType = MsgTypeMsgTypeGroupText;
                break;
            case SessionTypeSessionTypeSingle:
                msgType = MsgTypeMsgTypeSingleText;
                break;
            default:
                msgType = MsgTypeMsgTypeGroupText;
                NSAssert(NO, @"不知道的会话类型");
                break;
        }
        
        NSString *strMessage = array[3];
        
        //加密数据内容.
        std::string *strMsg =new std::string([strMessage UTF8String]);
        char* pOut;
        uint32_t nLen=0;
        int nRet =EncryptMsg(strMsg->c_str(), (uint32_t)strMsg->length(), &pOut, nLen);
         if (nRet != 0) {
             printf(" **** 加密错误:code= %d",nRet);
            strMessage=@"";
         }
         else{
             strMessage = [NSString stringWithUTF8String:pOut];

             Free(pOut);
         }
        
        delete strMsg;
        
        NSData* messageText = [strMessage dataUsingEncoding:NSUTF8StringEncoding];
        
        int fromUserID = [array[0] intValue];
        int toUserID = [array[1] intValue];
        [req setFromUserId:fromUserID];
        [req setToSessionId:toUserID];
        [req setMsgId:0];
        [req setCreateTime:0];
        [req setMsgType:msgType];
        [req setMsgData:messageText];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:CMD_MSG_DATA
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}

@end
