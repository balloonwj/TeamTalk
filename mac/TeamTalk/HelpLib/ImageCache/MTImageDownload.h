//
//  MTImageDownload.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MTDownloadImageCompletion)(NSImage* image);
typedef void(^MTDownloadFileCompletion)(NSString* targetFilePath,NSError* error);

@interface MTImageDownload : NSObject
/**
 *  单例
 *
 *  @return 单例
 */
+ (instancetype)shareInstance;

/**
 *  下载图片
 *
 *  @param url        url
 *  @param completion 下周完成
 */
- (void)loadImageWithURL:(NSString*)url completion:(MTDownloadImageCompletion)completion;

- (void)loadFileWithURL:(NSString*)url completion:(MTDownloadFileCompletion)completion;

@end
