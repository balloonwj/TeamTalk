//
//  DDMessageReviewWindowController.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageReviewContactsViewController.h"
@class DDMessageReviewModule,DDMessageReviewContactsViewController,DDMessagesReviewContentViewController;
@interface DDMessageReviewWindowController : NSWindowController<DDMessageReviewContactsViewControllerDelegate,NSSplitViewDelegate>
{
    __weak IBOutlet NSSplitView* _splitView;
    __weak IBOutlet NSSearchField* _searchTextField;

}
@property (nonatomic,strong)DDMessageReviewModule* module;
@property (nonatomic,strong)IBOutlet DDMessageReviewContactsViewController* contactsViewController;
@property (nonatomic,strong)IBOutlet DDMessagesReviewContentViewController* contentViewController;

+ (instancetype)instance;

@end
