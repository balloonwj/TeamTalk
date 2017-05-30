//
//  DDMessagesReviewContentViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessagesReviewContentViewController.h"
#import "MessageEntity.h"
#import "MTDatabaseUtil.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "DDMessagesReviewContentModule.h"
#import "NSTextView+Rect.h"
#import "DDMessageReviewTextView.h"
static NSInteger const perpageCount = 20;
static NSInteger const gap = 10;
static CGFloat const nameAndTimeHeight = 20;
static CGFloat const lineHeight = 2;


@interface DDMessagesReviewContentViewController (privateAPI)

- (void)p_registkvo;
- (void)p_cancelRegisteKVO;

- (void)p_addMessage:(MessageEntity*)message;
- (void)p_addNameAndTimeTextField:(MessageEntity*)message;
- (void)p_addContentViewForMessage:(MessageEntity*)message;
- (void)p_addLine;
- (void)p_resizeDocumentView;

- (void)p_updateButton;
@end

@implementation DDMessagesReviewContentViewController
{
    NSString* _sessionID;
    CGFloat _bottom;
    NSInteger _pageCount;
    NSInteger _currentPage;
    NSDate* _firstDateOnContent;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    _bottom = 0;
    [_messageScrollView.documentView setFlipped:YES];
    [self p_registkvo];
}

- (void)dealloc
{
    
}

#pragma mark Public API
- (void)updateSession:(NSString*)sessionID
{
    __weak DDMessagesReviewContentViewController* contentViewController = self;
    NSInteger messageCnt = [[MTDatabaseUtil instance] getMessagesCountForSessionID:sessionID];
#warning DB改动
    NSInteger pagecount = messageCnt % 20 == 0 ? messageCnt / 20 : messageCnt / 20 + 1;
    [self setValue:[NSNumber numberWithInteger:pagecount] forKeyPath:@"pageCount"];
    //定位到最新页
    [self setValue:[NSNumber numberWithInteger:_pageCount] forKeyPath:@"currentPage"];
    _sessionID = sessionID;
    [contentViewController updateForPage:_currentPage];
}

- (void)updateForPage:(NSInteger)page
{
    _currentPage = page;
    //移除原有的子视图
    NSMutableArray* subviews = [NSMutableArray arrayWithArray:[(NSView*)_messageScrollView.documentView subviews]];
    [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    NSClipView* contentView = _messageScrollView.contentView;
    [_messageScrollView.documentView setFrameSize:contentView.bounds.size];
    _bottom = 0;
    //添加消息
    __weak DDMessagesReviewContentViewController* contentViewController = self;
    #warning DB改动
//    [[DDDatabaseUtil instance] loadMessageForSessionID:_sessionID pageCount:perpageCount page:(_currentPage - 1) completion:^(NSArray *messages, NSError *error) {
//        for (NSInteger index = 0; index < [messages count]; index ++)
//        {
//            MessageEntity* message = messages[index];
//            if (index == 0)
//            {
//                uint32 timeInterval = message.msgTime;
//                NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//                [self setValue:date forKeyPath:@"firstDateOnContent"];
//            }
//            [contentViewController p_addMessage:message];
//        }
//    }];
}

#pragma mark NSTextField Delegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"])
    {
        NSString* stringValue = [_currentPageTextField stringValue];
        NSInteger inputPageIndex = [stringValue integerValue];
        if (inputPageIndex > _pageCount)
        {
            [self setValue:[NSNumber numberWithInteger:_pageCount] forKeyPath:@"currentPage"];
        }
        else
        {
            [self setValue:[NSNumber numberWithInteger:inputPageIndex] forKeyPath:@"currentPage"];
        }
        [self updateForPage:_currentPage];
    }
	else
    {
        if ([textView respondsToSelector:commandSelector])
        {
            [textView performSelector:commandSelector withObject:nil afterDelay:0];
        }
    }
    return YES;
}
#pragma mark IBAction
- (IBAction)nextPage:(id)sender
{
    if (_pageCount > _currentPage)
    {
        _currentPage ++;
        [self setValue:[NSNumber numberWithInteger:_currentPage] forKeyPath:@"currentPage"];
        [self updateForPage:_currentPage];
    }
}

- (IBAction)lastPage:(id)sender
{
    if (_currentPage > 1)
    {
        _currentPage --;
        [self setValue:[NSNumber numberWithInteger:_currentPage] forKeyPath:@"currentPage"];
        [self updateForPage:_currentPage];
    }
}

- (IBAction)firstPage:(id)sender
{
    _currentPage = 1;
    [self setValue:@1 forKeyPath:@"currentPage"];

    [self updateForPage:_currentPage];
}

- (IBAction)lastestPage:(id)sender
{
    [self setValue:[NSNumber numberWithInteger:_pageCount] forKeyPath:@"currentPage"];

    [self updateForPage:_currentPage];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPage"])
    {
        [self p_updateButton];
        NSString* title = [NSString stringWithFormat:@"%li",_currentPage];
        [_currentPageTextField setStringValue:title];
    }
    else if ([keyPath isEqualToString:@"pageCount"])
    {
        NSString* title = [NSString stringWithFormat:@"页/% li页",_pageCount];
        [_pageCountTextField setStringValue:title];
        
        [self p_updateButton];
    }
    else if ([keyPath isEqualToString:@"firstDateOnContent"])
    {
        NSDateFormatter* dateFormate = [[NSDateFormatter alloc] init];
        [dateFormate setDateFormat:@"yyyy-MM-dd"];
        NSString* dateString = [dateFormate stringFromDate:_firstDateOnContent];
        [_dateTextField setStringValue:dateString];
    }
}

#pragma mark private API

- (void)p_registkvo
{
    [self addObserver:self forKeyPath:@"currentPage" options:0 context:nil];
    [self addObserver:self forKeyPath:@"pageCount" options:0 context:nil];
    [self addObserver:self forKeyPath:@"firstDateOnContent" options:0 context:nil];
}

- (void)p_cancelRegisteKVO
{
    [self removeObserver:self forKeyPath:@"currentPage"];
    [self removeObserver:self forKeyPath:@"pageCount"];
    [self removeObserver:self forKeyPath:@"firstDateOnContent"];
}

- (void)p_addNameAndTimeTextField:(MessageEntity *)message
{
    NSString* senderID = [message senderId];
    NSString* myUserID =  [[DDClientState shareInstance] userID];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* title = nil;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
    NSString* dateString = [formatter stringFromDate:date];
    
    NSTextField* nameAndTimeTextField = [[NSTextField alloc] init];
    if ([senderID isEqualToString:myUserID])
    {
        //是登录用户发的
        NSString* name =[[MTUserModule shareInstance] myUserEntity].name;
        title = [NSString stringWithFormat:@"%@ %@",name,dateString];
        [nameAndTimeTextField setTextColor:[NSColor colorWithCalibratedRed:248.0 / 255.0
                                                                     green:150.0 / 255.0
                                                                      blue:188.0 / 255.0 alpha:1]];
    }
    else
    {
        //是别人发的
        MTUserEntity* sender =(MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:senderID]; 
        NSString* name = sender.name;
        title = [NSString stringWithFormat:@"%@ %@",name,dateString];
        [nameAndTimeTextField setTextColor:[NSColor grayColor]];

    }
    [nameAndTimeTextField setStringValue:title];
    [nameAndTimeTextField setBordered:NO];
    [nameAndTimeTextField setDrawsBackground:NO];
    [nameAndTimeTextField setEditable:NO];
    [nameAndTimeTextField setFrameSize:NSMakeSize(300, nameAndTimeHeight)];
    [nameAndTimeTextField setFrameOrigin:NSMakePoint(17, _bottom + gap)];
    _bottom += gap + nameAndTimeHeight;
    [self p_resizeDocumentView];
    
    [_messageScrollView.documentView addSubview:nameAndTimeTextField];
}

- (void)p_addContentViewForMessage:(MessageEntity *)message
{
    NSAttributedString* attribute = [DDMessagesReviewContentModule getAttributedStringFromShowMessage:message];
    DDMessageReviewTextView* textView = [[DDMessageReviewTextView alloc] initWithFrame:NSMakeRect(0, 0, 520, 1000)];
    [textView.undoManager removeAllActions];
    [textView setFont:[NSFont systemFontOfSize:13]];
    if (attribute)
    {
        [textView insertText:attribute];
    }
    
    NSRect rect = [textView contentRect];
    [textView setFrameSize:NSMakeSize(rect.size.width,rect.size.height)];
    [textView setFrameOrigin:NSMakePoint(15, _bottom + gap)];
    [textView setDrawsBackground:NO];
    [textView setEditable:NO];
    
    _bottom += gap + rect.size.height;
    [self p_resizeDocumentView];

    [_messageScrollView.documentView addSubview:textView];
}

- (void)p_addLine
{
    NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(16, _bottom + gap, 501, lineHeight)];
    [view setWantsLayer:YES];
    [view.layer setBackgroundColor:[NSColor colorWithCalibratedRed:232.0 / 255.0
                                                             green:233.0 / 255.0
                                                              blue:232.0 / 255.0
                                                             alpha:1].CGColor];
    //TODO 添加颜色
    _bottom += gap + lineHeight;
    [self p_resizeDocumentView];
    [_messageScrollView.documentView addSubview:view];
}

- (void)p_addMessage:(MessageEntity*)message
{
    [self p_addNameAndTimeTextField:message];
    [self p_addContentViewForMessage:message];
    [self p_addLine];
}

- (void)p_resizeDocumentView
{
    CGFloat bottomGap = 20;
    if (_bottom > [(NSView*)_messageScrollView.documentView bounds].size.height - bottomGap) {
        CGFloat width = self.view.bounds.size.width;
        [_messageScrollView.documentView setFrameSize:NSMakeSize(width, _bottom + bottomGap)];
    }
}

- (void)p_updateButton
{
    if (_currentPage == 1)
    {
        [_lastPageButton setHidden:YES];
        [_moreLastPageButton setHidden:YES];
    }
    else
    {
        [_lastPageButton setHidden:NO];
        [_moreLastPageButton setHidden:NO];
    }
    
    if (_currentPage == _pageCount)
    {
        [_nextPageButton setHidden:YES];
        [_moreNextPageButton setHidden:YES];
    }
    else
    {
        [_nextPageButton setHidden:NO];
        [_moreNextPageButton setHidden:NO];
    }
}
@end
