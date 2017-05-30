//
//  NSAttributedString+Message.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSAttributedString+Message.h"
#import "NSImage+Scale.h"
#import "DDChangableAttactment.h"
#import "DDEmotionAttachment.h"
#import "MTImageCache.h"
#import "DDPathHelp.h"
NSString* const realURLKey = @"RealURLKey";
@implementation NSAttributedString (Message)
+ (NSAttributedString *)imageAttributedString:(NSString *)imagePath realImageURL:(NSString*)realURL compressImage:(BOOL)compress
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    NSImage *scaleImage;
    if (image.size.width > 400 && compress)
    {
        scaleImage = [image scaleImageToWidth:400];
    }
    else
    {
        scaleImage = image;
    }
    // 用NSFileWrapper是为了显示动态的表情
    // 但setIcon对大于聊天窗口的图片显示有问题
    // 所以对于有缩放的图片，先用NSTextAttachmentCell代替
    // 以后看看是不是有其他解决方案
    DDChangableAttactment *attachment = [[DDChangableAttactment alloc] initWithRealURL:realURL];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:imagePath];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initSymbolicLinkWithDestinationURL:fileUrl];
    [fileWrapper setIcon:scaleImage];
    [fileWrapper setPreferredFilename:imagePath];
    
    [attachment setFileWrapper:fileWrapper];
    
    if (scaleImage != image) {
        NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:scaleImage];
        [attachment setAttachmentCell:attachmentCell];
    }
    
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
    
    return attributedString;
}

+ (NSAttributedString *)textAttributedString:(NSString *)text
{
    NSMutableAttributedString *textContent = [[NSMutableAttributedString alloc]
                                              initWithString:text
                                              attributes:nil];
    
    // add http link highlight
    NSDataDetector* dataDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    NSArray *matches = [dataDetector matchesInString:text
                                             options:0
                                               range:NSMakeRange(0, [text length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [textContent addAttributes:@{NSLinkAttributeName:url.absoluteString}
                                 range:matchRange];
        }
    }
    return textContent;
}

- (NSAttributedString *)replactTheAttactementAtIndex:(NSUInteger)index withAttachementImagePath:(NSString*)attachementPath
{
    NSMutableAttributedString* resultAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    NSUInteger currentIndex = -1;
    for (NSUInteger i=0; i<self.length; i++)
    {
        DDChangableAttactment *currentAttachment = [self attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if ([currentAttachment isKindOfClass:NSClassFromString(@"DDChangableAttactment")])
        {
            currentIndex ++;
            if (currentIndex == index)
            {
                NSAttributedString* newAttribute = [NSAttributedString imageAttributedString:attachementPath realImageURL:nil compressImage:YES];
                [resultAttributedString replaceCharactersInRange:NSMakeRange(i, 1) withAttributedString:newAttribute];
                break;
            }
        }
    }
    return resultAttributedString;
}

+ (NSAttributedString*)imageAttributeString:(NSString*)imagePath compressImage:(BOOL)compress
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    NSImage *scaleImage;
    if (image.size.width > 400 && compress)
    {
        scaleImage = [image scaleImageToWidth:400];
    }
    else
    {
        scaleImage = image;
    }
    // 用NSFileWrapper是为了显示动态的表情
    // 但setIcon对大于聊天窗口的图片显示有问题
    // 所以对于有缩放的图片，先用NSTextAttachmentCell代替
    // 以后看看是不是有其他解决方案
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:imagePath];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initSymbolicLinkWithDestinationURL:fileUrl];
    [fileWrapper setIcon:scaleImage];
    [fileWrapper setPreferredFilename:imagePath];
    
    [attachment setFileWrapper:fileWrapper];
    
    if (scaleImage != image) {
        NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:scaleImage];
        [attachment setAttachmentCell:attachmentCell];
    }
    
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
    
    return attributedString;
}

- (NSString*)getString
{
    NSMutableString* resultContent = [[NSMutableString alloc] init];
    NSAttributedString *text = self;
    for (int i=0; i<text.length; i++)
    {
        NSTextAttachment *attachment = [text attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if (attachment)
        {
            if (![attachment isKindOfClass:[DDEmotionAttachment class]])
            {
                NSString* filePath;
                //图片
                if ([attachment respondsToSelector:@selector(path)])
                {
                    filePath = [attachment performSelector:@selector(path)];
                }
                else
                {
                    NSFileWrapper* fileWrapper = attachment.fileWrapper;
                    filePath = fileWrapper.preferredFilename;
                    if (![filePath hasPrefix:@"/"])
                    {
                        NSData* data = [fileWrapper regularFileContents];
                        filePath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:filePath];
                        [data writeToFile:filePath atomically:YES];
                    }
                }
                [resultContent appendString:IMAGE_MARK_START];
                [resultContent appendString:filePath];
                [resultContent appendString:IMAGE_MARK_END];
            }
            else
            {
                //是表情
                NSString *emotionText =  [(DDEmotionAttachment *)attachment emotionText];
                [resultContent appendString:emotionText];
            }
        }else
        {
            //是文字
            [resultContent appendString:[[text attributedSubstringFromRange:NSMakeRange(i, 1)] string]];
        }
    }
    return resultContent;
}

- (NSArray*)filePaths
{
    NSAttributedString *text = self;
    NSMutableArray* filePaths = [[NSMutableArray alloc] init];
    for (int i=0; i<text.length; i++)
    {
        NSTextAttachment *attachment = [text attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if (attachment)
        {
            if (![attachment isKindOfClass:[DDEmotionAttachment class]])
            {
                //是图片不是表情
                NSString* filePath;
                if ([attachment respondsToSelector:@selector(path)])
                {
                    filePath = [attachment performSelector:@selector(path)];
                }
                else
                {
                    NSFileWrapper* fileWrapper = attachment.fileWrapper;
                    filePath = fileWrapper.preferredFilename;
                    if (![filePath hasPrefix:@"/"])
                    {
                        filePath = [[DDPathHelp imageCachePath] stringByAppendingPathComponent:filePath];
                    }
                }

                if (![filePaths containsObject:filePath])
                {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil])
                    {
                        [filePaths addObject:filePath];
                    }
                }
            }
        }
    }
    return filePaths;
}

@end
