//
//  MTImageCache.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTImageCache.h"
#import "DDPathHelp.h"

#define FILE_CACHE_PLIST                @"fileCache.plist"

static NSString* hashForKey(NSString* key) {
    if (![key isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"%lu.png", [key hash]];
    }
    return nil;
}

@interface MTImageCache(PrivateAPI)

- (NSUInteger)p_costForData:(NSData*)data;

- (NSString*)p_imageCachePath;

- (void)p_initialFilePathCache;

- (void)p_saveFilePathCache;
@end

/**
 *  最多缓存300张图片，cost1 = 500k，共计300 cost，共 150M
 */
@implementation MTImageCache
{
    NSCache* _cache;
    NSMutableDictionary* _filePathCache;
}
/**
 *  单例
 *
 *  @return 图片缓存类
 */
+ (instancetype)shareInstance
{
    static MTImageCache* g_imageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_imageCache = [[MTImageCache alloc] init];
    });
    return g_imageCache;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _cache = [[NSCache alloc] init];
        [_cache setCountLimit:300];
        [_cache setTotalCostLimit:300];
        
        [self p_initialFilePathCache];
    }
    return self;
}

/**
 *  缓存图片到内存或者磁盘
 *
 *  @param image 图片
 *  @param key   作为图片的唯一标识，一般为url
 *  @param save  是否保存到内存，默认都保存在磁盘中
 */
- (void)cacheImage:(NSImage*)image forKey:(NSString*)key toMemory:(BOOL)save
{
    NSData* data = [image TIFFRepresentation];
    
    if (save)
    {
        NSUInteger cost = [self p_costForData:data];
        [_cache setObject:image forKey:key cost:cost];
    }
    //保存到磁盘
    NSString* hash = hashForKey(key);
    NSString* imagePath = [self p_imageCachePath];
    imagePath = [imagePath stringByAppendingPathComponent:hash];
    [data writeToFile:imagePath atomically:YES];
}

- (void)cacheImageFilePath:(NSString*)imagePath forKey:(NSString*)key
{
    if (imagePath && key)
    {
        [_filePathCache setObject:imagePath forKey:key];
    }
    [self p_saveFilePathCache];
}

/**
 *  根据图片的唯一标识去取图片
 *
 *  @param key 图片的唯一表示
 *
 *  @return 图片
 */
- (NSImage*)imageFromCacheWithKey:(NSString*)key
{
    //先到内存
    if ([_cache objectForKey:key])
    {
        return [_cache objectForKey:key];
    }
    //到磁盘取数据
    NSString* hash = hashForKey(key);
    NSString* imagePath = [self p_imageCachePath];
    imagePath = [imagePath stringByAppendingPathComponent:hash];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        NSData* data = [[NSData alloc] initWithContentsOfFile:imagePath];
        NSImage* image = [[NSImage alloc] initWithData:data];
        return image;
    }
    return nil;
}

- (NSString*)filePathWithKey:(NSString*)key
{
    if ([[_filePathCache allKeys] containsObject:key])
    {
        return _filePathCache[key];
    }
    
    NSString* hash = hashForKey(key);
    NSString* imagePath = [self p_imageCachePath];
    imagePath = [imagePath stringByAppendingPathComponent:hash];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        return imagePath;
    }
    return nil;
}

#pragma mark -
#pragma mark PrivateAPI
- (NSUInteger)p_costForData:(NSData*)data
{
    return [data length] / (500 * 1024) + 1;
}

- (NSString*)p_imageCachePath
{
    NSString* imageCachePath = [DDPathHelp imageCachePath];
    return imageCachePath;
}

- (void)p_initialFilePathCache
{
    NSString* plistPath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:FILE_CACHE_PLIST];
    NSDictionary* filePathCache = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    _filePathCache = [[NSMutableDictionary alloc] initWithDictionary:filePathCache];
}

- (void)p_saveFilePathCache
{
    NSString* plistPath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:FILE_CACHE_PLIST];
    [_filePathCache writeToFile:plistPath atomically:YES];
}
@end
