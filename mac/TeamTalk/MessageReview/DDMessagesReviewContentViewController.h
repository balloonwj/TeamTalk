//
//  DDMessagesReviewContentViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDMessagesReviewContentViewController : NSViewController
{
    __weak IBOutlet NSScrollView* _messageScrollView;
    __weak IBOutlet NSTextField* _pageCountTextField;
    __weak IBOutlet NSTextField* _currentPageTextField;
    __weak IBOutlet NSTextField* _dateTextField;
    
    __weak IBOutlet NSButton* _nextPageButton;
    __weak IBOutlet NSButton* _moreNextPageButton;
    __weak IBOutlet NSButton* _lastPageButton;
    __weak IBOutlet NSButton* _moreLastPageButton;
}

/**
 *  更新会话，更新总页数，页面更新到最新的历史消息
 *
 *  @param sessionID 会话ID
 */
- (void)updateSession:(NSString*)sessionID;

/**
 *  更新历史消息页面内容
 *
 *  @param page      页码
 */
- (void)updateForPage:(NSInteger)page;

@end
