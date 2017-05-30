
//
//  DDHttpServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDHttpServer.h"
#import "DDHttpModule.h"
#import "AFNetworking.h"
#import "DDLoginManager.h"
#import "NSData+NSJSONSerialization.h"

@implementation DDHttpServer
- (void)loginWithUserName:(NSString*)userName
                 password:(NSString*)password
                  success:(void(^)(id respone))success
                  failure:(void(^)(id error))failure
{
    DDHttpModule* module = getDDHttpModule();
    NSMutableDictionary* dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:userName forKey:@"user_email"];
    [dictParams setObject:password forKey:@"user_pass"];
    [dictParams setObject:@"ooxx" forKey:@"macim"];
    [dictParams setObject:@"1.0" forKey:@"imclient"];
    [dictParams setObject:@"1" forKey:@"remember"];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [module httpPostWithUri:@"user/zlogin/" params:dictParams
                    success:^(NSDictionary *result)
     {
         success(result);
     }
                    failure:^(StatusEntity *error)
     
     {
         failure(error.msg);
     }];

}

- (void) getMsgServerIp: (void(^)(NSDictionary *dic))block{
    
    NSString *accessUrlString = @"http://access.tt.mogujie.org/msg_server";
    if ([DDLoginManager instance].accessUrl != nil) {
        accessUrlString = [DDLoginManager instance].accessUrl;
    }
    
    log4Info(@"获取服务器IP");
    AFHTTPRequestOperationManager* httpManager = [AFHTTPRequestOperationManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [httpManager GET:accessUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        block(responseDictionary);
        log4Info(@"获取服务器IP成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLog(@"failed");
        log4Error(@"获取服务器IP失败");
        block(@{@"code":@(1001)});
    }];
}
@end
