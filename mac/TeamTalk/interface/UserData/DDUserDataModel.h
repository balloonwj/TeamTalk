//
//  DDUserDataModel.h
//  Duoduo
//
//  Created by 独嘉 on 14-2-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTUserEntity.h"
#import "TcpProtocolHeader.h"
#import "DDHttpModule.h"
#import "DDImageUploader.h"
@class MGJMTalkClient;


@interface DDUserDataModel : NSObject
{
    
}
@property (nonatomic,retain)MTUserEntity* showUser;

- (void)loadUserInfoSuccess:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)uploadAvatar:(NSImage*)image completion:(MTUploadImageCompletion)completion;
@end
