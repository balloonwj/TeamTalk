//
//  DDMainWindowController.m
//  Duoduo
//
//  Created by zuoye on 13-11-28.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDMainWindowController.h"
#import "DDGroupViewController.h"
#import "DDRecentContactsViewController.h"
#import "DDSplitView.h"
#import "DDChattingViewController.h"
#import "MessageEntity.h"
#import "MTUserEntity.h"
#import "MTMessageModule.h"
#import "MTSessionEntity.h"
#import "MTSessionModule.h"
#import "DDCommonModule.h"
#import "DDUserInfoManager.h"
#import "DDChattingViewModule.h"
#import "DDSetting+OffLineReadMsgManager.h"
#import "StateMaintenanceManager.h"
#import "DDTcpClientManager.h"
#import "Reachability.h"
#import "DDLoginManager.h"
#import "DDMainWindowControllerModule.h"
#import "MTSessionEntity.h"
#import "MTMessageModule.h"
#import "DDClientState.h"
#import "DDChattingWindowManager.h"
#import "MTGroupModule.h"
#import "MTGroupEntity.h"
#import "NSWindow+Animation.h"
#import "DDGroupInfoManager.h"
#import "MTDatabaseUtil.h"
#import "DDUserPreferences.h"
#import "DDCommonApi.h"
#import "DDGroupMsgReadACKAPI.h"
#import "DDIntranetViewController.h"
#import "DDIntranetEntity.h"
#import "MTUserModule.h"

#define MAIN_WINDOW_NIB	@"DDMainWindow"		//Filename of the login window nib

@interface DDMainWindowController ()

- (void)p_initialFirstColumnViewControllers;

- (void)n_receiveBecomeKeyWindowNotification:(NSNotification*)notification;
- (void)n_receiveMessageNotification:(NSNotification*)notification;
- (void)n_receiveP2PMessageNotification:(NSNotification*)notification;
- (void)n_receiveP2pIntranetNotification:(NSNotification*)notification;

- (void)p_promptNewMessage:(MTMessageEntity*)message;


@end

@implementation DDMainWindowController
{
    BOOL _showSession;
    NSMutableArray* _firstColumnViewControllers;
    
    NSInteger _selectedIndexInLeftBar;
}

+ (instancetype)instance
{
    static DDMainWindowController* g_mainWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_mainWindowController = [[DDMainWindowController alloc] init];
    });
    return g_mainWindowController;
}

-(id)init
{
	if ((self = [super initWithWindowNibName:MAIN_WINDOW_NIB])) {
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveBecomeKeyWindowNotification:) name:NSWindowDidBecomeKeyNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveMessageNotification:) name:DD_MESSAGE_MODULE_RECEIVE_MESSAGE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveP2PMessageNotification:) name:notificationReceiveP2PShakeMessage object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveP2pIntranetNotification:) name:notificationReceiveP2PIntranetMessage object:nil];
        
        [[MTMessageModule shareInstance] addObserver:self
                                          forKeyPath:DD_MESSAGE_UNREAD_COUNT_KEY
                                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                             context:nil];
        
        [[DDClientState shareInstance] addObserver:self
                                        forKeyPath:DD_USER_STATE_KEYPATH
                                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                           context:nil];
        
        [self module];
    }
	return self;
}

- (DDMainWindowControllerModule*)module
{
    if (!_module)
    {
        _module = [[DDMainWindowControllerModule alloc] init];
    }
    return _module;
}

-(void)awakeFromNib{
        
    _showSession = NO;
    [self.window setAlphaValue:0];
    [self.window fadeInAnimation];
}



- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_statusItem setImage:[NSImage imageNamed:@"icon_statusbar"]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(onStatusItemClick)];
    
    [self p_initialFirstColumnViewControllers];
    
    [self.mainSplitView setPosition:100 ofDividerAtIndex:0];
    [_leftBarViewController selectTheItemAtIndex:0];
    _leftBarViewController.delegate = self;
    NSViewController* viewController = _firstColumnViewControllers[0];
    CGFloat width = self.firstColumnView.bounds.size.width;
    CGFloat height = self.firstColumnView.bounds.size.height;
    [viewController.view setFrame:NSMakeRect(0, 0, width, height)];
    [self.firstColumnView addSubview:viewController.view];

}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
}

- (IBAction)pressOnlineStateBtn:(id)sender
{
    NSRect rect =  [sender frame];
    NSPoint pt = NSMakePoint(rect.origin.x, rect.origin.y);
    pt = [[sender superview] convertPoint:pt toView:nil];
    pt.y-=4;
    NSInteger winNum = [[sender window] windowNumber];
    
    
    NSEvent *event= [NSEvent mouseEventWithType:NSLeftMouseDown location:pt modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:winNum context:[[sender window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
    [NSMenu popUpContextMenu: onlineStateMenu withEvent:event forView:sender];
}

#pragma mark openChat

- (void)openUserChatWithUser:(NSString*)userID
{
    MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
    NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:userID sessionType:SessionTypeSessionTypeSingle];
    if (user)
    {
        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
        if (!session)
        {
            session = [[MTSessionEntity alloc] initWithOriginID:user.ID type:SessionTypeSessionTypeSingle];
            [[MTSessionModule shareInstance] addSessions:@[session] saveToDB:YES];
        }
        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
    }
    [self openSessionChatWithSessionID:sessionID];
    
}

- (void)openGroupChatWithGroup:(NSString*)groupID
{
    NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:groupID sessionType:SessionTypeSessionTypeGroup];
    MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
    if (group)
    {
        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
        if (!session)
        {
            session = [[MTSessionEntity alloc] initWithOriginID:groupID type:SessionTypeSessionTypeGroup];
        }
        [[MTSessionModule shareInstance] addSessions:@[session] saveToDB:YES];
        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];

    }
    [self openSessionChatWithSessionID:sessionID];
}

- (void)openSessionChatWithSessionID:(NSString *)sessionID
{
    MTGetSessionLastMsgIDCompletion completion = ^{
        if ([[_chattingBackgroudView subviews] containsObject:[_intranetContentViewController view]])
        {
            [[_intranetContentViewController view] removeFromSuperview];
        }
        
        [MTSessionModule shareInstance].currentChatingSessionID = sessionID;
        if (!_currentChattingViewController)
        {
            _currentChattingViewController = [[DDChattingViewController alloc] initWithNibName:@"DDChattingView" bundle:nil];
            MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
            DDChattingViewModule* chatingModule = [[DDChattingViewModule alloc] initWithSession:session];
            _currentChattingViewController.module = chatingModule;
        }
        [_chattingBackgroudView addSubview:[_currentChattingViewController view]];
        [[_currentChattingViewController view] setFrame:[_chattingBackgroudView bounds]];
        
        if (![_currentChattingViewController.module.session.sessionID isEqualToString:sessionID])
        {
            //打开新会话
            MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
            self.module.currentChatSession = session;
            DDChattingViewModule* chatingModule = [[DDChattingViewModule alloc] initWithSession:session];
            _currentChattingViewController.module = chatingModule;
            [_currentChattingViewController updateUI];
        }
        
        if ([[MTMessageModule shareInstance] getUnreadMessageCountForSessionID:sessionID] > 0)
        {
            //发送消息已读确认
            [[MTSessionModule shareInstance] sendSessionReadACK:sessionID];
            
            //清除此会话的计数
            [[MTMessageModule shareInstance] clearUnreadMessagesForSessionID:sessionID];
        }
    };
    
    completion();
}


- (void)recentContactsSelectObject:(NSString*)sessionID
{
    DDRecentContactsViewController* recentContacts = _firstColumnViewControllers[0];
    [recentContacts selectSession:sessionID];
}

- (void)shakeTheWindow
{
    [self.window beginShakeAnimation];
}

static NSString* const SESSION_ID = @"sessionId";          //群消息到达
-(void)notifyUserNewMsg:(NSString*)sId title:(NSString*)title content:(NSString*)content
{
    if (content)
    {
        NSUserNotificationCenter* notifyCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        
        NSUserNotification* notification = [[NSUserNotification alloc]init];
        
        //标题过滤
        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sId];
        if (session.sessionType == SessionTypeSessionTypeGroup)
        {
            notification.title = [NSString stringWithFormat:@"%@-%@",session.name,title];
        }
        else
        {
            notification.title = session.name;
        }
        
        //内容过滤
        NSError* error = NULL;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"&\\$#@~\\^@\\[\\{:[\\w|\\W]+?:\\}\\]&\\$~@#@"
                                                                               options:0
                                                                                 error:&error];
        NSString* result = [regex stringByReplacingMatchesInString:content
                                                           options:0
                                                             range:NSMakeRange(0, content.length)
                                                      withTemplate:@"[图片]"];
        notification.informativeText = result;
        notification.hasActionButton = YES;
        notification.actionButtonTitle = @"OK";
        notification.otherButtonTitle = @"Cancel";
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:sId forKey:SESSION_ID];
        [notification setUserInfo:userInfo];
        [notifyCenter deliverNotification:notification];
    }
}

- (void)notifyIntranetMessageWithTitle:(NSString*)title content:(NSString*)content
{
    NSUserNotificationCenter* notifyCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    NSUserNotification* notification = [[NSUserNotification alloc]init];
    
    notification.title = title;
    notification.informativeText = content;
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"OK";
    notification.otherButtonTitle = @"Cancel";
    NSDictionary* info = @{@"Intranet" : @(YES)};
    [notification setUserInfo:info];
    [notifyCenter deliverNotification:notification];
}

- (void)leftChangeUseravatar:(NSImage*)image
{
    [_leftBarViewController.avatarImageView setImage:image];
}

#pragma mark 点击了消息通知中心弹出来的面板.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    if(!notification || !notification.userInfo)
        return;
    
    [[self window] makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    NSString* sessionId = [notification.userInfo objectForKey:SESSION_ID];
    if (sessionId)
    {
        DDRecentContactsViewController* recentContactsVC = (DDRecentContactsViewController*)_firstColumnViewControllers[0];
        [recentContactsVC selectSession:sessionId];
        [self openSessionChatWithSessionID:sessionId];
    }
    else
    {
        //内网消息
        [self.leftBarViewController selectTheItemAtIndex:2];
        DDIntranetViewController* intranetViewController = _firstColumnViewControllers[2];
        [intranetViewController selectItemAtIndex:0];
    }

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(void)renderTotalUnreadedCount:(NSUInteger)count
{
    #define MAX_UNREADEDCOUNT_STRING @"99+"
    #define EMPTY_UNREADEDCOUNT_STRING  @""
    
    NSDockTile* title = [[NSApplication sharedApplication] dockTile];

    if (count == 0)
    {
        [_statusItem setImage:[NSImage imageNamed:@"icon_statusbar"]];
    }
    else
    {
        [_statusItem setImage:[NSImage imageNamed:@"icon_statusbar_blue"]];
    }
    
    if(count > 99)
    {
        [_statusItem setTitle:MAX_UNREADEDCOUNT_STRING];
        [title setBadgeLabel:MAX_UNREADEDCOUNT_STRING];
    }
    else if(count > 0)
    {
        [_statusItem setTitle:[NSString stringWithFormat:@"%ld",count]];
        [title setBadgeLabel:[NSString stringWithFormat:@"%ld",count]];
    }
    else
    {
        [_statusItem setTitle:EMPTY_UNREADEDCOUNT_STRING];
        [title setBadgeLabel:EMPTY_UNREADEDCOUNT_STRING];
    }
    
    //左侧Item
//        int unreadIntranetMessage = [messageModule countOfUnreadIntranetMessageForSessionID:@"1szei2"];
//        [_leftBarViewController setMessageCount:unreadIntranetMessage atIndex:2];
    [_leftBarViewController setMessageCount:count atIndex:0];
}


//菜单栏icon点击,打开窗口.
-(void)onStatusItemClick
{
    [[self window] makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];

    MTMessageModule* messageModule = [MTMessageModule shareInstance];
    if ([messageModule getUnreadMessgeCount] > 0)
    {
        
        NSString* toSelectedSession = [messageModule getLastUnreadSessionId ];
        if (toSelectedSession)
        {
            DDRecentContactsViewController* recentContactsVC = (DDRecentContactsViewController*)_firstColumnViewControllers[0];
            [recentContactsVC selectSession:toSelectedSession];
            [self openSessionChatWithSessionID:toSelectedSession];
        }
    }
}

#pragma mark -
#pragma mark - QLPreviewPanelController
- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.dataSource = _currentChattingViewController;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.dataSource = nil;
}

#pragma mark NSSplitView

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0)
    {
        return 230;
    }
    else
    {
        return 570;
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0)
    {
        return 230;
    }
    else
    {
        return 1000;
    }
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    if ([view isEqual:_chattingBackgroudView])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark DDRecentContactsViewContrpller Delegate
- (void)recentContactsViewController:(DDRecentContactsViewController *)viewController selectSession:(NSString *)session
{
    [self openSessionChatWithSessionID:session];
}

#pragma mark DDGroupViewController Delegate
- (void)groupViewController:(DDGroupViewController *)groupVC selectGroup:(MTGroupEntity *)group
{
    [self openGroupChatWithGroup:group.ID];
}

#pragma mark DDIntranetViewController Delegate
- (void)intranetViewController:(DDIntranetViewController *)intranetViewCOntroller selectIntranetEntity:(DDIntranetEntity *)intranet
{
    if ([[_chattingBackgroudView subviews] containsObject:[_currentChattingViewController view]]) {
        [[_currentChattingViewController view] removeFromSuperview ];
    }
    if (!_intranetContentViewController)
    {
        _intranetContentViewController = [[DDIntranetContentViewController alloc] initWithNibName:@"DDIntranetContentViewController" bundle:nil];
        [_intranetContentViewController.view setFrame:_chattingBackgroudView.bounds];
    }
    [_intranetContentViewController setIntranetEntity:intranet];
    [_intranetContentViewController.webView setMainFrameURL:intranet.itemURL];
    [[_intranetContentViewController view] setFrame:[_chattingBackgroudView bounds]];
    [_chattingBackgroudView addSubview:_intranetContentViewController.view];
}

#pragma mark - DDLeftBarViewControllerDelegate
- (void)selectedItemIndex:(NSInteger)index
{
    _selectedIndexInLeftBar = index;
    NSMutableArray* toRemoveSubView = [NSMutableArray arrayWithArray:self.firstColumnView.subviews];
    [toRemoveSubView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSView*)obj removeFromSuperview];
    }];
    NSViewController* viewController = _firstColumnViewControllers[index];
    [viewController.view setFrame:NSMakeRect(0, 0, self.firstColumnView.bounds.size.width, self.firstColumnView.bounds.size.height)];
    [self.firstColumnView addSubview:viewController.view];
    
    NSString* lastSessionID =[[MTMessageModule shareInstance] getLastUnreadSessionId];
    //[MTSessionModule shareInstance].currentChatingSessionID;
    if (index == 0)
    {
        //选中最近联系人
        if (lastSessionID)
        {
            DDRecentContactsViewController* recentContactsVC = _firstColumnViewControllers[0];
            [recentContactsVC selectSession:lastSessionID];
            [self openSessionChatWithSessionID:lastSessionID];
        }
        else
        {
            NSString* firstSessionID = [MTSessionModule shareInstance].sessions[0];
            DDRecentContactsViewController* recentContactsVC = _firstColumnViewControllers[0];
            [recentContactsVC selectSession:firstSessionID];
            [self openSessionChatWithSessionID:firstSessionID];
        }
    }
    else if (index == 1)
    {
        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:lastSessionID];
        if (session.sessionType == SessionTypeSessionTypeGroup)
        {
            NSString* groupID = session.originID;
            MTGroupEntity* groupEntity = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
            if (groupEntity.groupType == DDNormalGroupType)
            {
                DDGroupViewController* groupVC = _firstColumnViewControllers[1];
                [groupVC selectGroup:groupEntity];
                return;
            }
        }
        //选中第一行
        DDGroupViewController* groupVC = _firstColumnViewControllers[1];
        
        if ([groupVC.module.groups count] > 0)
        {
            [groupVC selectRow:0];
            [groupVC selectGroup:groupVC.module.groups[0]];
        }
    }
    else if (index == 2)
    {
        //打开内网
        DDIntranetViewController* intranetVC = _firstColumnViewControllers[2];
        [intranetVC selectItemAtIndex:0];
    }
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_MESSAGE_UNREAD_COUNT_KEY])
    {
        NSUInteger count = [[MTMessageModule shareInstance] getUnreadMessgeCount];
        
        //she
        [self renderTotalUnreadedCount:count];
    }
    else if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH])
    {
        NSString* info = nil;
        switch ([DDClientState shareInstance].userState)
        {
            case DDUserKickout:
                info = @"您的账号在另一地点登陆，您被迫下线";
                break;
            case DDUserKickByMobile:
                info = @"您已被移动端提出登录,您被迫下线";
                break;
            default:
                break;
        }
        if (info)
        {
            [[DDAlertWindowController  defaultControler] showAlertWindow:[self window] title:@"下线通知" info:info leftBtnName:@"" midBtnName:@"" rightBtnName:@"确定"];
        }
    }
}

#pragma mark Private API
- (void)mainWindowBecomeAlive:(NSNotification*)notification
{

    //TT_3.0
    /*
    NSString* sessionID = sessionModule.chatingSessionID;
    if ([messageModule countMessageBySessionId:sessionID] > 0)
    {
//        [self selectTheSessionSegment:nil];
        [self openChatViewByUserId:sessionID];
        DDRecentContactsViewController* recentContactsVC = _firstColumnViewControllers[0];
        [recentContactsVC selectSession:sessionID];
    }
     */
}

- (void)p_initialFirstColumnViewControllers
{
    _firstColumnViewControllers = [[NSMutableArray alloc] init];
    DDRecentContactsViewController* recentContactsViewController = [[DDRecentContactsViewController alloc] initWithNibName:@"DDRecentContactsViewController" bundle:nil];
    [recentContactsViewController initialData];
    [recentContactsViewController setDelegate:self];
    [_firstColumnViewControllers addObject:recentContactsViewController];
    
    DDGroupViewController* groupViewController = [[DDGroupViewController alloc] initWithNibName:@"DDGroupViewController" bundle:nil];
    [groupViewController setDelegate:self];
    [_firstColumnViewControllers addObject:groupViewController];
    
    DDIntranetViewController* intranetViewController = [[DDIntranetViewController alloc] initWithNibName:@"DDIntranentViewController" bundle:nil];
    [intranetViewController setDelegate:self];
    [_firstColumnViewControllers addObject:intranetViewController];
}

- (void)n_receiveBecomeKeyWindowNotification:(NSNotification*)notification
{
    
    NSWindow* window = [notification object];
    if([window isEqual:self.window])
    {
        NSString* sessionID = [[MTSessionModule shareInstance] currentChatingSessionID];
        if (sessionID)
        {
            MTMessageModule* messageModule = [MTMessageModule shareInstance];
            if([messageModule getUnreadMessageCountForSessionID:sessionID] > 0)
            {
                [self openSessionChatWithSessionID:sessionID];
            }
            DDRecentContactsViewController* recentContactsVC = _firstColumnViewControllers[0];
            [recentContactsVC selectSession:sessionID];
            
        }
    }
}

- (void)n_receiveMessageNotification:(NSNotification*)notification
{
    MTMessageEntity* message = [notification object];
    if([[MTSessionModule shareInstance].currentChatingSessionID isEqualToString:message.sessionID] && [[NSApplication sharedApplication] isActive]){
        
        
    }else
    {
        if (![[[DDSetting instance]getShieldSessionIDs] containsObject:message.sessionID])
        {
            [self p_promptNewMessage:message];
        }
    }
    //tt_3.0
    /*
    DDMessageModule* moduleMsg = getDDMessageModule();
    if([moduleMsg countMessageBySessionId:sessionId] < 1)
        return;
    if ([sessionId isEqualToString:_lastSessionID] && [[NSApplication sharedApplication] isActive] && [self.window isKeyWindow])     //当前焦点项
    {
        MessageEntity* msg = [moduleMsg popMessage:sessionId];
        [currentChattingViewController addMessageToChatContentView:msg isHistoryMsg:NO showtime:kIgnore showName:kIgnoreThis];
        DDSessionModule* moduleSess = getDDSessionModule();
        SessionEntity* session = [moduleSess getSessionBySId:sessionId];
        [[DDDatabaseUtil instance] insertMessage:msg
                                         success:^{
                                             
                                             [moduleSess tcpSendReadedAck:session];
                                         } failure:^(NSString *errorDescripe) {
                                             
                                         }];
        DDLog(@"***************************************************************");
    }
    else
    {
        //不是当前列,要显示未读消息.
        [self p_promptNewMessage:message];
    }
     */
}

- (void)n_receiveP2PMessageNotification:(NSNotification*)notification
{


    NSDictionary* dic = [notification object];
    NSDictionary* contentDic = dic[@"content"];
    if (!contentDic)
    {
        return;
    }

    NSString* fromUserId = dic[@"fromUserID"];

    MTUserEntity* user =(MTUserEntity *)[[MTUserModule shareInstance]getOriginEntityWithOriginID:fromUserId];
    
    NSString* content = contentDic[@"content"];
    if ([content isEqualToString:@"shakewindow"])
    {
        [self notifyUserNewMsg:fromUserId title:user.name content:@"向你发送了一个抖动"];
        [NSApp activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:nil];
        [self.window beginShakeAnimation];
        
        //
        MTSessionModule* sessionModule = [MTSessionModule shareInstance];
        MTSessionEntity* session = [sessionModule getSessionBySessionID:fromUserId];
        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];

        //tt_3.0 更新最新联系人.
       // [NotificationHelp postNotification:notificationReloadTheRecentContacts userInfo:nil object:nil];
    }

}

- (void)n_receiveP2pIntranetNotification:(NSNotification*)notification
{
    NSDictionary* dic = [notification object];
    NSDictionary* content = dic[@"content"];
    if ([[DDUserPreferences defaultInstance] playNewMesageSound]) {
        [DDCommonApi playSound:@"message.wav"];
    }
    if ([[DDUserPreferences defaultInstance] showBubbleHint])
    {
        NSUserNotificationCenter* notifyCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        //如果缓存命中，则先remove掉    {
        //        [notifyCenter removeDeliveredNotification:cachedNotification];
        NSUserNotification* userNotification = [[NSUserNotification alloc]init];
        
        //内容过滤
        userNotification.title = [NSString stringWithFormat:@"内网 - %@",content[@"Author"]];
        userNotification.informativeText = content[@"Content"];
        userNotification.hasActionButton = YES;
        userNotification.actionButtonTitle = @"OK";
        userNotification.otherButtonTitle = @"Cancel";
        [userNotification setUserInfo:dic];
        [notifyCenter deliverNotification:userNotification];
    }
}

- (void)p_promptNewMessage:(MTMessageEntity*)message
{
    if(message && [[DDUserPreferences defaultInstance] showBubbleHint])
    {
        NSString* senderID = message.senderID;

        //自己就不弹了.
        if ([senderID isEqualToString:[[DDClientState shareInstance] userID]]) {
            return;
        }
        
        MTUserEntity* user = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:senderID];
        if (user)
        {
            if ([[DDUserPreferences defaultInstance] playNewMesageSound]) {
                [DDCommonApi playSound:@"message.wav"];
            }
            NSString* messageContent = nil;
            if (message.messageType == MessageTypeVoice)
            {
                messageContent = @"语音";
            }
            else
            {
                messageContent = message.messageContent;
            }
            [self notifyUserNewMsg:message.sessionID title:user.name content:messageContent];
        }
    }
}
- (IBAction)showMyInfo:(id)sender
{
    
    NSString *myUserId = [[DDClientState shareInstance] userID];
    MTUserEntity* showUser = (MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:myUserId];
    [[DDUserInfoManager instance] showUser:showUser forContext:self];
}

@end
