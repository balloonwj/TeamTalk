//
//  DDIntranetModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetModule.h"
#import "NSString+DDStringAdditions.h"
#import "MD5.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import <AFNetworking/AFNetworking.h>
@interface DDIntranetModule(PrivateAPI)

- (void)p_sortIntranet;

@end
@implementation DDIntranetModule
- (id)init
{
    self = [super init];
    if (self)
    {
        _intranets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadIntranetsCompletion:(DDIntranetLoadCompletion)completion
{
    AFHTTPRequestOperationManager* httpManager = [AFHTTPRequestOperationManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [httpManager GET:[DDClientState shareInstance].discoverURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* items = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary* info = (NSDictionary*)obj;
            DDIntranetEntity* intranetEntity = [[DDIntranetEntity alloc] initWithInfo:info];
            [_intranets addObject:intranetEntity];
        }];
        [self p_sortIntranet];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLog(@"failed");
    }];
}

#pragma mark private API
- (void)p_sortIntranet
{
    [_intranets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DDIntranetEntity* intranet1 = (DDIntranetEntity*)obj1;
        DDIntranetEntity* intranet2 = (DDIntranetEntity*)obj2;
        if (intranet1.priority > intranet2.priority)
        {
            return NSOrderedAscending;
        }
        else if(intranet1.priority < intranet2.priority)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

@end
