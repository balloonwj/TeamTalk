//
//  DDRecentContactsCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AvatorImageView,MTSessionEntity;
@interface DDRecentContactsCell : NSTableCellView
{
    __weak IBOutlet NSTextField* nameTextField;
    __weak IBOutlet NSImageView* topIconImageView;
    __weak IBOutlet NSImageView* shieldIconImageView;
    __weak IBOutlet NSTextField* unreadMessageLabel;
    __weak IBOutlet NSImageView* unreadMessageBackground;
}
@property(nonatomic,strong)NSColor *tempColor;
-(void)clearUnreadCount;
- (void)configeCellWithObject:(MTSessionEntity*)object;

- (void)setTopIconHidden:(BOOL)hidden;
@end
