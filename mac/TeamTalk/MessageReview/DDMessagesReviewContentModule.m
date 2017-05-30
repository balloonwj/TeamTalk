//
//  DDMessagesReviewContentModule.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessagesReviewContentModule.h"
#import "NSAttributedString+Message.h"
#import "MessageEntity.h"
#import "DDEmotionAttachment.h"
#import "EmotionManager.h"
@implementation DDMessagesReviewContentModule
+ (NSAttributedString*)getAttributedStringFromShowMessage:(MessageEntity*)message
{
    NSMutableAttributedString* messageShowAttributed = [[NSMutableAttributedString alloc] init];
    
    if ([message.msgContent length] == 0)
    {
        return nil;
    }
    
    NSMutableString *msgContent = [NSMutableString stringWithString:message.msgContent];
    NSRange startRange;
    while ((startRange= [msgContent rangeOfString:IMAGE_MARK_START]).location!=NSNotFound) {
        if (startRange.location>0) {
            NSString *str = [msgContent substringWithRange:NSMakeRange(0, startRange.location)];
            [msgContent deleteCharactersInRange:NSMakeRange(0, startRange.location)];
            startRange.location=0;
            NSAttributedString* textAndEmotionAttribute = [DDMessagesReviewContentModule getTextAndEmotionAttributeFromText:str];
            [messageShowAttributed appendAttributedString:textAndEmotionAttribute];
        }
        
        NSRange endRange = [msgContent rangeOfString:IMAGE_MARK_END];
        if (endRange.location !=NSNotFound) {
            NSRange range;
            range.location = startRange.location+startRange.length;
            range.length = endRange.location-startRange.length-startRange.location;
            NSString *url = [msgContent substringWithRange:range];
            
            DDLog(@"图片url:%@",url);
            [msgContent deleteCharactersInRange:NSMakeRange(startRange.location,(startRange.length+range.length+endRange.length) )];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"tab_bg" ofType:@"png"];
            EGOImageLoader* imageLoder = [EGOImageLoader sharedImageLoader];
            NSString* imagePath = [imageLoder cachePathForURL:[NSURL URLWithString:url]];
            if (imagePath)
            {
                NSAttributedString* imageAttribute = [NSAttributedString imageAttributeString:imagePath compressImage:NO];
                [messageShowAttributed appendAttributedString:imageAttribute];
            }
            else
            {
                NSAttributedString* imageAttribute = [NSAttributedString imageAttributeString:path compressImage:NO];
                [messageShowAttributed appendAttributedString:imageAttribute];
            }
            
        } else {
            DDLog(@"没有匹配后缀:%@",msgContent);
            break;
        }
    }
    
    // add remain text content
    if([msgContent length] > 0){
        DDLog(@"文本.");
        NSAttributedString* emotionTextAttribute = [DDMessagesReviewContentModule getTextAndEmotionAttributeFromText:msgContent];
        [messageShowAttributed appendAttributedString:emotionTextAttribute];
    }
    return messageShowAttributed;
}

#pragma mark - PrivateAPI
+ (NSAttributedString*)getTextAndEmotionAttributeFromText:(NSString*)text
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
@end
