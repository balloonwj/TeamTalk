//
//  DDLoginManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDHttpServer,DDMsgServer,DDTcpServer,DDLoginServer,MTUserEntity;
@interface DDLoginManager : NSObject
{
    DDHttpServer* _httpServer;
    DDMsgServer* _msgServer;
    DDTcpServer* _tcpServer;
    DDLoginServer* _loginServer;
}

@property (nonatomic,readonly)NSString* token;
@property (nonatomic, copy) NSString *accessUrl;

+ (instancetype)instance;

/**
 *  登录接口，整个登录流程
 *
 *  @param name     用户名
 *  @param password 密码
 */
- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(MTUserEntity* user))success failure:(void(^)(NSString* error))failure;

/**
 *  断线重连，重连失败会重走整个登录流程
 *
 *  @param success 重连完成
 *  @param failure 重连失败
 */
- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure;

/**
 *  离线
 */
- (void)offlineCompletion:(void(^)())completion;
@end
