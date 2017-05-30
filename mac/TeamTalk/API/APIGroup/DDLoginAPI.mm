//
//  DDLoginAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginAPI.h"
#import "MTUserEntity.h"
#import "IMLogin.pb.h"
#import "IMBaseDefine.pb.h"
#import "security.h"
#include <iostream>
@implementation DDLoginAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 15;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_LOGIN;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_LOGIN;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_LOGIN_REQ_USERLOGIN;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_LOGIN_RES_USERLOGIN;
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
        
        IMLoginRes *res = [IMLoginRes parseFromData:data];
        NSInteger serverTime = res.serverTime;
        NSInteger loginResult = res.resultCode;
        NSDictionary* result = nil;
        if (loginResult !=0) {
            return result;
        }else
        {
            MTUserEntity *user = [[MTUserEntity alloc] initWithUserInfo:res.userInfo];
            result = @{@"serverTime":@(serverTime),
                       @"result":@(loginResult),
                       @"user":user,
                       };
            return result;
        }
        
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
        
        NSString* name = object[0];
        NSString* password = object[1];
        NSString* clientVersion = object[2];
        
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_LOGIN
                                    cId:CMD_LOGIN_REQ_USERLOGIN
                                  seqNo:seqNo];
        IMLoginReqBuilder *login = [IMLoginReq builder];
        [login setUserName:name];
        
        std::string *strMsg =new std::string([password UTF8String]);
        char* pOut;
        uint32_t nLen=0;
        int nRet =EncryptPass(strMsg->c_str(), (uint32_t)strMsg->length(), &pOut, nLen);
        if (nRet != 0) {
            printf(" **** 加密密码错误:code= %d",nRet);
            password=@"";
        }else{
            password = [NSString stringWithUTF8String:pOut];
            Free(pOut);
        }
        delete strMsg;

        
        [login setPassword:password];
        [login setClientType:ClientTypeClientTypeMac];
        [login setClientVersion:clientVersion];
        [login setOnlineStatus:UserStatTypeUserStatusOnline];
        [dataout directWriteBytes:[login build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
