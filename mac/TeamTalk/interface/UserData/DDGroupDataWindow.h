//
//  DDGroupDataWindow.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDGroupDataModule.h"
#import "DDGroupInfoCell.h"
@class DDUserDataWindowController;
@interface DDGroupDataWindow : NSWindowController<NSTableViewDataSource,NSTableViewDelegate,DDGroupInfoCellDelegate>
{
    IBOutlet NSTableView* _usersDataTableView;
    IBOutlet NSTextField* _titleTextField;
    DDUserDataWindowController* _userDataWindowController;
}
@property (nonatomic,retain)DDGroupDataModule* module;
@end
