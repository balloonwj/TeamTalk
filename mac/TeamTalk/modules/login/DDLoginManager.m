//
//  DDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginManager.h"
#import "DDHttpServer.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
#import "DDLoginServer.h"
#import "LoginEntity.h"
#import "MTUserEntity.h"
#import "DDReceiveKickAPI.h"
#import "MTUserModule.h"
#import "MTSysConfigModule.h"

@interface DDLoginManager(privateAPI)

- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure;
- (void)p_loginSuccess:(MTUserEntity*)user;
- (void)p_loginFailure;
@end

@implementation DDLoginManager
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _serverIp;
    NSUInteger _port;
}
+ (instancetype)instance
{
    static DDLoginManager *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[DDLoginManager alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _loginServer = [[DDLoginServer alloc] init];
    }
    return self;
}

#pragma mark Public API
- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(MTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure
{
    __weak DDLoginManager* weakSelf = self;
    
    
    [DDClientState shareInstance].userState = DDUserLogining;
    
    [_httpServer getMsgServerIp:^(NSDictionary *dic) {
        NSInteger code  = [[dic objectForKey:@"code"] integerValue];
        if (code == 0) {
            _serverIp = [dic objectForKey:@"priorIP"];
            _port =  [[dic objectForKey:@"port"] integerValue];
            [DDClientState shareInstance].msfsURL = [dic objectForKey:@"msfsPrior"];
            [DDClientState shareInstance].discoverURL = dic[@"discovery"];
            _lastLoginUserName = [name copy];
            _lastLoginPassword = [password copy];
            log4Info(@"开始链接服务器")
            [_tcpServer loginTcpServerIP:_serverIp port:_port Success:^{
                log4Info(@"连接服务器成功,开始验证用户信息");
                [_msgServer loginWithUsername:name Password:password success:^(id object) {
                    MTUserEntity* user = object[@"user"];
                    NSUInteger serverTime = [object[@"serverTime"] integerValue];
                    DDLog(@"-------------------------------------------> local:%f \n remote:%lu",[[NSDate date] timeIntervalSince1970],(unsigned long)serverTime);
                    [weakSelf p_loginSuccess:user];
                    _lastLoginUser = [user ID];
                    log4Info(@"验证用户信息通过");
                    success(user);
                } failure:^(id object) {
                    DDLog(@"login#登录验证失败");
                    log4Error(@"验证用户信息失败");
                    failure(@"登录验证失败");
                }];
                
            } failure:^{
                log4Error(@"连接服务器失败");
                failure(@"连接服务器失败");
            }];
        }
        else
        {
            failure(@"获取服务器IP出错");
        }
    }];
}

- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure
{
    if ([DDClientState shareInstance].userState != DDUserLogining)
    {
        DDLog(@"开始断线重连");
        log4Info(@"开始断线重连");
         __weak DDLoginManager* weakSelf = self;
        [_tcpServer loginTcpServerIP:_serverIp port:_port Success:^{
            [_msgServer loginWithUsername:_lastLoginUserName Password:_lastLoginPassword success:^(id object) {
                MTUserEntity* user = object[@"user"];
                [weakSelf p_loginSuccess:user];
                _lastLoginUser = [user ID];
                success(user);
            } failure:^(id object) {
                DDLog(@"login#登录验证失败");
                
                failure(@"登录验证失败");
            }];
            
        } failure:^{
            
        }];
    }

}

- (void)offlineCompletion:(void(^)())completion
{
    [_tcpServer disconnect];
    completion();
}


- (void)p_loginSuccess:(MTUserEntity*)user
{
    [DDClientState shareInstance].userID = [user.ID copy];
    [[MTSysConfigModule shareInstance] getSysConfigFromLocal];
    [DDClientState shareInstance].userState = DDUserOnline;
    
    [[MTUserModule shareInstance] addMaintainOriginEntities:@[user]];
}

- (void)p_loginFailure
{
    [DDClientState shareInstance].userState = DDUserOffLine;
}

@end
