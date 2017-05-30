//
//  DDPathHelp.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-16.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDPathHelp : NSObject

/**
 *  程序数据目录，暂时是TeamTalk
 *
 *  @return 地址
 */
+ (NSString*)applicationSupportDirectory;


/**
 *  登录相关归档数据地址
 *
 *  @return 地址
 */
+ (NSString*)loginArchivedDataPath;

/**
 *  下载目录
 *
 *  @return 返回下载目录
 */
+ (NSString*)downLoadPath;

+ (NSString*)imageCachePath;

+ (NSString*)voiceCachePath;
@end
