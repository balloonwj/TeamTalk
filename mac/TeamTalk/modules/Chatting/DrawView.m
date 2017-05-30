//
//  DrawView.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DrawView.h"
#import "NSAttributedString+Message.h"
@implementation DrawView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{    
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    if (![[pasteboard types] containsObject:NSFilenamesPboardType]) {
        return NO;
    }
    
    NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
    NSString *file = [files objectAtIndex:0];
    // do not support directory in this version
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSDictionary *dict = [fileManage attributesOfItemAtPath:file error:nil];
    NSString *fileType = [dict objectForKey:NSFileType];
    if (fileType != NSFileTypeRegular) {
        DDLog(@"not a file!!!");
        return NO;
    }
    else
    {
        if (self.delegate)
        {
            [self.delegate drawFileInTo:file];
        }
    }
    return YES;
}
@end
