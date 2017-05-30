//
//  DDMessageReviewContactsViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DDMessageReviewContactsViewController;
@protocol DDMessageReviewContactsViewControllerDelegate<NSObject>

- (void)contactsViewController:(DDMessageReviewContactsViewController*)viewController selectObject:(id)object;

@end
@interface DDMessageReviewContactsViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>
{
    __weak IBOutlet NSTableView* _tableView;
}
@property (nonatomic,assign)IBOutlet id<DDMessageReviewContactsViewControllerDelegate> delegate;
- (void)updateContacts:(NSArray*)contacts;

- (id)selectedContact;
@end
