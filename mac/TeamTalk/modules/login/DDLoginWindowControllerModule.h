//
//  DDLoginWindowControllerModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-14.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDLoginWindowControllerModule : NSObject<NSCoding>
@property (nonatomic,readonly)NSString* lastuserName;
@property (nonatomic,readonly)NSString* lastpassword;
@property (nonatomic,readonly)NSString* lastavatar;
@property (nonatomic,readonly)NSMutableDictionary* avatarMap;
- (void)loginWithUserName:(NSString*)userName password:(NSString*)password success:(void(^)())success failure:(void(^)(NSString* info))failure;

- (NSString*)getAvatarForUserName:(NSString*)name;
@end
