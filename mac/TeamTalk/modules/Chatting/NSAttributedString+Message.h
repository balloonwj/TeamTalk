//
//  NSAttributedString+Message.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* const realURLKey;
@interface NSAttributedString (Message)
/**
 *  根据图片路径获得富文本，如果|realURL|不为空，则会下载并自动替换
 *
 *  @param imagePath 图片路径
 *  @param realURL   真实的URL
 *  @param compress  是否压缩图片
 *
 *  @return 富文本
 */
+ (NSAttributedString *)imageAttributedString:(NSString *)imagePath realImageURL:(NSString*)realURL compressImage:(BOOL)compress;

/**
 *  根据字符串获得富文本，URL会高亮显示
 *
 *  @param text 字符串
 *
 *  @return 富文本
 */
+ (NSAttributedString *)textAttributedString:(NSString *)text;

/**
 *  替换指定索引的附件
 *
 *  @param index            指定索引
 *  @param attachementPath  替换的附件地址
 *
 *  @return 富文本
 */
- (NSAttributedString *)replactTheAttactementAtIndex:(NSUInteger)index withAttachementImagePath:(NSString*)attachementPath;

+ (NSAttributedString*)imageAttributeString:(NSString*)imagePath compressImage:(BOOL)compress;

/**
 *  获取纯文本，将图片和表情转化为对应的占位符
 *
 *  @return 纯文本
 */
- (NSString*)getString;

/**
 *  从富文本中获取文件路径，在发送消息的时候可以用
 *
 *  @return 文件路径数组
 */
- (NSArray*)filePaths;

@end
