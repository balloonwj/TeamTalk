//
//  DDSuperAPI.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-24.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAPIScheduleProtocol.h"
#import "DDTcpClientManager.h"
#import "DataOutputStream.h"
#import "DataInputStream.h"
#import "DataOutputStream+Addition.h"
#import "TcpProtocolHeader.h"
typedef void(^RequestCompletion)(id response,NSError* error);


static uint32_t strLen(NSString *aString)
{
    return (uint32_t)[[aString dataUsingEncoding:NSUTF8StringEncoding] length];
}

/**
 *  这是一个超级类，不能被直接使用
 */
@interface DDSuperAPI : NSObject
@property (nonatomic,copy)RequestCompletion completion;
@property (nonatomic,readonly)uint16_t seqNo;

- (void)requestWithObject:(id)object Completion:(RequestCompletion)completion;

@end
