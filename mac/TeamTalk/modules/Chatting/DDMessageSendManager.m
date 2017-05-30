
//
//  DDMessageSendManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageSendManager.h"
#import "DDEmotionAttachment.h"
#import "DDImageUploader.h"
#import "MTSessionEntity.h"
#import "MTMessageEntity.h"
#import "MTMessageModule.h"
#import "DDTcpClientManager.h"
#import "DDSendMessageAPI.h"
#import "NSAttributedString+Message.h"
#import "DDImageUploader.h"
#import "DDPathHelp.h"
#import "MTImageCache.h"
static uint32_t seqNo = 0;
static const NSUInteger maxContentLength = 3500;

@interface DDMessageSendManager(PrivateAPI)

- (NSString*)p_copyImageFileFromOriginPath:(NSString*)originPath;

- (void)sendSimpleMessage:(NSAttributedString *)content forSession:(MTSessionEntity *)session success:(void (^)(NSString *))success failure:(void(^)(NSString*))failure;
- (void)sendMixMessage:(NSAttributedString *)content forSession:(MTSessionEntity *)session success:(void (^)(NSString *))success failure:(void(^)(NSString*))failure;
//- (MessageEntity*)messageWithSession:(MTSessionEntity*)session contentToSend:(NSString*)content;

- (void)p_sendText:(MTMessageEntity*)message forSession:(MTSessionEntity*)session success:(MTSendMessageSuccess)success failure:(MTSendMessageFailure)failure;

@end

@implementation DDMessageSendManager
{
    DDImageUploader* _imageUpload;
    NSUInteger _uploadImageCount;
}
+ (instancetype)instance
{
    static DDMessageSendManager* g_messageSendManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageSendManager = [[DDMessageSendManager alloc] init];
    });
    return g_messageSendManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _uploadImageCount = 0;
        _waitToSendMessage = [[NSMutableArray alloc] init];
        _sendMessageSendQueue = dispatch_queue_create("com.mogujie.Duoduo.sendMessageSend", NULL);
        _imageUpload = [[DDImageUploader alloc] init];
    }
    return self;
}

- (MTMessageEntity*)sendMessage:(NSAttributedString*)content forSession:(MTSessionEntity*)session success:(MTSendMessageSuccess)success  failure:(MTSendMessageFailure)failure
{
#warning 要用服务器时间
    NSUInteger messageTime = [[NSDate date] timeIntervalSince1970];
    
    NSString* senderID = [DDClientState shareInstance].userID;
    
    __block NSString* messageContent = [content getString];
    
    //如果有图片需要先上传图片

    NSArray* filePaths = [content filePaths];
    NSMutableArray* destFilePaths = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < [filePaths count]; index ++)
    {
        NSString* originFilePath = filePaths[index];
        NSString* destFilePath = [self p_copyImageFileFromOriginPath:originFilePath];
        if (destFilePath)
        {
            [destFilePaths addObject:destFilePath];
        }
        else
        {
            [destFilePaths addObject:originFilePath];
        }
        messageContent = [messageContent stringByReplacingOccurrencesOfString:originFilePath withString:destFilePath];
    }
    
    MTMessageEntity* messageEntity = [[MTMessageEntity alloc] initWithServerMessageID:0 type:MessageTypeNormal messageTime:messageTime sessionID:session.sessionID senderID:senderID targetID:session.originID content:messageContent state:MessageSending];

    
    __weak DDMessageSendManager* weakSelf = self;
    if ([destFilePaths count] > 0)
    {
        NSMutableArray* newfilePaths = [[NSMutableArray alloc] initWithArray:destFilePaths];
        for (NSUInteger index = 0; index < [newfilePaths count]; index ++)
        {
//            NSImage* image = images[index];
            NSString* filePath = newfilePaths[index];
            [_imageUpload uploadImageAtFilePath:filePath completion:^(NSString *url, NSError *error) {
                if (url)
                {
                    [[MTImageCache shareInstance] cacheImageFilePath:filePath forKey:url];
                    messageContent = [messageContent stringByReplacingOccurrencesOfString:filePath withString:url];
                    [newfilePaths removeObject:filePath];
                    if ([newfilePaths count] == 0)
                    {
                        //图片上传完成
                        MTMessageEntity* messageEntity = [[MTMessageEntity alloc] initWithServerMessageID:0 type:MessageTypeNormal messageTime:messageTime sessionID:session.sessionID senderID:senderID targetID:session.originID content:messageContent state:MessageSending];
                        [weakSelf p_sendText:messageEntity forSession:session success:success failure:failure];
                    }
                }
            }];
        }
    }
    else
    {
        [self p_sendText:messageEntity
              forSession:session
                 success:success
                 failure:failure];
    }
    return messageEntity;
}

#pragma mark Private API
- (NSString*)p_copyImageFileFromOriginPath:(NSString*)originPath
{
    NSString* fileName = [[originPath componentsSeparatedByString:@"/"] lastObject];
    if ([fileName length] > 0)
    {
        NSString* suffix = [[fileName componentsSeparatedByString:@"."] lastObject];
        NSUInteger timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString* newFileName = [NSString stringWithFormat:@"%li-%lu.%@",[fileName hash],timeInterval,suffix];
        NSString* newFilePath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:newFileName];
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtPath:originPath toPath:newFilePath error:&error];
        if (error)
        {
            log4Error(@"复制图片出错,Path:%@",originPath);
        }
        return newFilePath;
    }
    return nil;
}

- (void)sendMixMessage:(NSAttributedString *)content forSession:(MTSessionEntity *)session success:(void (^)(NSString *))success failure:(void(^)(NSString* ))failure
{
    dispatch_async(self.sendMessageSendQueue, ^{
        NSString* string = [content getHasImageContentFromInput];

        DDSendMessageAPI* sendMessageAPI = [[DDSendMessageAPI alloc] init];
        uint32_t nowSeqNo = ++seqNo;
        NSString *myUserId = [[DDClientState shareInstance]userID];
        NSArray* object = @[myUserId,session.sessionID,string,[NSNumber numberWithInt:nowSeqNo],[NSNumber numberWithInt:session.sessionType]];
        
        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                uint32_t returnSeqNo = [response intValue];
                if (returnSeqNo == nowSeqNo)
                {
                    success(string);
                }
                else
                {
                    failure(@"seqNo不同");
                    DDLog(@"different seqNo");
                }
                
            }
            else
            {
                failure(@"发送超时");
            }
        }];
    });
}

- (void)p_sendText:(MTMessageEntity*)message forSession:(MTSessionEntity*)session success:(MTSendMessageSuccess)success failure:(MTSendMessageFailure)failure
{
    DDSendMessageAPI* sendMessageAPI = [[DDSendMessageAPI alloc] init];
    
    NSString *myUserId = [[DDClientState shareInstance]userID];
    
    //长度限制
    NSData* data = [message.messageContent dataUsingEncoding:NSUTF8StringEncoding];
    if ([data length] > maxContentLength)
    {
        NSError* error = [NSError errorWithDomain:@"内容太长了" code:1002 userInfo:nil];
        failure(message,error);
        return;
    }
    
     NSArray* object = @[myUserId,session.originID,@(session.sessionType),message.messageContent];
     [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
         if (!error)
         {
             NSUInteger messageServerID = [response integerValue];
             message.messageServerID = messageServerID;
             success(message);
         }
         else
         {
             failure(message,error);
         }
     }];
}
@end