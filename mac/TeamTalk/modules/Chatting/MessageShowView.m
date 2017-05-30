//
//  MessageShowView.m
//  ScrollViewChatDemo
//
//  Created by 独嘉 on 14-3-17.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "MessageShowView.h"
#import "NSImage+Stretchable.h"
#import "NSTextView+Rect.h"
#import "MessageViewFactory.h"
#import "NSView+Addition.h"
#import <objc/runtime.h>
#import "MTUserEntity.h"
#import "MTUserModule.h"

typedef void(^LoadUserInfoCompletion)(MTUserEntity* user);

static CGFloat const messageGap = 20.0;
static CGFloat const messageContentLeftAndRightGap = 8;
static CGFloat const messageContentUpAndDownGap = 8;
static CGFloat const messageSenderHeight = 20.0;
static CGFloat const messageTimeHeight = 15.0;
static CGFloat const documentBottomGap = 20.0;

static CGFloat const documentBeginY = 30.0;

static CGFloat const avatarLeftGap = 10;
static CGFloat const avatarWidth = 20;

//static int const bubbleLeftAndRightGap = avatarLeftGap + avatarWidth + 5;

static CGFloat const bubbleRightGap = 15;

static void* kNameButtonUserID = @"NameButtonUserIDKey";

@interface MessageShowView(PrivateAPI)

- (NSTextField*)messageTimeTextField:(NSString*)time;
- (NSButton*)senderNameControl:(NSString*)name userID:(NSString*)userID;
- (NSTextField*)hintTextField:(NSString*)hint;
- (NSImageView*)bubbleImageViewWithContentRect:(NSRect)contentRect left:(BOOL)left;
- (void)addMessageSubView:(NSView*)subview;

- (void)clickTheNameButton:(NSButton*)sender;
- (void)selectTheMenuItem:(id)sender;

- (void)setDocumentFrame:(NSSize)size;

- (void)clickTheLoadHistoryButton:(id)sender;
- (void)p_loadUserInfo:(NSString*)userID completion:(LoadUserInfoCompletion)completion;

@end

@implementation MessageShowView
{
    BOOL _documentBeginAddGap;
    NSString* _operationUserID;
    BOOL _loading;
    
    CGFloat _oldDocumentHeight;
    
    //这两个变量存在的原因在DDMessageTextView的委托中
    BOOL _changed;
    CGFloat _changedBoundy;
    
    CGFloat bubbleLeftGap;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [self.documentView setFlipped:YES];
    _documentBeginAddGap = YES;
    _loading = NO;
    [self setDelegate:self];
    bubbleLeftGap = avatarLeftGap + avatarWidth + 5;
    [self needShowNewMsgBtn:NO];
    [[self contentView] setPostsBoundsChangedNotifications: YES];
    [[NSNotificationCenter defaultCenter] addObserver: self
               selector: @selector(boundsDidChangeNotification:)
                   name: NSViewBoundsDidChangeNotification
                 object: [self contentView]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setType:(ChatType)type
{
    switch (type)
    {
        case User:
            bubbleLeftGap = avatarLeftGap + avatarWidth - 15;
            break;
        case Group:
            bubbleLeftGap = avatarLeftGap + avatarWidth + 5;
            break;
        default:
            break;
    }
}

-(void)boundsDidChangeNotification:(NSNotification *) notification
{
   // NSLog(@"%f",self.contentSize);
    
    if ([self isScrollBottom]) {
        [self needShowNewMsgBtn:NO];
    }
}
-(void)needShowNewMsgBtn:(BOOL)isNeed
{
    [self.showNewMsgBtn setHidden:!isNeed];
}

- (void)viewDidMoveToSuperview
{
    if (!_loadHistoryButton)
    {
        _bottom = documentBeginY;
        
        _loadHistoryButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width / 2.0 - 20, 0, 40, 30)];
        [_loadHistoryButton setTitle:@"点击或下拉加载更多消息"];
        [_loadHistoryButton setTarget:self];
        [_loadHistoryButton setAction:@selector(clickTheLoadHistoryButton:)];
        [_loadHistoryButton setButtonType:NSCircularBezelStyle];
        [_loadHistoryButton setBordered:NO];
        [_loadHistoryButton setAutoresizingMask:NSViewWidthSizable];
        
        [self.documentView addSubview:_loadHistoryButton];
    }
}

- (void)loadMessageFinishForCount:(NSInteger)count
{
    DDLog(@"%f",self.contentView.bounds.origin.y);
    [self stopLoading];
    CGFloat documentHeight = [(NSView*)self.documentView bounds].size.height;
    CGFloat addHeight = documentHeight - _oldDocumentHeight;
    [[self documentView] scrollPoint:NSMakePoint(0, addHeight)];
    if (count == 0)
    {
        [_loadHistoryButton setTitle:@"没有历史消息了"];
        [_loadHistoryButton setBordered:NO];
    }
    else
    {
        [_loadHistoryButton setEnabled:YES];
    }
    DDLog(@"%f",self.contentView.bounds.origin.y);

}

#pragma mark - Getter

- (NSMenu*)userOperationMenu
{
    if (_userOperationMenu) {
        return _userOperationMenu;
    }
    
    _userOperationMenu = [[NSMenu alloc] init];
    NSMenuItem *chatMenuItem = [[NSMenuItem alloc] initWithTitle:@"开始聊天" action:@selector(selectTheMenuItem:) keyEquivalent:@""];
    [chatMenuItem setTarget:self];
    [chatMenuItem setTag:Chat];
    [_userOperationMenu addItem:chatMenuItem];
    
    NSMenuItem *viewMenuItem = [[NSMenuItem alloc] initWithTitle:@"查看资料" action:@selector(selectTheMenuItem:) keyEquivalent:@""];
    [viewMenuItem setTarget:self];
    [viewMenuItem setTag:View];
    [_userOperationMenu addItem:viewMenuItem];
    return _userOperationMenu;
}

- (void)viewDidEndLiveResize
{
    [self setDocumentFrame:NSMakeSize(self.bounds.size.width, _bottom + messageGap)];
}

- (void)addMessageViewOnTail:(NSView*)view atLeft:(BOOL)left name:(NSString*)name time:(NSString*)time forceScroll:(BOOL)scroll userID:(NSString *)userID
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.documentView setFlipped:NO];
        CGFloat offSetY = [[self contentView] bounds].origin.y;
        CGFloat height = self.contentView.bounds.size.height;
        BOOL scrollFlag = fabs(offSetY - (_bottom - height)) < 40;
        if ([view isKindOfClass:NSClassFromString(@"DDMessageTextView")])
        {
            [(DDMessageTextView*)view setLoadDelegate:self];
        }
        if ([time length] > 0)
        {
            NSTextField* timeTextField = [self messageTimeTextField:time];
            [self.documentView addSubview:timeTextField];
        }
        
        if ([name length] > 0 && left)
        {
            EGOImageView* avatar = [self senderAvatarUserID:userID];
            [self.documentView addSubview:avatar];
            
            NSString* signString = @"!@#Unknow#@!";
            NSButton* nameButton;
            if ([name hasPrefix:signString])
            {
                nameButton = [self senderNameControl:userID userID:userID];
                [self p_loadUserInfo:userID completion:^(MTUserEntity *user) {
                    [nameButton setTitle:user.name];
                }];
            }else
            {
                nameButton = [self senderNameControl:name userID:userID];
            }
            [self.documentView addSubview:nameButton];
        }
        NSImageView* bubbleImageView = [self bubbleImageViewWithContentRect:view.bounds
                                                                       left:left];
        [self.documentView addSubview:bubbleImageView];
        [view setFrame:NSMakeRect(messageContentLeftAndRightGap, messageContentUpAndDownGap, view.bounds.size.width, view.bounds.size.height)];
        [bubbleImageView addSubview:view];
    [self setDocumentFrame:NSMakeSize(self.bounds.size.width, _bottom + messageGap)];
    if (scrollFlag || scroll)
    {
        [self scrollToDocumentEnd];
    }
        _bottom += messageGap;
}

- (void)addMessageViewOnHead:(NSArray*)views atLefts:(NSArray*)lefts names:(NSArray*)names times:(NSArray*)times userIDs:(NSArray *)userIDs
{
    
    
    CGFloat offSetY = [[self contentView] bounds].origin.y;
    CGFloat height = self.contentView.bounds.size.height;
    BOOL scrollFlag = fabs(offSetY - (_bottom - height)) < 40;
    //隐藏所有老会话
    NSArray* oldSubView = [[self.documentView subviews] copy];
    [oldSubView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSView*)obj setHidden:YES];
    }];
    
    
    //从顶部开始添加历史会话
    CGFloat oldBottom = _bottom;
    _bottom = documentBeginY;
    _documentBeginAddGap = NO;
    for (int index = 0; index < [views count]; index ++)
    {
        NSView* view = views[index];
        BOOL left = [lefts[index] boolValue];
        NSString* name = names[index];
        NSString* time = times[index];
        NSString* userID = userIDs[index];
        [self addMessageViewOnTail:view
                            atLeft:left
                              name:name
                              time:time
                       forceScroll:!left userID:userID];

    }
    [oldSubView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSView* view = (NSView*)obj;
        [view setFrame:NSMakeRect(view.frame.origin.x, view.frame.origin.y + _bottom - documentBeginY, view.bounds.size.width, view.bounds.size.height)];
        [view setHidden:NO];
    }];
    _bottom = oldBottom + _bottom - documentBeginY;
    [self setDocumentFrame:NSMakeSize(self.bounds.size.width, _bottom + messageGap)];
//    [_progressIndicator setFrameOrigin:NSMakePoint(_progressIndicator.frame.origin.x, 0)];
    [_loadHistoryButton setFrameOrigin:NSMakePoint(_loadHistoryButton.frame.origin.x, 0)];
    
    if (scrollFlag)
    {
        [self scrollToDocumentEnd];
    }

}

- (void)addHintWithContent:(NSString*)content
{
    NSTextField* hintTextView = [self hintTextField:content];
    [self.documentView addSubview:hintTextView];
    
    [self scrollToDocumentEnd];
}

- (void)scrollToDocumentEnd
{
//
    CGFloat offSet = _bottom < self.bounds.size.height ? 0 : _bottom - self.bounds.size.height + messageGap;
    [[self contentView] scrollToPoint:NSMakePoint(0, offSet)];
    [self reflectScrolledClipView:[self contentView]];
    [self needShowNewMsgBtn:NO];
}


#pragma mark - NSTextField

#pragma mark - MessageView Delegate
- (void)resetScrollView
{
    _changed = YES;
    _changedBoundy = self.contentView.bounds.origin.y;
}

- (void)messageTextView:(DDMessageTextView*)textView finishLoadAttachAtIndex:(NSUInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{

//        @synchronized(self)
//        {
            CGFloat offSetY = self.contentView.bounds.origin.y;
            
            NSRect contentRect = [MessageViewFactory getContentRectFromMessage:textView.textStorage];

            NSImageView* bubbleImageView = (NSImageView*)[textView superview];
            CGFloat width = contentRect.size.width + messageContentLeftAndRightGap * 2;
            CGFloat height = contentRect.size.height + messageContentUpAndDownGap * 2;

            CGFloat x = 0;
            if (bubbleImageView.frame.origin.x == bubbleLeftGap)
            {
                x = bubbleImageView.frame.origin.x;
            }
            else
            {
                x = self.width - bubbleRightGap - width;
            }
            CGFloat y = bubbleImageView.frame.origin.y;
            
            CGFloat distance = height - bubbleImageView.bounds.size.height;
            NSImage* bubbleImage = [bubbleImageView image];
            bubbleImage = [bubbleImage stretchableImageWithSize:NSMakeSize(width, height) edgeInsets:NSEdgeInsetsMake(10, 10, 10, 10)];
        
            [bubbleImageView setFrame:NSMakeRect(x, y, width, height)];
            [bubbleImageView setImage:bubbleImage];
            [textView setFrame:NSMakeRect(messageContentLeftAndRightGap, messageContentUpAndDownGap, contentRect.size.width, contentRect.size.height)];
            [self subviewsBelow:bubbleImageView.frame.origin.y moveUpOrDown:distance];
            
//            if (scrollFlag)
//            {
//                [self scrollToDocumentEnd];
//            }
       
            if (y < offSetY + self.bounds.size.height)
            {
//                CGFloat scrollOffSetY = offSetY > 0 ? offSetY + distance : _bottom - self.bounds.size.height;
//                [[self contentView] scrollToPoint:NSMakePoint(0, scrollOffSetY)];
//                [self reflectScrolledClipView:[self contentView]];
            }
        
//        }
    });
    
}

#pragma mark - privateAPI
- (void)ptrScrollViewDidTriggerRefresh:(id)sender
{
    [self clickTheLoadHistoryButton:sender];
}


#pragma mark - PrivateAPI
- (NSTextField*)messageTimeTextField:(NSString*)time
{
    CGFloat y = _bottom;
    NSTextField* timeTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, y, self.bounds.size.width, messageTimeHeight)];
    [timeTextField setTextColor:[NSColor grayColor]];
    [timeTextField setAlignment:NSCenterTextAlignment];
    [timeTextField setDrawsBackground:NO];
    [timeTextField setBordered:NO];
    [timeTextField setStringValue:time];
    [timeTextField setEditable:NO];
    [timeTextField setAutoresizingMask:NSViewWidthSizable];
    _bottom = y + messageTimeHeight;
    return timeTextField;
}

- (NSButton*)senderNameControl:(NSString*)name userID:(NSString*)userID
{
    CGFloat y = _bottom;
    NSButton* nameButton = [[NSButton alloc] initWithFrame:NSMakeRect(bubbleLeftGap, y, 55, messageSenderHeight)];
    
    NSMutableAttributedString* titleAttributedString = [[NSMutableAttributedString alloc] initWithString:name];
    [titleAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                  value:(id)[NSColor grayColor].CGColor
                                  range:NSMakeRange(0, [name length])];
    
    [nameButton setAttributedTitle:titleAttributedString];
    [nameButton setBordered:NO];
    [nameButton setTarget:self];
    [nameButton setAction:@selector(clickTheNameButton:)];
    
    objc_setAssociatedObject(nameButton, kNameButtonUserID, userID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    _bottom = y + messageSenderHeight;
    return nameButton;
}

- (EGOImageView*)senderAvatarUserID:(NSString*)userID
{
    CGFloat y = _bottom;
    EGOImageView* imageView = [[EGOImageView alloc] initWithFrame:NSMakeRect(avatarLeftGap, y, avatarWidth, avatarWidth)];
    
    MTUserEntity* user = (MTUserEntity *)[[MTUserModule shareInstance]getOriginEntityWithOriginID:userID];
    NSURL* avatarURL = [NSURL URLWithString:user.avatar];
    
    [imageView loadImageWithURL:avatarURL setplaceholderImage:@"man_placeholder"];
    [imageView setWantsLayer:YES];
    [imageView.layer setCornerRadius:3.0];
    
    return imageView;
}

- (NSTextField*)hintTextField:(NSString*)hint
{
    CGFloat y = _bottom;
    NSTextField* hintTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, y, self.bounds.size.width, messageTimeHeight)];
    [hintTextField setTextColor:[NSColor grayColor]];
    [hintTextField setAlignment:NSCenterTextAlignment];
    [hintTextField setDrawsBackground:NO];
    [hintTextField setBordered:NO];
    [hintTextField setStringValue:hint];
    [hintTextField setEditable:NO];
    [hintTextField setAutoresizingMask:NSViewWidthSizable];
    _bottom = y + messageTimeHeight + messageGap;
    
    [self setDocumentFrame:NSMakeSize(self.bounds.size.width, _bottom + messageGap)];
    return hintTextField;

}

- (NSImageView*)bubbleImageViewWithContentRect:(NSRect)contentRect left:(BOOL)left
{
    CGFloat y;
    if (_documentBeginAddGap)
    {
        y = _bottom == documentBeginY ? messageGap + documentBeginY : _bottom;
    }
    else
    {
        y = _bottom;
    }
    _bottom = y + contentRect.size.height + 2 * messageContentUpAndDownGap;
    
    
    NSImageView* imageView = [[NSImageView alloc] init];
    imageView.autoresizingMask = NSViewNotSizable;
    CGFloat x = left ? bubbleLeftGap : self.bounds.size.width - contentRect.size.width - 2 * messageContentLeftAndRightGap - bubbleRightGap;
    
    NSRect imageRect = NSMakeRect(x, y, contentRect.size.width + 2 * messageContentLeftAndRightGap, contentRect.size.height + 2 * messageContentUpAndDownGap);
    [imageView setFrame:imageRect];

    NSImage* bubbleImage = left ? [NSImage imageNamed:@"bubble_left"] : [NSImage imageNamed:@"bubble_right"];
    bubbleImage = [bubbleImage stretchableImageWithSize:imageRect.size edgeInsets:NSEdgeInsetsMake(10, 10, 10, 10)];
    [imageView setImage:bubbleImage];
    
    imageView.autoresizingMask = left ? NSViewMaxXMargin : NSViewMinXMargin;
    return imageView;
}



- (void)subviewsBelow:(CGFloat)y moveUpOrDown:(CGFloat)distance
{
    _bottom += distance;
    NSRect contentFrame = [[self documentView] frame];
    float height = _bottom > self.contentView.bounds.size.height ? _bottom : self.contentView.bounds.size.height;
    [self setDocumentFrame:NSMakeSize(contentFrame.size.width, height)];
    [[self.documentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSView* view = (NSView*)obj;
        if (view.frame.origin.y > y)
        {
            [view setFrame:NSMakeRect(view.frame.origin.x,
                                      view.frame.origin.y + distance,
                                      view.frame.size.width,
                                      view.frame.size.height)];
        }
    }];
}

- (void)clickTheNameButton:(NSButton*)sender
{
    NSString* userID = objc_getAssociatedObject(sender, kNameButtonUserID);
    _operationUserID = [userID copy];
    //显示菜单
    NSRect rect =  [sender frame];
    NSPoint pt = NSMakePoint(rect.origin.x, rect.origin.y);
    pt = [[sender superview] convertPoint:pt toView:nil];
    pt.y -= sender.bounds.size.height;
    NSInteger winNum = [[sender window] windowNumber];
    
    
    NSEvent *event= [NSEvent mouseEventWithType:NSLeftMouseDown location:pt modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:winNum context:[[sender window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
    
    [NSMenu popUpContextMenu: self.userOperationMenu withEvent:event forView:sender];
}

- (void)selectTheMenuItem:(id)sender
{
    NSMenuItem* menuItem = sender;
    if (self.loadDelegate)
    {
        [self.loadDelegate messageShowView:self selectTheUserID:_operationUserID forOperation:menuItem.tag];
    }
}

- (void)setDocumentFrame:(NSSize)size
{
    if ((self.contentSize.height) < _bottom)
    {
//        CGFloat contentViewBoundY = self.contentView.bounds.origin.y;
        [[self documentView] setFrameSize:size];
//        CGFloat contentViewBoundYasd = self.contentView.bounds.origin.y;
//        [[self contentView] scrollToPoint:NSMakePoint(0, contentViewBoundY)];
//        [self reflectScrolledClipView:[self contentView]];
    }
}

- (void)clickTheLoadHistoryButton:(id)sender
{
    [_loadHistoryButton setEnabled:NO];
    if (self.loadDelegate)
    {
        _oldDocumentHeight = [(NSView*)self.documentView bounds].size.height;
        [self.loadDelegate touchToRefresh];
    }
}

- (void)viewBoundsChanged:(NSNotification*)notification
{
    [super viewBoundsChanged:notification];
    if (_changed)
    {
        _changed = NO;
        [[self contentView] scrollToPoint:NSMakePoint(0, _changedBoundy)];
        [self reflectScrolledClipView:[self contentView]];
    }
}

- (void)p_loadUserInfo:(NSString*)userID completion:(LoadUserInfoCompletion)completion
{
    //tt_3.0
    /*
    DDUserInfoAPI* infoAPI = [[DDUserInfoAPI alloc] init];
    DDUserlistModule* userModule = getDDUserlistModule();
    [infoAPI requestWithObject:@[userID] Completion:^(id response, NSError *error) {
        if (!error)
        {
            NSArray* users = (NSArray*)response;
            MTUserEntity* user = users[0];
            [userModule addUser:user];
            completion(user);
        }
        else
        {
            DDLog(@"error:%@",[error domain]);
            [self p_loadUserInfo:userID completion:completion];
        }
    }];
     */
}

//- (void)viewBoundsChanged:(NSNotification*)notification
//{
//    id contentView = [notification object];
//    if ([contentView isEqual:self.contentView])
//    {
////        DDLog(@"%f",self.contentView.bounds.origin.y);
//        CGFloat contentViewBoundY = self.contentView.bounds.origin.y;
//        CGFloat contentViewBoundHeight = self.contentView.bounds.size.height;
//        CGFloat documentViewBoundHeight = [(NSView*)[self documentView] frame].size.height;
//        if (documentViewBoundHeight - contentViewBoundHeight - contentViewBoundY < documentBeginY)
//        {
//            [_progressIndicator startAnimation:nil];
//            if (!_loading)
//            {
//                _loading = YES;
//                [self.delegate dragTheRefreshIndicator];
//                _refreshOffSet = contentViewBoundY;
//            }
//        }
//        else
//        {
//            if (!_loading)
//            {
//                [_progressIndicator stopAnimation:nil];
//
//            }
//        }
//    }
//}

-(BOOL)isScrollBottom
{
    CGFloat offSetY = [[self contentView] bounds].origin.y;
    CGFloat height = ((NSView *)self.documentView).height;
//    DDLog(@"%f----->",offSetY);
//    DDLog(@"%f<-----",height);
    

    if (offSetY+[[self contentView] bounds].size.height>= height) {
        return YES;
    }
    return NO;
}
-(IBAction)goToBottom:(id)sender
{
    [self scrollToDocumentEnd];
}
@end
