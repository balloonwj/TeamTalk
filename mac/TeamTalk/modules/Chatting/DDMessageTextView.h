//
//  DDMessageTextView.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@class DDMessageTextView;
@protocol DDMessageTextViewDelegate <NSObject,QLPreviewPanelDataSource>

//不知道为什么在setAttributeString中的insertText时，ScrollView的offset会变
- (void)resetScrollView;
- (void)messageTextView:(DDMessageTextView*)textView finishLoadAttachAtIndex:(NSUInteger)index;

@end

@interface DDMessageTextView : NSTextView<EGOImageLoaderObserver,NSTextViewDelegate>

@property (nonatomic,assign)id<DDMessageTextViewDelegate> loadDelegate;

/**
 *  只能设置一次，设置多次会出错，设置富文本
 *
 *  @param sender 富文本
 */
- (void)setAttributeString:(NSAttributedString*)sender;
@end
