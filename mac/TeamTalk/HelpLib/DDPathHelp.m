//
//  DDPathHelp.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-16.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDPathHelp.h"


static NSString* const loginArchivedName = @"LoginArchived";

#define PORTABLE_ADIUM_KEY					@"Preference Folder Location"


@implementation DDPathHelp
+ (NSString*)applicationSupportDirectory
{
    static NSString *preferencesFolderPath = nil;
	
    //Determine the preferences path if neccessary
	if (!preferencesFolderPath) {
		preferencesFolderPath = [[[[NSBundle mainBundle] infoDictionary] objectForKey:PORTABLE_ADIUM_KEY] stringByExpandingTildeInPath];
		if (!preferencesFolderPath)
			preferencesFolderPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:@"TeamTalk"];
	}
	
	return preferencesFolderPath;
}

+ (NSString*)loginArchivedDataPath
{
    NSString* applicationSupportDirectory = [DDPathHelp applicationSupportDirectory];
    NSString* loginArchivedPath = [applicationSupportDirectory stringByAppendingPathComponent:loginArchivedName];
    return loginArchivedPath;
}

+ (NSString*)downLoadPath
{
    NSString* downLoadPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
    return downLoadPath;
}

+ (NSString*)imageCachePath
{
    NSString* applicationSupportDirectory = [DDPathHelp applicationSupportDirectory];
    NSString* imageCache = [applicationSupportDirectory stringByAppendingPathComponent:@"ImageCache"];
    BOOL directory;
    BOOL exit = [[NSFileManager defaultManager] fileExistsAtPath:imageCache isDirectory:&directory];
    if (!exit)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imageCache;
}

+ (NSString*)voiceCachePath
{
    NSString* applicationSupportDirectory = [DDPathHelp applicationSupportDirectory];
    
    NSString* userID = [DDClientState shareInstance].userID;
    
    NSString* directorPath = [applicationSupportDirectory stringByAppendingPathComponent:userID];
    
    NSString* voicePath = [directorPath stringByAppendingPathComponent:@"VoiceCache"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //判断用户的db是否存在，若不存在则创建相应的DB目录
    BOOL isDirector = NO;
    BOOL isExiting = [fileManager fileExistsAtPath:voicePath isDirectory:&isDirector];
    
    if (!(isExiting && isDirector))
    {
        BOOL createDirection = [fileManager createDirectoryAtPath:voicePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        if (!createDirection)
        {
            log4Error(@"语音缓存文件创建失败~");
        }
    }
    return voicePath;
}

@end
