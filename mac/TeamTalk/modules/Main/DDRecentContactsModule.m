//
//  DDRecentContactsModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRecentContactsModule.h"
#import "DDRecentConactsAPI.h"
#import "MTGroupModule.h"
#import "MTUserEntity.h"
#import "MTGroupEntity.h"
#import "MTSessionEntity.h"
#import "MTSessionModule.h"
#import "DDGetOfflineFileAPI.h"
#import "SpellLibrary.h"
#import "DDPathHelp.h"
#import "DDSetting.h"
#import "DDGroupInfoAPI.h"
#import "MTDatabaseUtil.h"
#import "MTUserModule.h"
#define RECETNT_CONTACTS_PLIST_FILE                 @"RecentPerson.plist"

typedef void(^RecentUsersCompletion)();
typedef void(^RecentGroupCompletion)();
typedef void(^LoadTopSessionCompletion)();
typedef void(^LoadLocalRecentCOntactsCompletion)();

@interface DDRecentContactsModule(PrivateAPI)


- (NSString*)p_plistPath;

@end

@implementation DDRecentContactsModule
{
    BOOL _finishedLoadRecentUsers;
    BOOL _finishedLoadRecentGroups;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _finishedLoadRecentGroups = NO;
        _finishedLoadRecentUsers = NO;
    }
    return self;
}

- (void)loadRecentContacts:(LoadRecentContactsCompletion)completion
{
    //TT_3.0
}

- (void)saveRecentContacts
{
    NSMutableArray* recentContacts = [[NSMutableArray alloc] init];
    
    BOOL result = [[MTDatabaseUtil instance] updateSessions:recentContacts];
    if (result)
    {
        DDLog(@"保存最近会话成功");
    }
    else
    {
        log4Error(@"保存最近会话失败");
    }
}

#pragma mark PrivateAPI

- (NSString*)p_plistPath
{
//    NSString* myName = [[userListModule myUser] userId];
    NSString* myName = @"11";
    
    NSString* directorPath = [[DDPathHelp applicationSupportDirectory] stringByAppendingPathComponent:myName];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDirector = NO;
    BOOL isExiting = [fileManager fileExistsAtPath:directorPath isDirectory:&isDirector];
    
    if (!(isExiting && isDirector))
    {
        BOOL createDirection = [fileManager createDirectoryAtPath:directorPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        if (!createDirection)
        {
            DDLog(@"create director");
        }
    }
    
    
    NSString *plistPath = [directorPath stringByAppendingPathComponent:RECETNT_CONTACTS_PLIST_FILE];
    return plistPath;
}
@end
