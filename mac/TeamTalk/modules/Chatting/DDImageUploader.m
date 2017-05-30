//
//  DDImageUploader.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDImageUploader.h"
#import <AFNetworking/AFNetworking.h>
#import "NSImage+Addition.h"
#import "MTImageCache.h"
#import "DDLoginManager.h"

@implementation DDImageUploader
{
   
    //AFURLSessionManager* _urlSessionManager;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        /*
        _urlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        AFHTTPResponseSerializer* responseSerialzer = [[AFHTTPResponseSerializer alloc] init];
        responseSerialzer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
        _urlSessionManager.responseSerializer = responseSerialzer;
         */
    }
    return self;
}

- (void)uploadImage:(NSImage*)image completion:(MTUploadImageCompletion)completion
{
    /*
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    [manager POST:@"http://samwize.com/api/poo/"
       parameters:@{@"color": @"green"}
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileURL:filePath name:@"image" error:nil];
} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"Success: %@", responseObject);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}]
     */
    

    NSData* imageData = [image imageDataCompressionFactor:1.0];
    NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://msfs.tt.mogujie.org/" parameters:@{@"type":@"im_image"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:imageData name:@"file"];
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.png" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://msfs.tt.mogujie.org/" parameters:@{@"type":@"im_image"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString* url = dic[@"url"];
        if (url)
        {
            [[MTImageCache shareInstance] cacheImage:image forKey:url toMemory:YES];
        }
        completion(url,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil,error);
    }];
    
    
    /*
    NSProgress* progess = nil;
    NSURLSessionUploadTask* uploadTask = [_urlSessionManager uploadTaskWithStreamedRequest:request progress:&progess completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error)
        {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSString* url = dic[@"url"];
            if (url)
            {
                [[MTImageCache shareInstance] cacheImage:image forKey:url toMemory:YES];
            }
            completion(url,nil);
        }else
        {
            completion(nil,error);
        }
    }];
    [uploadTask resume];
     */
}

- (void)uploadImageAtFilePath:(NSString*)filePath completion:(MTUploadImageCompletion)completion
{
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    NSString* fileSuffix = [[filePath componentsSeparatedByString:@"."] lastObject];
    fileSuffix = [fileSuffix length] > 0 ? fileSuffix : @"png";
    NSString* fileName = [NSString stringWithFormat:@"image.%@",fileSuffix];
    NSImage *image = [[NSImage alloc]initWithData:imageData];
 
        /*
    NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://msfs.tt.mogujie.org/" parameters:@{@"type":@"im_image"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
    } error:nil];
         */
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *msfsUrlString = [NSString stringWithFormat:@"%@", [DDClientState shareInstance].msfsURL];
    [manager POST:msfsUrlString parameters:@{@"type":@"im_image"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString* url = dic[@"url"];
        if (url)
        {
            [[MTImageCache shareInstance] cacheImage:image forKey:url toMemory:YES];
        }
        completion(url,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil,error);
    }];
    
    
    /*
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:request writingStreamContentsToFile:tmpFileUrl completionHandler:^(NSError *error) {
        
        // Show progress.
        NSProgress *progress = nil;
        // Here note that we are submitting the initial multipart request. We are, however,
        // forcing the body stream to be read from the temporary file.
        NSURLSessionUploadTask *uploadTask = [_urlSessionManager uploadTaskWithRequest:request
                                                                   fromFile:tmpFileUrl
                                                                   progress:&progress
                                                          completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                              {
                                                  // Cleanup: remove temporary file.
                                                  [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                  
                                                  // Do something with the result.
                                                  if (!error)
                                                  {
                                                      NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                      NSString* url = dic[@"url"];
                                                      if (url)
                                                      {
                                                          [[MTImageCache shareInstance] cacheImageFilePath:filePath forKey:url];
                                                      }
                                                      completion(url,nil);
                                                  }else
                                                  {
                                                      completion(nil,error);
                                                  }

                                                  
                                                  if (error) {
                                                      NSLog(@"Error: %@", error);
                                                  } else {
                                                  }
                                              }];
        
        [uploadTask resume];
    }];
     */
}
@end
