//
//  DDMainWindowController.h
//  Duoduo
//
//  Created by zuoye on 13-11-28.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDWindowController.h"
#import "EGOImageView.h"
#import "FMSearchTokenField.h"
#import "DDSearchFieldEditorDelegate.h"
#import "DDLeftBarViewController.h"
#import "DDRecentContactsViewController.h"
#import "DDGroupViewController.h"
#import "DDIntranetViewController.h"
#import "DDIntranetContentViewController.h"
@class DDLeftBarViewController;
@class DDSplitView;
@class DDChattingViewController,DDMainWindowControllerModule;

@interface DDMainWindowController : DDWindowController<
                                                    NSUserNotificationCenterDelegate,
                                                    NSSplitViewDelegate,
                                                    DDLeftBarViewControllerDelegate,
                                                    DDRecentContactsViewControllerDelegate,
                                                    DDGroupViewControllerDelegate,
                                                    DDIntranetViewControllerDelegate>{
    DDChattingViewController *_currentChattingViewController;
    DDIntranetContentViewController* _intranetContentViewController;
                                                
    NSStatusItem* _statusItem;                       //状态栏图标
    NSMenu *onlineStateMenu; 
    NSInteger preOnlineMenuTag;
}

@property (nonatomic,weak) IBOutlet DDLeftBarViewController* leftBarViewController;
@property (nonatomic,strong)DDMainWindowControllerModule* module;

@property (nonatomic,weak) IBOutlet NSView *firstColumnView;
@property (nonatomic,weak) IBOutlet DDSplitView *mainSplitView;
@property (nonatomic,weak) IBOutlet NSView *chattingBackgroudView;

@property (nonatomic,weak) IBOutlet FMSearchTokenField *searchField;
@property (nonatomic,strong) IBOutlet DDSearchFieldEditorDelegate *searchFieldDelegate;
+ (instancetype)instance;

- (IBAction)showMyInfo:(id)sender;

/**
 *  开始一个和用户的聊天会话，如果会话不存在会建立新的会话，并且刷新界面
 *
 *  @param userID 用户ID
 */
- (void)openUserChatWithUser:(NSString*)userID;

/**
 *  开始一个和群的聊天会话，如果会话不存在会简历新的会话，并且刷新界面
 *
 *  @param groupID 群ID
 */
- (void)openGroupChatWithGroup:(NSString*)groupID;

/**
 *  开始一个已存在的会话
 *
 *  @param sessionID 会话ID
 */
- (void)openSessionChatWithSessionID:(NSString*)sessionID;

-(void)notifyUserNewMsg:(NSString*)sid title:(NSString*)title content:(NSString*)content;

- (void)notifyIntranetMessageWithTitle:(NSString*)title content:(NSString*)content;

-(void)renderTotalUnreadedCount:(NSUInteger)count;

- (void)recentContactsSelectObject:(NSString*)sessionID;

- (void)shakeTheWindow;

- (void)leftChangeUseravatar:(NSImage*)image;
@end
