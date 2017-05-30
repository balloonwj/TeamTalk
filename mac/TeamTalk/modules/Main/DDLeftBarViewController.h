//
//  DDLeftBarViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDLeftBarItem.h"
@protocol DDLeftBarViewControllerDelegate<NSObject>

- (void)selectedItemIndex:(NSInteger)index;

@end
@interface DDLeftBarViewController : NSViewController<DDLeftBarItemDelegate>
{
    __weak IBOutlet NSMenu *onlineStateMenu;
    __weak IBOutlet NSMenu *settingMenu;
}
@property (nonatomic,assign)IBOutlet id<DDLeftBarViewControllerDelegate> delegate;
@property (nonatomic,weak)IBOutlet EGOImageView* avatarImageView;
@property (nonatomic,weak)IBOutlet NSButton* stateButton;
@property (nonatomic,weak)IBOutlet NSButton* settionButton;
@property (nonatomic,assign,readonly)BOOL observerDataSate;


- (void)selectTheItemAtIndex:(NSInteger)index;

- (void)setMessageCount:(NSInteger)count atIndex:(NSInteger)index;

@end
