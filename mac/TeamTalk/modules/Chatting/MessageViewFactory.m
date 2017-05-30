//
//  MessageCellView.m
//  ScrollViewChatDemo
//
//  Created by 独嘉 on 14-3-16.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "MessageViewFactory.h"
#import "NSTextView+Rect.h"
#import "DDMessageTextView.h"
#import "DDChangableAttactment.h"
#import "NSAttributedString+Message.h"
#define MESSAGE_VIEW_FONT                   [NSFont systemFontOfSize:13]

@interface MessageViewFactory(privateAPI)


@end

@implementation MessageViewFactory

+ (MessageViewFactory*)instance
{
    static MessageViewFactory* g_messageFactor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageFactor = [[MessageViewFactory alloc] init];
    });
    return g_messageFactor;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _layoutManager = [[NSLayoutManager alloc] init];
    }
    return self;
}

- (NSTextView*)produceTextViewWithMessage:(NSAttributedString*)message
{
//    NSTextStorage* textStorage = _layoutManager.textStorage;
//    NSMutableAttributedString* allMessage = [[NSMutableAttributedString alloc] initWithAttributedString:textStorage.];
    
    DDMessageTextView* textView = [[DDMessageTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    
    [textView setFont:MESSAGE_VIEW_FONT];
    textView.drawsBackground = NO;

    [textView setAttributeString:message];

    [textView setEditable:NO];
    NSRect contentRect = [MessageViewFactory getContentRectFromMessage:textView.textStorage];

//    NSTextContainer* textContainner = [[NSTextContainer alloc] initWithContainerSize:CGSizeMake(contentRect.size.width, contentRect.size.height)];
//    [_layoutManager addTextContainer:textContainner];
//    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:message];
//    [_layoutManager replaceTextStorage:textStorage];
    CGFloat x = 480 - contentRect.size.width;
    static int index = 0;
    CGFloat y = 40 * index;
    index ++;
    [textView setFrame:NSMakeRect(x, y, contentRect.size.width, contentRect.size.height)];
    [textView setFont:MESSAGE_VIEW_FONT];
    textView.drawsBackground = NO;
    [textView setEditable:NO];

    return textView;
}

+ (NSRect)getContentRectFromMessage:(NSAttributedString*)message
{
    NSTextView* textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 480, 1000)];
    [textView.undoManager removeAllActions];
    [textView setFont:MESSAGE_VIEW_FONT];
    [textView insertText:message];
    
    NSRect rect = [textView contentRect];
    return rect;
}
@end
