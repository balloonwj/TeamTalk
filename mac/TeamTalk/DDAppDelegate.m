//
//  DDAppDelegate.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDAppDelegate.h"
#import "MTUserEntity.h"
#import "MTSessionModule.h"
#import "DDMainModule.h"
#import "DDMainWindowController.h"
#import "DDMainWindowController.h"
#import "MTMessageModule.h"
#import "DDApplicationUpdate.h"
#import "DDLoginWindowController.h"
#import "DDClientStateMaintenanceManager.h"
#import "DDTcpClientManager.h"
#import "PFMoveApplication.h"
#import "DDServiceAccountModule.h"
#import "StateMaintenanceManager.h"
#import "MTUserModule.h"
#import "MTGroupModule.h"
#import "MTSessionModule.h"
#import <Quartz/Quartz.h>
#import "MTDepartmentManager.h"
//Portable Duoduo prefs key

#define PORTABLE_ADIUM_KEY					@"Preference Folder Location"
#define ALWAYS_RUN_SETUP_WIZARD FALSE

@implementation DDAppDelegate
{
}
#pragma mark Core Controllers
-(id)init{
    self =[super self];
    if (self) {
        NSString *logPath = [[self applicationSupportDirectory] stringByAppendingPathComponent:@"duoduo_log.txt"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self applicationSupportDirectory]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[self applicationSupportDirectory]
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        //设置默认记录级别
        [[L4Logger rootLogger] setLevel:[L4Level all]];
        //定义输出目标与日志模板
        [[L4Logger rootLogger] addAppender: [[L4RollingFileAppender alloc] initWithLayout:[L4Layout simpleLayout] fileName:logPath]];
        //自初始化并定义日志实例
        L4Logger *theLogger = [L4Logger loggerForClass:[L4FunctionLogger class]];
        [theLogger setLevel:[L4Level all]];
        
        setSharedDuoduo(self);

    }
    return self;
}



//duoduo is almost done lauching,init
- (void)applicationWillFinishLaunching:(NSNotification *)notification{

    PFMoveToApplicationsFolderIfNecessary();
    
//    check for a recent crach log
    
//    Ignore SIGPIPE, which is a harmless error signal
//    sent when write() or similar function calls fail due to a broken pipe in the network connection
    signal(SIGPIPE, SIG_IGN);
    
    //cocoa程序获取url scheme传入参数
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    log4CInfo(@"applicationWillFinishLaunching");
}


//duoduo has finished lauching.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[DDApplicationUpdate instance] startAutoCheckUpdateAtOnce];
    //应用程序初始化相关
    [StateMaintenanceManager instance];
    [DDClientStateMaintenanceManager shareInstance];
    [DDServiceAccountModule shareInstance];
    
    [MTSessionModule shareInstance];
    [MTGroupModule shareInsatnce];
    [MTUserModule shareInstance];
    [MTDepartmentManager shareInstance];
    [StateMaintenanceManager instance];
    
    [MTMessageModule shareInstance];
    log4CInfo(@"applicationDidFinishLaunching");
    if(nil == _loginWindowController)
    {
        _loginWindowController = [[DDLoginWindowController alloc] initWithWindowNibName:@"LoginSelect"];
    }
    [_loginWindowController showWindow:nil];
    [_loginWindowController.window makeKeyAndOrderFront:nil];
    self.showWindow = _loginWindowController.window;
}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    DDLog(@" --");
}

/*!
 * @brief Returns the location of Duoduo's preference folder
 *
 * This may be specified in our bundle's info dictionary keyed as PORTABLE_ADIUM_KEY
 * or, by default, be within the system's 'application support' directory.
 */
- (NSString *)applicationSupportDirectory
{
	//Path to the preferences folder
	static NSString *_preferencesFolderPath = nil;
	
    //Determine the preferences path if neccessary
	if (!_preferencesFolderPath) {
		_preferencesFolderPath = [[[[NSBundle mainBundle] infoDictionary] objectForKey:PORTABLE_ADIUM_KEY] stringByExpandingTildeInPath];
		if (!_preferencesFolderPath)
			_preferencesFolderPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:@"TeamTalk"];
	}
	
	return _preferencesFolderPath;
}


- (void)applicationWillTerminate:(NSNotification *)notification{
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.showWindow makeKeyAndOrderFront:nil];
    DDLog(@"applicationShouldHandleReopen");
    return YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [[QLPreviewPanel sharedPreviewPanel] close];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
//    if (_showMainWindow)
//    {
//        DDMessageModule* messageModule = getDDMessageModule();
//        DDSessionModule* sessionModule = getDDSessionModule();
//        NSString* chattingSessionID = [sessionModule chatingSessionID];
//        if ([messageModule countMessageBySessionId:chattingSessionID] > 0)
//        {
//            [[DDMainWindowController instance] openChatViewByUserId:chattingSessionID];
//        }
//    }
}

- (void)showMainWindowController
{
    [_loginWindowController close];
    [[DDMainWindowController instance].window makeKeyAndOrderFront:nil];
    self.showWindow = [DDMainWindowController instance].window;
}

- (void)p_clearOldCachePath
{
    NSString *preferencesFolderPath = nil;
    if (!preferencesFolderPath) {
        preferencesFolderPath = [[[[NSBundle mainBundle] infoDictionary] objectForKey:PORTABLE_ADIUM_KEY] stringByExpandingTildeInPath];
        if (!preferencesFolderPath)
            preferencesFolderPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:@"Duoduo 1.0"];
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    
    if ([fileManager fileExistsAtPath:preferencesFolderPath])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError* error = nil;
            [fileManager removeItemAtPath:preferencesFolderPath error:&error];
        });
    }
}

@end


