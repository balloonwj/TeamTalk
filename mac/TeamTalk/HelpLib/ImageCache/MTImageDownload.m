//
//  MTImageDownload.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTImageDownload.h"
#import <AFNetworking.h>
#import "DDPathHelp.h"
#import "MTImageCache.h"
@interface MTImageDownload(PrivateAPI)

- (void)p_loadImageWithURL:(NSString*)url completion:(MTDownloadImageCompletion)completion;

- (void)p_addComplection:(MTDownloadImageCompletion)completio forURL:(NSString*)url;

- (void)p_executeCompletionForURL:(NSString*)url image:(NSImage*)image;

@end

@implementation MTImageDownload
{
   // AFURLSessionManager *_manager;
    NSMutableArray* _downloadingImageUrls;
    NSMutableDictionary* _completions;
}

+ (instancetype)shareInstance
{
    static MTImageDownload* g_imageDownload;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_imageDownload = [[MTImageDownload alloc] init];
    });
    return g_imageDownload;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
       // NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  //      _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//        _manager.responseSerializer = [AFImageResponseSerializer serializer];
        _downloadingImageUrls = [[NSMutableArray alloc] init];
        _completions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadImageWithURL:(NSString*)url completion:(MTDownloadImageCompletion)completion
{
    if (![[_completions allKeys] containsObject:url])
    {
        [self p_addComplection:completion forURL:url];
        [self p_loadImageWithURL:url completion:completion];
    }
    else
    {
        [self p_addComplection:completion forURL:url];
    }
}

- (void)loadFileWithURL:(NSString*)url completion:(MTDownloadFileCompletion)completion
{
    if ([_downloadingImageUrls containsObject:url] || [[MTImageCache shareInstance] filePathWithKey:url])
    {
        return;
    }
    
    if ([url length] == 0)
    {
        return;
    }
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSString* fileName = [[url componentsSeparatedByString:@"/"] lastObject];
    if (fileName) {
        NSString* targetFilePath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:fileName];
        AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *data = [[NSData alloc] initWithData:responseObject];
            [data writeToFile:targetFilePath atomically:YES];
            [[MTImageCache shareInstance] cacheImageFilePath:targetFilePath forKey:url];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            log4Error(@"file downloading error : %@", [error localizedDescription]);
        }];
        [downloadRequest start];
    }
    else
    {
        NSError* error = [NSError errorWithDomain:@"url取文件名不对" code:0 userInfo:nil];
        completion(nil,error);
    }
}

#pragma mark -
#pragma mark PrivateAPI
- (void)p_loadImageWithURL:(NSString*)url completion:(MTDownloadImageCompletion)completion
{
    if ([url length] == 0)
    {
        return;
    }
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    __weak MTImageDownload* weakSelf = self;
    AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = [[NSData alloc] initWithData:responseObject];
//        [data writeToFile:targetFilePath atomically:YES];
        NSImage *img = [[NSImage alloc]initWithData:data];
        [weakSelf p_executeCompletionForURL:url image:img];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        log4Error(@"file downloading error : %@", [error localizedDescription]);
    }];
    [downloadRequest start];
    
    /*
    NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            [weakSelf p_executeCompletionForURL:url image:responseObject];
        }
    }];
    [dataTask resume];
     */
}

- (void)p_addComplection:(MTDownloadImageCompletion)completion forURL:(NSString*)url
{
    if ([[_completions allKeys] containsObject:url])
    {
        NSMutableArray* completions = _completions[url];
        [completions addObject:[completion copy]];
    }
    else
    {
        NSMutableArray* completions = [[NSMutableArray alloc] init];
        [completions addObject:[completion copy]];
        [_completions setObject:completions forKey:url];
    }
}

- (void)p_executeCompletionForURL:(NSString*)url image:(NSImage*)image
{
    if ([[_completions allKeys] containsObject:url])
    {
        NSMutableArray* completions = _completions[url];
        for (NSInteger index = 0; index < [completions count]; index ++)
        {
            MTDownloadImageCompletion completion = completions[index];
            completion(image);
        }
    }
}
@end
