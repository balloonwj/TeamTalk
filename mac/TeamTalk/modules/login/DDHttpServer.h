//
//  DDHttpServer.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDHttpServer : NSObject

/**
 *  登录Http服务器
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param success  登录成功回调的block
 *  @param failure  登录失败回调的block
 */
- (void)loginWithUserName:(NSString*)userName
                 password:(NSString*)password
                  success:(void(^)(id respone))success
                  failure:(void(^)(id error))failure;

- (void) getMsgServerIp: (void(^)(NSDictionary* dic))block;
@end
