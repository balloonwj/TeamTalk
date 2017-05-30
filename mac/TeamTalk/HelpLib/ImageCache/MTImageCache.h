//
//  MTImageCache.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  图片缓存类,TODO:Cache有效期
 */
@interface MTImageCache : NSObject

/**
 *  单例
 *
 *  @return 图片缓存类
 */
+ (instancetype)shareInstance;

/**
 *  缓存图片到内存或者磁盘
 *
 *  @param image 图片
 *  @param key   作为图片的唯一标识，一般为url
 *  @param save  是否保存到内存，默认都保存在磁盘中
 */
- (void)cacheImage:(NSImage*)image forKey:(NSString*)key toMemory:(BOOL)save;

/**
 *  将|filePath|路径下的图片作为|key|的缓存
 *
 *  @param imagePath 源文件路径
 *  @param key       缓存唯一标识符
 */
- (void)cacheImageFilePath:(NSString*)imagePath forKey:(NSString*)key;

/**
 *  根据图片的唯一标识去取图片
 *
 *  @param key 图片的唯一表示
 *
 *  @return 图片
 */
- (NSImage*)imageFromCacheWithKey:(NSString*)key;


/**
 *  根据key获取缓存图片的路径
 *
 *  @param key key
 *
 *  @return 缓存图片的路径
 */
- (NSString*)filePathWithKey:(NSString*)key;


@end
