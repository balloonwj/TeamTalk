//
//  DDUnreadMessageAPI.m
//  Duoduo
//
//  Created by scorpio on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "DDUnreadMessageAPI.h"
#import "IMMessage.pb.h"
#import "MTSessionEntity.h"

@implementation DDUnreadMessageAPI
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
    return CMD_MSG_UNREAD_CNT_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_MSG_UNREAD_CNT_RES;
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
        IMUnreadMsgCntRsp *allGroupRsp = [IMUnreadMsgCntRsp parseFromData:data];
        NSArray* unreadInfoList = allGroupRsp.unreadinfoList;
        __block NSMutableDictionary* unreadMessageDic = [[NSMutableDictionary alloc] init];
        [unreadInfoList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UnreadInfo* unreadInfo = (UnreadInfo*)obj;
            SessionType sessionType = unreadInfo.sessionType;
            NSUInteger unreadCnt = unreadInfo.unreadCnt;
            NSString* originID = [NSString stringWithFormat:@"%i",unreadInfo.sessionId];
            NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:sessionType];;
            [unreadMessageDic setObject:@(unreadCnt) forKey:sessionID];
        }];
        return unreadMessageDic;
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
        IMUnreadMsgCntReqBuilder *req = [IMUnreadMsgCntReq builder];
        
        [req setUserId:[object intValue]];
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:CMD_MSG_UNREAD_CNT_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[req build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
