//
//  CrashReportManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-13.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "CrashReportManager.h"
#import <CrashReporter/CrashReporter.h>
#import <IOSurface/IOSurface.h>
#import "AFHTTPRequestOperation.h"
NSString* GetHardwareUUID()
{
    NSString *ret = nil;
    io_service_t platformExpert ;
    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")) ;
    
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString ;
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR("IOPlatformUUID"), kCFAllocatorDefault, 0) ;
        if (serialNumberAsCFString) {
            ret = [(__bridge NSString *)(CFStringRef)serialNumberAsCFString copy];
            CFRelease(serialNumberAsCFString); serialNumberAsCFString = NULL;
        }
        IOObjectRelease(platformExpert); platformExpert = 0;
    }
    
    return ret;
}

@implementation CrashReportManager
+ (CrashReportManager*)instance
{
    static CrashReportManager* g_crashReportManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_crashReportManager = [[CrashReportManager alloc] init];
    });
    return g_crashReportManager;
}

- (void)checkAndSendCrashReport
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport])
    {
        
        [self handleCrashReportSuccess:^{
            [crashReporter purgePendingCrashReport];

        } failure:^{
            [crashReporter purgePendingCrashReport];
        }];
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error])
    {
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    }
}

- (void)handleCrashReportSuccess:(void(^)())success failure:(void(^)())failure
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil)
    {
        NSLog(@"Could not load crash report: %@", error);
        [crashReporter purgePendingCrashReport];
        return;
    }
    [self uploadTheCrashReport:crashData success:^{
        success();
    } failure:^{
        failure();
    }];
    return;
}

- (NSString *)applicationSupportDirectory
{
	//Path to the preferences folder
	static NSString *_preferencesFolderPath = nil;
	
    //Determine the preferences path if neccessary
	if (!_preferencesFolderPath) {
		_preferencesFolderPath = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Preference Folder Location"] stringByExpandingTildeInPath];
		if (!_preferencesFolderPath)
			_preferencesFolderPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:@"TeamTalk"];
	}
	
	return _preferencesFolderPath;
}

- (void)uploadTheCrashReport:(NSData*)crashReport success:(void(^)())success failure:(void(^)())failure
{
//    NSURL *url = [NSURL URLWithString:@"http://www.mogujie.com"];
//    NSString* fileName = [self crashFileName];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    NSDictionary* parameters = @{@"platform":@"Mac"};
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/mtalk/client/page/dump/" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:crashReport name:@"dumpFile" fileName:fileName mimeType:@"application/octet-stream"];
//    }];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         DDLog(@"success with response string %@", operation);
//         NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//         NSDictionary* status = response[@"status"];
//         NSNumber* code = status[@"code"];
//         if (![code isEqualToNumber:@1001])
//         {
//             DDLog(@"发送奔溃报告失败");
//             failure();
//         }
//         else
//         {
//             success();
//         }
//     }
//                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         DDLog(@"error: %@", error.localizedDescription);
//         failure();
//     }];
//    [operation start];
}

- (NSString*)crashFileName
{
    NSString* uuid = GetHardwareUUID();
    NSDate* now = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString* dateString = [dateFormatter stringFromDate:now];
    NSString* fileName = [NSString stringWithFormat:@"%@-%@.crash",uuid,dateString];
    return fileName;
}

@end
