//
//  DDSendMessageAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDHistoryMessageAPI.h"
#import "IMMessage.pb.h"
#import "MTMessageEntity.h"
@implementation DDHistoryMessageAPI
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
    return CID_MSG_LIST_REQUEST;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CID_MSG_LIST_RESPONSE;
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
        IMGetMsgListRsp *allMessageRsp = [IMGetMsgListRsp parseFromData:data];
        NSArray* messages = allMessageRsp.msgList;
        NSString* sessionID = [NSString stringWithFormat:@"%i",allMessageRsp.sessionId];
        NSMutableArray* newMessages = [[NSMutableArray alloc] init];
        for (NSInteger index = 0; index < [messages count]; index ++)
        {
            MsgInfo* msgInfo = messages[index];
            MTMessageEntity* messageEntity = [[MTMessageEntity alloc] initWithMesssageInfo:msgInfo withSessionID:sessionID];
            [newMessages addObject:messageEntity];
        }
        return newMessages;
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
        IMGetMsgListReqBuilder *req = [IMGetMsgListReq builder];
        
        [req setUserId:[object[0] intValue]];
        [req setSessionType:[object[1] intValue]];
        [req setSessionId:[object[2] intValue]];
        [req setMsgIdBegin:[object[3] intValue]];
        [req setMsgCnt:[object[4] intValue]];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:CID_MSG_LIST_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
