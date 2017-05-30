//
//  DDReceiveOnlineUserListAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDOnlineUserListAPI.h"
#import "IMBuddy.pb.h"


@implementation DDOnlineUserListAPI

- (int)requestServiceID
{
    return ServiceIDSidBuddyList;
}

- (int)responseServiceID
{
    return ServiceIDSidBuddyList;
}

- (int)requestCommendID
{
    return BuddyListCmdIDCidBuddyListUsersStatusRequest;
}

- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListUsersStatusResponse;
}

- (int)requestTimeOutTimeInterval
{
    return 10;
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
        IMUsersStatRsp *allUserStateRsp = [IMUsersStatRsp parseFromData:data];
        
        NSArray *usersStatList = allUserStateRsp.userStatList;
        
        return usersStatList;
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
    Package package = (id)^(id object,uint32_t seqNo)
    {
        IMUsersStatReqBuilder *reqBuilder =[IMUsersStatReq builder];
        
        [reqBuilder setUserId:0];
        [reqBuilder setUserIdListArray:(NSArray *)object];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}

@end
