//
//  MTPreviewItem.m
//  Duoduo
//
//  Created by 独嘉 on 15/2/2.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTPreviewItem.h"

@implementation MTPreviewItem
{
    NSString* _urlString;
    NSString* _title;
    NSURL* _url;
}
- (instancetype)initWithItemURL:(id)url title:(NSString*)title
{
    self = [super init];
    if (self)
    {
        if ([url isKindOfClass:[NSURL class]])
        {
            _url = [url copy];
        }
        else
        {
            _urlString = [url copy];
        }
        _title = [title copy];
    }
    return self;
}

#pragma mark -
#pragma mark - QLPreviewItem
- (NSURL*)previewItemURL
{
    if (_url)
    {
        return _url;
    }
    else
    {
        if ([_urlString hasPrefix:@"http://"])
        {
            return [NSURL URLWithString:_urlString];
        }
        else
        {
            NSURL* filePathUrl = [NSURL fileURLWithPath:_urlString];
            return filePathUrl;
        }
    }
}

- (NSString*)previewItemTitle
{
    return _title;
}



@end
