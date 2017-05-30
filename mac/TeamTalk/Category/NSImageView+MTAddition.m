//
//  NSImageView+MTAddition.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "NSImageView+MTAddition.h"
#import "MTImageCache.h"
#import "MTImageDownload.h"
@implementation NSImageView (MTAddition)
- (void)setImageWithURL:(NSString*)url placeholderImage:(NSString*)placeholder
{
    static int index = 0;
    index ++;
    NSImage* cacheImage = [[MTImageCache shareInstance] imageFromCacheWithKey:url];
    if (cacheImage)
    {
        [self setImage:cacheImage];
    }
    else
    {
        NSImage* placeholderImage = [NSImage imageNamed:placeholder];
        [self setImage:placeholderImage];
        //开始下载图片
        if ([url length] > 0)
        {
            [[MTImageDownload shareInstance] loadImageWithURL:url completion:^(NSImage *image) {
                [[MTImageCache shareInstance] cacheImage:image forKey:url toMemory:YES];
                [self setImage:image];
            }];
        }
    }
}
@end
