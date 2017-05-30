//
//  CrashReportManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-13.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashReportManager : NSObject
+ (CrashReportManager*)instance;

- (void)checkAndSendCrashReport;
@end
