//
//  DDUserDataModel.m
//  Duoduo
//
//  Created by 独嘉 on 14-2-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserDataModel.h"
#import "DDUserDetailInfoAPI.h"
@implementation DDUserDataModel
{
    DDImageUploader* _imageUpload;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _imageUpload = [[DDImageUploader alloc] init];
    }
    return self;
}

- (void)loadUserInfoSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    DDUserDetailInfoAPI* detailInfoAPI = [[DDUserDetailInfoAPI alloc] init];
    [detailInfoAPI requestWithObject:@[_showUser.ID] Completion:^(id response, NSError *error) {
        if ([response count] > 0)
        {
            NSDictionary* userInfo = response[0];
            success(userInfo);
        }
        else
        {
            failure(nil);
        }
    }];
}

- (void)uploadAvatar:(NSImage*)image completion:(MTUploadImageCompletion)completion
{
    [_imageUpload uploadImage:image completion:completion];
}

@end
