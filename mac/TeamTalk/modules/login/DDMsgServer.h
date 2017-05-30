//
//  DDMsgServer.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDMsgServer : NSObject

-(void)loginWithUsername:(NSString*)username
                Password:(NSString*)password
                success:(void(^)(id object))success
                failure:(void(^)(id object))failure;
@end
