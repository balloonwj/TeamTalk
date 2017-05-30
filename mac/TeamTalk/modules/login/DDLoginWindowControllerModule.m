//
//  DDLoginWindowControllerModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-14.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginWindowControllerModule.h"
#import "DDLoginManager.h"
#import "CrashReportManager.h"
#import "MTUserEntity.h"
#import "DDTcpClientManager.h"
#import "DDClientState.h"
#import "DDPathHelp.h"
#import "DDUserPreferences.h"

#import "DDRecentConactsAPI.h"
#import "SpellLibrary.h"

#import "DDAllUserAPI.h"
#import "MTMessageModule.h"
#import "StateMaintenanceManager.h"
#import "DDGetOfflineFileAPI.h"
#import "MTUserModule.h"

typedef void(^LoadAllUsersCompletion)();

static NSString* const nameKey = @"Name";
static NSString* const passwordKey = @"Password";
static NSString* const avatarKey = @"Avatar";
static NSString* const avatarMapKey = @"AvatarMap";

@interface DDLoginWindowControllerModule(privateAPI)

- (void)p_loginSuccessWithUser:(MTUserEntity*)user;
- (void)p_archivedLoginData;
- (void)p_loadAllUsersCompletion:(LoadAllUsersCompletion)completion;

@end

@implementation DDLoginWindowControllerModule

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* archivePath = [DDPathHelp loginArchivedDataPath];
        NSData* data = [[NSData alloc] initWithContentsOfFile:archivePath];
        DDLoginWindowControllerModule* module = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (module)
        {
            self = module;
        }
        if (!_avatarMap)
        {
            _avatarMap = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)loginWithUserName:(NSString*)userName password:(NSString*)password success:(void(^)())success failure:(void(^)(NSString* info))failure
{
    __weak DDLoginWindowControllerModule* weakSelf = self;
    [[DDLoginManager instance] loginWithUsername:userName password:password success:^(MTUserEntity *user) {
        [weakSelf p_loginSuccessWithUser:user];
        _lastuserName = [userName copy];
        _lastpassword = [password copy];
        _lastavatar = [user.avatar copy];
        [_avatarMap setValue:_lastavatar forKey:_lastuserName];
        [weakSelf p_archivedLoginData];
        [NotificationHelp postNotification:notificationUserLoginSuccess userInfo:nil object:user];
        success();
    } failure:^(NSString *error) {
        failure(error);
    }];
}

- (NSString*)getAvatarForUserName:(NSString*)name
{
    NSString* avatar = _avatarMap[name];
    return avatar;
}

#pragma mark - NSCoding
//nscoding协议的方法
-(void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:_lastavatar forKey:avatarKey];
    [coder encodeObject:_lastuserName forKey:nameKey];
    [coder encodeObject:_lastpassword forKey:passwordKey];
    [coder encodeObject:_avatarMap forKey:avatarMapKey];
}

-(id) initWithCoder:(NSCoder *)  decoder{
    if(self =[super init]){
        _lastuserName = [decoder decodeObjectForKey:nameKey];
        _lastpassword = [decoder decodeObjectForKey:passwordKey];
        _lastavatar=[decoder decodeObjectForKey:avatarKey];
        _avatarMap = [decoder decodeObjectForKey:avatarMapKey];
    }
    return (self);
}

#pragma mark - privateAPI
- (void)p_loginSuccessWithUser:(MTUserEntity*)user
{
    //注册快捷键
    [[DDUserPreferences defaultInstance] resetShortcutRegistration];

    //登录完成，检测发送crash report
    [[CrashReportManager instance] checkAndSendCrashReport];
}

- (void)p_archivedLoginData
{
    NSString* loginDataPath = [DDPathHelp loginArchivedDataPath];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    BOOL writeSuccess = [data writeToFile:loginDataPath atomically:YES];
    if (!writeSuccess)
    {
        log4Error(@"登录数据打包失败");
    }
}



@end
