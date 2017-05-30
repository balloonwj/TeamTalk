//
//  DDChattingViewModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingViewModule.h"
#import "MTSessionEntity.h"
#import "DDEmotionAttachment.h"
#import "AIImageAdditions.h"
#import "EGOCache.h"
#import "NSAttributedString+Message.h"
#import "MessageEntity.h"
#import "EmotionManager.h"
#import "EGOImageLoader.h"
#import "NSImage+Addition.h"
#import "MTMessageModule.h"
@interface DDChattingViewModule(privateAPI)

- (void)fetchGroupUsers;
- (NSAttributedString*)getTextAndEmotionAttributeFromText:(NSString*)text;

@end

@implementation DDChattingViewModule
{
    NSAttributedString* _currentContent;
}
- (id)initWithSession:(MTSessionEntity*)session
{
    self = [super init];
    if (self)
    {
        _session = session;
        //获取组内成员
        _firstMessageID = [[MTMessageModule shareInstance] getLastMessageIDForSessionID:session.sessionID];
        _loadingHistoryMessage = NO;
        _firstTimeToLoadMessage = YES;
        
    }
    return self;
}


- (NSAttributedString*)getAttributedStringFromInputContent:(NSAttributedString*)inputContent compress:(BOOL)compress
{
    NSMutableAttributedString* resultAttributedString = [[NSMutableAttributedString alloc] init];
    
    if (inputContent.length) {
        NSUInteger lastTextIndex = 0;
        NSUInteger i = 0;
        for (i=0; i<inputContent.length; i++) {
            NSTextAttachment *attachment = [inputContent attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
            
            if (attachment)
            {
                
                if (lastTextIndex != i)
                {
                    NSString *msgData = [[inputContent attributedSubstringFromRange:NSMakeRange(lastTextIndex, i - lastTextIndex)] string];
                    NSAttributedString* tempAttribute = [NSAttributedString textAttributedString:msgData];
                    [resultAttributedString appendAttributedString:tempAttribute];
                }
                lastTextIndex = i + 1;
                
                NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
                [resultAttributedString appendAttributedString:attributedString];
                
//                if ([attachment isKindOfClass:[DDEmotionAttachment class]])
//                {
//                    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
//                    [resultAttributedString appendAttributedString:attributedString];
//                }else
//                {
//                    NSImage *image = nil;
//                    if ([attachment respondsToSelector:@selector(image)])
//                    {
//                        image = [attachment performSelector:@selector(image)];
//                    }
//                    if (!image)
//                    {
//                        if ([[attachment attachmentCell] respondsToSelector:@selector(image)])
//                        {
//                            image = [[attachment attachmentCell] performSelector:@selector(image)];
//                        }
//                    }
//                    NSString* preferredFileName = [[attachment fileWrapper] preferredFilename];
//                    NSString* suffixFileName = [preferredFileName substringWithRange:NSMakeRange([preferredFileName rangeOfString:@"."].location + 1, [preferredFileName length] - [preferredFileName rangeOfString:@"."].location - 1)];
//                    suffixFileName = [suffixFileName length] > 0 ? suffixFileName : @"png";
//                    NSString *imageKey =[NSString stringWithFormat:@"tem-%lu", [[image description] hash]];
//                    NSString *fileName=[[[EGOCache currentCache] pathForKey:imageKey]  stringByAppendingPathExtension:suffixFileName];
//                    
//                    [image saveImageToFile:fileName compressionFactor:1.0];
//                    
//                    NSAttributedString* imageAttribute = [NSAttributedString imageAttributedString:fileName realImageURL:nil compressImage:compress];
//                    [resultAttributedString appendAttributedString:imageAttribute];
//                }
            }
        }
        
        if (lastTextIndex != i)
        {
            NSString *msgData = [[inputContent attributedSubstringFromRange:
                                  NSMakeRange(lastTextIndex, i - lastTextIndex)] string];
            NSAttributedString* textAttributedString = [NSAttributedString textAttributedString:msgData];
            [resultAttributedString appendAttributedString:textAttributedString];
        }
    }
    return resultAttributedString;
}

- (NSAttributedString*)getLastInputHistoryMessages
{
    if (self.inputHistoryMessageIndex == 0)
    {
        _currentContent = [self.dataSource getCurrentAttribute];
    }
    
    NSAttributedString* attribute = [[MTMessageModule shareInstance] getInputHistoryForSessionID:self.session.sessionID forIndex:self.inputHistoryMessageIndex];
    if (attribute)
    {
        self.inputHistoryMessageIndex ++;
    }
    return attribute;
}

- (NSAttributedString*)getNextInputHistoryMessages
{
    self.inputHistoryMessageIndex --;
    NSAttributedString* attribute = [[MTMessageModule shareInstance] getInputHistoryForSessionID:self.session.sessionID forIndex:self.inputHistoryMessageIndex];
    if (!attribute)
    {
        self.inputHistoryMessageIndex ++;
        attribute = [_currentContent copy];
    }
    DDLog(@"------------------------->%lu",(unsigned long)self.inputHistoryMessageIndex);
    return attribute;
}

#pragma mark - PrivateAPI
- (NSAttributedString*)getTextAndEmotionAttributeFromText:(NSString*)text
{
    NSMutableAttributedString* resultAttribute = [[NSMutableAttributedString alloc] init];
    NSMutableString *msgContent = [NSMutableString stringWithString:text];
    NSRange startRange;
    while ((startRange = [msgContent rangeOfString:@"["]).location != NSNotFound) {
        if (startRange.location > 0)
        {
            NSString *str = [msgContent substringWithRange:NSMakeRange(0, startRange.location)];
            DDLog(@"[前文本内容:%@",str);
            [msgContent deleteCharactersInRange:NSMakeRange(0, startRange.location)];
            startRange.location=0;
            NSAttributedString* textAttribute = [NSAttributedString textAttributedString:str];
            [resultAttribute appendAttributedString:textAttribute];
        }
        
        NSRange endRange = [msgContent rangeOfString:@"]"];
        if (endRange.location != NSNotFound) {
            NSRange range;
            range.location = 0;
            range.length = endRange.location + endRange.length;
            NSString *emotionText = [msgContent substringWithRange:range];
            [msgContent deleteCharactersInRange:
             NSMakeRange(0, endRange.location + endRange.length)];
            
            DDLog(@"类似表情字串:%@",emotionText);
            NSString *emotionFile = [[EmotionManager instance] getFileFrom:emotionText];
            if (emotionFile) {
                // 表情
                NSString *path = [[NSBundle mainBundle] pathForResource:emotionFile ofType:nil];
                DDEmotionAttachment* emotionAttribute = [[DDEmotionAttachment alloc] init];
                NSURL *fileUrl = [NSURL fileURLWithPath:path];
                NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initSymbolicLinkWithDestinationURL:fileUrl];
                NSImage* emotionImage = [[NSImage alloc] initWithContentsOfURL:fileUrl];
                [fileWrapper setIcon:emotionImage];
                [fileWrapper setPreferredFilename:path];
                [emotionAttribute setFileWrapper:fileWrapper];
                [emotionAttribute setEmotionFileName:emotionFile];
                [emotionAttribute setEmotionPath:path];
                [emotionAttribute setEmotionText:emotionText];
                NSMutableAttributedString *attachmentString = (NSMutableAttributedString*)[NSMutableAttributedString attributedStringWithAttachment:emotionAttribute];

                [resultAttribute appendAttributedString:attachmentString];
            } else
            {
                NSAttributedString* textAttribute = [NSAttributedString textAttributedString:emotionText];
                [resultAttribute appendAttributedString:textAttribute];
            }
        } else {
            DDLog(@"没有[匹配的后缀");
            break;
        }
    }
    
    if ([msgContent length] > 0)
    {
        NSAttributedString* textAttribute = [NSAttributedString textAttributedString:msgContent];
        [resultAttribute appendAttributedString:textAttribute];
    }
    return resultAttribute;
}

- (void)fetchGroupUsers
{
//    switch (_session.type)
//    {
//        case SESSIONTYPE_SINGLE:
//            break;
//        case SESSIONTYPE_GROUP:
//        case SESSIONTYPE_TEMP_GROUP:
//        {
//            [_session.groupUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSString* userID = (NSString*)obj;
//            }];
//        }
//            break;
//    }
}

@end
