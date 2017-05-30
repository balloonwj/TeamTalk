//
//  MessageCellView.h
//  ScrollViewChatDemo
//
//  Created by 独嘉 on 14-3-16.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MessageViewFactory : NSView
{
    NSLayoutManager* _layoutManager;
}

+ (MessageViewFactory*)instance;

- (NSTextView*)produceTextViewWithMessage:(NSAttributedString*)message;

+ (NSRect)getContentRectFromMessage:(NSAttributedString*)message;
@end
