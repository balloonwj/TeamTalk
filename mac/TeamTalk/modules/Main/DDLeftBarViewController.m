//
//  DDLeftBarViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLeftBarViewController.h"
#import "DDLeftBarItem.h"
#import <QuartzCore/QuartzCore.h>
#import "MTUserEntity.h"
#import "StateMaintenanceManager.h"
#import "DDClientState.h"
#import "DDLoginManager.h"
#import "DDTcpClientManager.h"
#import "DDPreferenceWinController.h"
#import "DDMessageReviewWindowController.h"
#import "StateMaintenanceManager.h"
#import "MTMessageModule.h"
static CGFloat const itemUpGap = 200;
@interface DDLeftBarViewController ()

- (void)p_initialItems;
- (void)p_layoutItems;
- (void)p_initialItemSelectedBackgroundImageView;
- (void)p_selectedItemBackgroundMoveToIndex:(NSInteger)index;
- (void)p_updateMyOnlieState:(uint32)state;
- (void)n_receiveTcpLinkDisconnectNotification:(NSNotification*)notification;
- (void)n_receiveUserLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveP2PIntranetMessageNotification:(NSNotification*)notification;
- (void)n_receiveMessageNotification:(NSNotification*)notification;
@end

@implementation DDLeftBarViewController
{
    NSMutableArray* _items;
    NSImageView* _selectedImageBackground;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _observerDataSate=NO;
        
    }
    return self;
}

- (void)awakeFromNib{
    
    _items = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveTcpLinkDisconnectNotification:) name:notificationTcpLinkDisconnect object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserLoginSuccessNotification:) name:notificationUserLoginSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveMessageNotification:) name:notificationReceiveMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveP2PIntranetMessageNotification:) name:notificationReceiveP2PIntranetMessage object:nil];
    
    [self p_initialItemSelectedBackgroundImageView];
    [self p_initialItems];
    
    [_avatarImageView setWantsLayer:YES];
    [_avatarImageView.layer setCornerRadius:_avatarImageView.bounds.size.width / 2.0];
    
    _observerDataSate = YES;
   
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_USER_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
    
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_NETWORK_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}


- (void)dealloc
{
    if(_observerDataSate){
        [[DDClientState shareInstance] removeObserver:self forKeyPath:DD_USER_STATE_KEYPATH];
        [[DDClientState shareInstance] removeObserver:self forKeyPath:DD_NETWORK_STATE_KEYPATH];
    }
}

#pragma mark -
#pragma mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH]) {
        switch ([DDClientState shareInstance].userState)
        {
            case DDUserKickout:
            case DDUserKickByMobile:
                [self p_updateMyOnlieState:UserStatTypeUserStatusOffline];
                break;
            case DDUserOffLine:
                [self p_updateMyOnlieState:UserStatTypeUserStatusOffline];
                break;
            case DDUserOffLineInitiative:
                [self p_updateMyOnlieState:UserStatTypeUserStatusOffline];
                break;
            case DDUserOnline:
                [self p_updateMyOnlieState:UserStatTypeUserStatusOnline];
                break;
            case DDUserLogining:
                break;
        }
    }
    else if ([keyPath isEqualToString:DD_NETWORK_STATE_KEYPATH])
    {
        if ([DDClientState shareInstance].networkState == DDNetWorkDisconnect)
        {
            //网络断开
            [self p_updateMyOnlieState:UserStatTypeUserStatusOffline];
        }
    }
}

#pragma mark public
- (void)selectTheItemAtIndex:(NSInteger)index
{
    [self p_selectedItemBackgroundMoveToIndex:index];
    [self selectedItem:_items[index]];
}

- (void)setMessageCount:(NSInteger)count atIndex:(NSInteger)index
{
    if ([_items count] > index)
    {
        DDLeftBarItem* item = _items[index];
        [item hasUnreadMessage:count];
    }
}

- (IBAction)showOnlineChangedMenu:(id)sender
{
    NSRect rect =  [sender frame];
    NSPoint pt = NSMakePoint(rect.origin.x, rect.origin.y);
    pt = [[sender superview] convertPoint:pt toView:nil];
    pt.y-=4;
    pt.x -= 34;
    NSInteger winNum = [[sender window] windowNumber];
    
    
    NSEvent *event= [NSEvent mouseEventWithType:NSLeftMouseDown location:pt modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:winNum context:[[sender window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
    [NSMenu popUpContextMenu:onlineStateMenu withEvent:event forView:sender];
}

- (IBAction)showSettingMenu:(id)sender
{
    NSRect rect =  [sender frame];
    NSPoint pt = NSMakePoint(rect.origin.x, rect.origin.y);
    pt = [[sender superview] convertPoint:pt toView:nil];
    pt.y-=4;
    pt.x -= 34;
    NSInteger winNum = [[sender window] windowNumber];
    
    
    NSEvent *event= [NSEvent mouseEventWithType:NSLeftMouseDown location:pt modifierFlags:NSLeftMouseDownMask timestamp:0 windowNumber:winNum context:[[sender window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
    [NSMenu popUpContextMenu:settingMenu withEvent:event forView:sender];
}

- (IBAction)showPerferenceSetting:(id)sender
{
    [[DDPreferenceWinController instance] showWindow:self];
}

- (IBAction)showMessageManagerView:(id)sender
{
    [[DDMessageReviewWindowController instance] showWindow:self];
}

- (IBAction)showFileManagerView:(id)sender
{
    //TODO：文件传输面板
}

-(IBAction)changeOnlineState:(NSMenuItem *)sender{
    NSInteger tag = sender.tag;

    
    //需要查询自己的用户状态.
    ;
    
    UserStatType state = [[StateMaintenanceManager instance] getUserStateForUserID:[[DDClientState shareInstance]userID]];
    if (state == tag)
        return;
    
    if (tag==UserStatTypeUserStatusOnline)
    {
        if(UserStatTypeUserStatusOffline == state)
        {
            [[DDLoginManager instance] reloginSuccess:^{
                DDLog(@"relogin success");
                [[DDClientState shareInstance] setUserState:DDUserOffLine];
                [self p_updateMyOnlieState:UserStatTypeUserStatusOnline];
            } failure:^(NSString *error) {
                DDLog(@"relogin failure:%@",error);
            }];
            
            
//            DDClientState* clientState = [DDClientState instance];
//            clientState.userInitiativeOffline = NO;
//            clientState.kickout = NO;
//            [[DDLoginManager instance] reloginSuccess:^{
//                clientState.online = YES;
//                [NotificationHelp postNotification:notificationUserReloginSuccess userInfo:nil object:nil];
//            } failure:^(NSString *error) {
//                
//            }];
            
        }
        else if(UserStatTypeUserStatusLeave == state)
        {
//            [[DDLogic instance] pushTaskWithBlock:
//             ^()
//             {
//                 NSMutableData *data = [TcpProtocolPack getSetUserOnlineState:tag];
//                 [[DDTcpClientManager instance] writeToSocket:data];
//             }];
//            [stateMaintenanceManager changeMyOnlineState:USER_STATUS_ONLINE];
//            [self p_updateMyOnlieState:USER_STATUS_ONLINE];
        }
    }
    else if(tag==UserStatTypeUserStatusLeave)
    {
        if(UserStatTypeUserStatusOffline == state)
        {
//            DDClientState* clientState = [DDClientState instance];
//            clientState.userInitiativeOffline = NO;
//            clientState.kickout = NO;
//            [[DDLoginManager instance] reloginSuccess:^{
//                [NotificationHelp postNotification:notificationUserReloginSuccess userInfo:nil object:nil];
//            } failure:^(NSString *error) {
//                
//            }];
        }
        else if(UserStatTypeUserStatusOnline == state)
        {
//            [[DDLogic instance] pushTaskWithBlock:
//             ^()
//             {
//                 NSMutableData *data = [TcpProtocolPack getSetUserOnlineState:tag];
//                 [[DDTcpClientManager instance] writeToSocket:data];
//             }];
//            [stateMaintenanceManager changeMyOnlineState:USER_STATUS_LEAVE];
//            [self p_updateMyOnlieState:USER_STATUS_LEAVE];
        }
    }
    else if(tag==UserStatTypeUserStatusOffline)
    {
        //断开连接.
        [[DDClientState shareInstance] setUserState:DDUserOffLineInitiative];
        [self p_updateMyOnlieState:UserStatTypeUserStatusOffline];
    }
}

#pragma mark IBAction
- (IBAction)showPreferenceWindow:(id)sender
{
    [[DDPreferenceWinController instance] showWindow:self];
}

#pragma mark DDLeftItem Delegate
- (void)selectedItem:(DDLeftBarItem *)item
{
    NSInteger tag = item.tag;
    [self p_selectedItemBackgroundMoveToIndex:tag];
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDLeftBarItem* item = (DDLeftBarItem*)obj;
        if (item.tag != tag)
        {
            [item setSelected:NO];
        }
        else
        {
            [item setSelected:YES];
        }
    }];
    [self.delegate selectedItemIndex:tag];
}

#pragma mark privateAPI
- (void)p_initialItems
{
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
    NSImage* recentChatImageSelected = [NSImage imageNamed:@"recent-chat-selected"];
    NSImage* recentChatImageUnselected = [NSImage imageNamed:@"recent-chat-unselected"];
    DDLeftBarItem* recentChat = [[DDLeftBarItem alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)
                                                       selectedImage:recentChatImageSelected
                                                     unSelectedImage:recentChatImageUnselected tag:0];
    recentChat.delegate = self;
    [_items addObject:recentChat];
    [recentChat setAutoresizingMask:NSViewMinYMargin];
    
    NSImage* groupImageSelected = [NSImage imageNamed:@"group-selected"];
    NSImage* groupImageUnselected = [NSImage imageNamed:@"group-unselected"];
    DDLeftBarItem* group = [[DDLeftBarItem alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)
                                                  selectedImage:groupImageSelected
                                                unSelectedImage:groupImageUnselected
                                                            tag:1];
    group.delegate = self;
    [_items addObject:group];
    [group setAutoresizingMask:NSViewMinYMargin];
    
    NSImage* intranentImageSelected = [NSImage imageNamed:@"intranet_selected"];
    NSImage* intranentImageUnselected = [NSImage imageNamed:@"Intranet_unselected"];
    DDLeftBarItem* intranent = [[DDLeftBarItem alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height) selectedImage:intranentImageSelected unSelectedImage:intranentImageUnselected tag:2];
    intranent.delegate = self;
    [_items addObject:intranent];
    [intranent setAutoresizingMask:NSViewMinYMargin];
    
    [self p_layoutItems];
}

- (void)p_layoutItems
{
    CGFloat itemStartY = self.view.bounds.size.height - itemUpGap;
    for (NSInteger index = 0; index < [_items count]; index ++)
    {
        DDLeftBarItem* item = _items[index];
        CGSize size = item.bounds.size;
        CGFloat y = itemStartY - index * size.height;
        [item setFrame:NSMakeRect(0, y, size.width, size.height)];
        [self.view addSubview:item];
    }
}

- (void)p_initialItemSelectedBackgroundImageView
{
    _selectedImageBackground = [[NSImageView alloc] init];
    NSImage* image = [NSImage imageNamed:@"left-bar-selected-background"];
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
    CGFloat itemStartY = self.view.bounds.size.height - itemUpGap;
    [_selectedImageBackground setFrame:NSMakeRect(0, itemStartY, size.width, size.height)];
    [_selectedImageBackground setImage:image];
    [_selectedImageBackground setAutoresizingMask:NSViewMinYMargin];
    
    [self.view addSubview:_selectedImageBackground positioned:NSWindowBelow relativeTo:nil];
    
}

- (void)p_selectedItemBackgroundMoveToIndex:(NSInteger)index
{
    CGFloat itemStartY = self.view.bounds.size.height - itemUpGap;

    NSViewAnimation *theAnim;
    NSRect firstViewFrame;
    NSRect newViewFrame;
    NSMutableDictionary* firstViewDict;
    

        // Create the attributes dictionary for the first view.
        firstViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
        firstViewFrame = [_selectedImageBackground frame];
        
        // Specify which view to modify.
        [firstViewDict setObject:_selectedImageBackground forKey:NSViewAnimationTargetKey];
        
        // Specify the starting position of the view.
        [firstViewDict setObject:[NSValue valueWithRect:firstViewFrame]
                          forKey:NSViewAnimationStartFrameKey];
        
        // Change the ending position of the view.
        newViewFrame = firstViewFrame;
        CGFloat y = itemStartY - index * _selectedImageBackground.bounds.size.height;

        newViewFrame.origin.x = 0;
        newViewFrame.origin.y = y;
        [firstViewDict setObject:[NSValue valueWithRect:newViewFrame]
                          forKey:NSViewAnimationEndFrameKey];
    
    // Create the view animation object.
    theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
                                                               arrayWithObjects:firstViewDict, nil]];
    
    // Set some additional attributes for the animation.
    [theAnim setDuration:0];    // One and a half seconds.
    [theAnim setAnimationCurve:NSAnimationEaseIn];
    
    // Run the animation.
    [theAnim startAnimation];
    
    // The animation has finished, so go ahead and release it.
}

- (void)n_receiveTcpLinkDisconnectNotification:(NSNotification*)notification
{
//    [self p_updateMyOnlieState:USER_STATUS_OFFLINE];
//    
//    [[StateMaintenanceManager instance] changeMyOnlineState:USER_STATUS_OFFLINE];
}

-(void)p_updateMyOnlieState:(uint32)state
{
    NSImage *icon;
    switch (state)
    {
        case UserStatTypeUserStatusOnline:
            icon = [NSImage imageNamed:@"state-online"];
            break;
        case UserStatTypeUserStatusOffline:
            icon = [NSImage imageNamed:@"state-offline"];
            break;
        case UserStatTypeUserStatusLeave:
            icon = [NSImage imageNamed:@"state-leave"];
            break;
    }
    
    [self.stateButton setImage:icon];
}


- (void)n_receiveUserLoginSuccessNotification:(NSNotification*)notification
{
    [self p_updateMyOnlieState:UserStatTypeUserStatusOnline];
    
    MTUserEntity* user = [notification object];
    NSString* avatar = user.avatar;
    NSURL* avatarURL = [NSURL URLWithString:avatar];
    [_avatarImageView loadImageWithURL:avatarURL setplaceholderImage:@"man_placeholder"];
    
}

- (void)n_receiveP2PIntranetMessageNotification:(NSNotification*)notification
{
    
}

- (void)n_receiveMessageNotification:(NSNotification*)notification
{
   // DDLeftBarItem* firstItem = _items[0];
    //[firstItem hasUnreadMessage:YES];
}

@end
