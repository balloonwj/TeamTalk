//
//  DDChangableAttactment.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChangableAttactment.h"
#import "EGOImageLoader.h"

@implementation DDChangableAttactment

- (id)initWithRealURL:(NSString*)sender
{
    self = [super init];
    if (self)
    {
        if (sender)
        {
            _realURL = [sender copy];
        }
    }
    return self;
}


#pragma mark - QLPreviewItem
- (NSURL*)previewItemURL
{
    if (_realURL)
    {
        EGOImageLoader* loder = [EGOImageLoader sharedImageLoader];
        NSURL* realURL = [NSURL URLWithString:_realURL];
        NSString* cachePath = [loder cachePathForURL:realURL];
        NSURL* fileURL = [NSURL fileURLWithPath:cachePath];
        return fileURL;
    }
    else
    {
        NSURL* url = [[self fileWrapper] symbolicLinkDestinationURL];
        return url;
    }
}
@end
