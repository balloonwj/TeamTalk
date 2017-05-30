//
//  DDMessageTextView.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageTextView.h"
#import "NSAttributedString+Message.h"
#import "DDChangableAttactment.h"
#import <Quartz/Quartz.h>
#import <QuickLook/QuickLook.h>
#import "DDPathHelp.h"
@interface DDMessageTextView(PrivateAPI)

- (void)p_saveImageSource;
- (void)p_saveImageAtPath;
- (void)p_copy;

@end

@implementation DDMessageTextView
{
    NSMutableArray* realURLs;
    NSInteger _currentClickIndex;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)setAttributeString:(NSAttributedString*)sender
{
    self.delegate = self;
    [self setEditable:YES];
    [self setString:@""];
    if (self.loadDelegate)
    {
        [self.loadDelegate resetScrollView];
    }
    [self insertText:sender];
//    [self changeAttributes:sender];
    NSUInteger i = 0;
//    BOOL finishAddRealURL = [realURLs count] > 0;
    for (i=0; i<sender.length; i++)
    {
        DDChangableAttactment *attachment = [sender attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if ([attachment isKindOfClass:[DDChangableAttactment class]])
        {
            NSString* realURL = attachment.realURL;
//            if (!realURLs)
//            {
//                realURLs = [[NSMutableArray alloc] init];
//            }
            if (realURL)
            {
                NSString* cachePath = [[EGOImageLoader sharedImageLoader] cachePathForURL:[NSURL URLWithString:realURL]];
                NSImage* image = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:realURL] shouldLoadWithObserver:self];
                if (cachePath && image)
                {
                    NSAttributedString* newAttribute = [NSAttributedString imageAttributedString:cachePath realImageURL:nil compressImage:YES];

                    [self.textStorage replaceCharactersInRange:NSMakeRange(i, 1) withAttributedString:newAttribute];
                }
                else
                {
                    NSURL* url = [NSURL URLWithString:realURL];
                    if (url)
                    {
                        [[EGOImageLoader sharedImageLoader] loadImageForURL:url completion:^(NSImage *image, NSURL *imageURL, NSError *error) {
                            
                            NSString* imageCachePath = [[EGOImageLoader sharedImageLoader] cachePathForURL:[NSURL URLWithString:realURL]];
                            NSAttributedString* newAttribute = [NSAttributedString imageAttributedString:imageCachePath realImageURL:nil compressImage:YES];
                            
                            [self.textStorage replaceCharactersInRange:NSMakeRange(i, 1) withAttributedString:newAttribute];
                            if (self.loadDelegate)
                            {
                                [self.loadDelegate messageTextView:self finishLoadAttachAtIndex:i];
                            }
                        }];
                    }
//                    [[EGOImageLoader sharedImageLoader] loadImageForURL:[NSURL URLWithString:realURL]
//                                                               observer:self];
                }
            }
//            if (!finishAddRealURL && realURL)
//            {
//                [realURLs addObject:realURL];
//            }
        }
    }
    [self setEditable:NO];
}

-(void)keyDown:(NSEvent *)theEvent{
    unichar characters =  [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(characters != 0x20){
        [super keyDown:theEvent];
    }else{
        NSPoint point = [theEvent locationInWindow];
        DDLog(@"%@",NSStringFromPoint(point));
        QLPreviewPanel *prePanel = [QLPreviewPanel sharedPreviewPanel];
        if (prePanel) {
            [prePanel setDataSource:self];
            [prePanel makeKeyAndOrderFront:nil];
        }
    }
    
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    DDLog(@"right mouse down");
    NSMenu* menu = [[NSMenu alloc] init];
    
    NSMenuItem* copyItem = [[NSMenuItem alloc] initWithTitle:@"复制" action:@selector(p_copy) keyEquivalent:@""];
    [copyItem setTarget:self];
    [menu addItem:copyItem];
    
    NSMenuItem* saveItem = [[NSMenuItem alloc] initWithTitle:@"保存" action:@selector(p_saveImageSource) keyEquivalent:@""];
    [saveItem setTarget:self];
    
    NSMenuItem* savePathItem = [[NSMenuItem alloc] initWithTitle:@"另存为" action:@selector(p_saveImageAtPath) keyEquivalent:@""];
    [savePathItem setTarget:self];
    
    DDChangableAttactment* attachment = (DDChangableAttactment*)[self.textStorage attribute:NSAttachmentAttributeName atIndex:_currentClickIndex effectiveRange:NULL];
    NSString* filePath = [[attachment fileWrapper] symbolicLinkDestination];
    if (filePath)
    {
        [saveItem setEnabled:YES];
        [savePathItem setEnabled:YES];
        [menu addItem:saveItem];
        [menu addItem:savePathItem];

    }
    
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}

- (BOOL)resignFirstResponder
{
    [self setSelectedRange:NSMakeRange(0, 0)];
    return YES;
}

- (void)dealloc
{
//    [[EGOImageLoader sharedImageLoader] removeObserver:self];
    self.loadDelegate = nil;
    DDLog(@"asdasd");
}

#pragma mark QLPreviewPanel DataSource
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    for(int i = 0;i < [self.textStorage length]; i ++)
    {
        DDChangableAttactment* attachment = (DDChangableAttactment*)[self.textStorage attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if (i == _currentClickIndex)
        {
            return attachment;
        }
    }
    return nil;
}


#pragma mark NSTextView Delegate
- (void)textView:(NSTextView *)textView
   clickedOnCell:(id<NSTextAttachmentCell>)cell
          inRect:(NSRect)cellFrame
         atIndex:(NSUInteger)charIndex
{
    _currentClickIndex = charIndex;
//    selectImageRect = cellFrame;
    [self setNeedsDisplay:YES];
}

- (NSURL *)textView:(NSTextView *)textView URLForContentsOfTextAttachment:(NSTextAttachment *)textAttachment atIndex:(NSUInteger)charIndex
{
    return [[textAttachment fileWrapper] symbolicLinkDestinationURL];
}


#pragma mark -
#pragma mark - privateAPI
- (void)p_saveImageSource
{
    
    for(int i = 0;i < [self.textStorage length]; i ++)
    {
        DDChangableAttactment* attachment = (DDChangableAttactment*)[self.textStorage attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
        if (i == _currentClickIndex)
        {
            NSString* filePath = [[attachment fileWrapper] symbolicLinkDestination];
            if (filePath)
            {
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSError* error;
                NSString* copyFileName = [NSString stringWithFormat:@"TeamTalk-Image-%li.png",(NSUInteger)[[NSDate date] timeIntervalSince1970]];
                NSString* copyFilePath = [[DDPathHelp downLoadPath] stringByAppendingPathComponent:copyFileName];
                if ([fileManager isReadableFileAtPath:filePath])
                {
                    BOOL copy = [fileManager copyItemAtPath:filePath toPath:copyFilePath error:&error];
                    if (!copy)
                    {
                        DDLog(@"保存图片失败:%@",error);
                    }
//                    else
//                    {
//                        NSDictionary* attribute = [fileManager attributesOfItemAtPath:copyFilePath error:&error];
//                        NSMutableDictionary* newAttribute = [NSMutableDictionary dictionaryWithDictionary:attribute];
//                        [newAttribute setValue:[NSDate date] forKey:NSFileCreationDate];
//                        BOOL createModiey = [fileManager setAttributes:newAttribute ofItemAtPath:copyFilePath error:&error];
//                    }
                }
            }
        }
    }
}

- (void)p_saveImageAtPath
{
    __block NSSavePanel *panel = [NSSavePanel savePanel];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for(int i = 0;i < [self.textStorage length]; i ++)
            {
                DDChangableAttactment* attachment = (DDChangableAttactment*)[self.textStorage attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
                if (i == _currentClickIndex)
                {
                    NSString* filePath = [[attachment fileWrapper] symbolicLinkDestination];
                    if (filePath)
                    {
                        NSFileManager* fileManager = [NSFileManager defaultManager];
                        NSError* error;
                        NSString* savePath = [[panel URL] path];
                        NSString* lastComponent = [savePath lastPathComponent];
                        if ([lastComponent rangeOfString:@".png"].length == 0)
                        {
                            savePath = [savePath stringByAppendingString:@".png"];
                        }
                        if ([fileManager isReadableFileAtPath:filePath])
                        {
                            BOOL copy = [fileManager copyItemAtPath:filePath toPath:savePath error:&error];
                            if (!copy)
                            {
                                DDLog(@"保存图片失败:%@",error);
                            }
                        }
                    }
                }
            }
        }
        
        panel=nil;
    }];
}

- (void)copy:(id)sender
{
    [super copy:sender];
}

- (void)p_copy
{
    NSDictionary *documentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:NSRTFTextDocumentType, NSDocumentTypeDocumentAttribute, nil];
    NSData * data = [self.attributedString dataFromRange:NSMakeRange(0, [self.attributedString length]) documentAttributes:documentAttributes error:nil];
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    BOOL success = [pasteboard setData:data forType:NSRTFPboardType];
    DDLog(@"asd");
}

@end
