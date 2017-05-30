//
//  DDUnrequestSuperAPI.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataInputStream.h"
#import "DDAPIUnrequestScheduleProtocol.h"
typedef void(^ReceiveData)(id object,NSError* error);

@interface DDUnrequestSuperAPI : NSObject
@property (nonatomic,copy)ReceiveData receivedData;
- (BOOL)registerAPIInAPIScheduleReceiveData:(ReceiveData)received;
@end
