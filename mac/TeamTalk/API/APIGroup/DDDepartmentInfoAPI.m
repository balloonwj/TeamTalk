//
//  DDDepartmentInfoAPI.m
//  Duoduo
//
//  Created by zuoye on 15/3/17.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "DDDepartmentInfoAPI.h"
#import "IMBuddy.pb.h"
#import "MTDepartmentEntity.h"
@implementation DDDepartmentInfoAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 20;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return MODULE_ID_SESSION;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_SESSION;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_FRI_LIST_DEPARTMENT_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_LIST_DEPARTMENT_RES;
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
        IMDepartmentRsp *departRsp = [IMDepartmentRsp parseFromData:data];
        NSInteger lastUpdateTime = departRsp.latestUpdateTime;
        NSArray* departments = departRsp.deptList;
        
        NSMutableArray* theDepartments = [[NSMutableArray alloc] init];
        for (DepartInfo * departInfo in departments)
        {
            MTDepartmentEntity* departmentEntity = [[MTDepartmentEntity alloc] initWithDepartmentInfo:departInfo];
            [theDepartments addObject:departmentEntity];
        }
        
        NSDictionary* response = @{@"lastUpdateTime":@(lastUpdateTime),@"departments":theDepartments};
        
        return response;
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
        IMDepartmentReqBuilder* requestBuilder = [IMDepartmentReq builder];
        
        NSArray* array = (NSArray*)object;
        
        UInt32 lastestUpdateTime = [array[0] intValue];
        
        UInt32 userID = [[DDClientState shareInstance].userID intValue];
        [requestBuilder setUserId:userID];
        
        [requestBuilder setLatestUpdateTime:lastestUpdateTime];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION
                                    cId:CMD_FRI_LIST_DEPARTMENT_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[requestBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
