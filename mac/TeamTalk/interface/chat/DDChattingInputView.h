//
//  DDChattingInputView.h
//  Duoduo
//
//  Created by zuoye on 13-12-3.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDSendingTextView.h"
#import "DDImageMessage.h"
#import "MTSessionEntity.h"


@interface DDChattingInputView : DDSendingTextView<NSTextViewDelegate>{
    NSMutableArray		*historyArray;
    NSMutableArray  *sendQueue;
    int                  currentHistoryLocation;
    MTSessionEntity *sessonEntity;
    DDImageMessage *imageMessage;
}
@property (nonatomic,assign)NSUInteger currentIndex;
- (void)pasteAsPlainTextWithTraits:(id)sender;
- (NSImage *)currentImage;
- (void)setSessionEntity: (MTSessionEntity *)session;
@end
