//
//  DDImageUploader.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MTUploadImageCompletion)(NSString* url, NSError* error);

@interface DDImageUploader : NSObject

/**
 *  上传图片到服务器
 *
 *  @param image      上传的图片
 *  @param completion 完成上传
 */
- (void)uploadImage:(NSImage*)image completion:(MTUploadImageCompletion)completion;

/**
 *  上传位于|filePath|路径上的图片
 *
 *  @param filePath   待上传图片的路径
 *  @param completion 上传完成
 */
- (void)uploadImageAtFilePath:(NSString*)filePath completion:(MTUploadImageCompletion)completion;
@end
