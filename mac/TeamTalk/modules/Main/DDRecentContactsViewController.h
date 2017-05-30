//
//  DDRecentContactsViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDSearchViewController.h"

#define DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION             @"DDRecentContactsViewReloadNotification"

@class DDRecentContactsViewController,SessionEntity,DDSearchViewController;
@protocol DDRecentContactsViewControllerDelegate <NSObject>

- (void)recentContactsViewController:(DDRecentContactsViewController*)viewController selectSession:(NSString*)session;

@end

@class SessionEntity,DDRecentContactsModule;
@interface DDRecentContactsViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSMenuDelegate,DDSearchViewControllerDelegate>
@property (nonatomic,assign)id<DDRecentContactsViewControllerDelegate> delegate;
@property (nonatomic,weak)IBOutlet NSSearchField* searchField;
@property (nonatomic,weak)IBOutlet NSTableView* tableView;
@property (nonatomic,weak)IBOutlet DDSearchViewController* searchViewController;
@property (nonatomic,retain)DDRecentContactsModule* module;
@property (nonatomic,weak)IBOutlet NSClipView* clipView;
@property (nonatomic,strong)NSPopover *popover;
@property (nonatomic,assign)int isShowPop;
@property (strong) IBOutlet NSMenu *menu;

- (void)selectSession:(NSString*)session;

- (void)updateData;

- (void)initialData;

@end
