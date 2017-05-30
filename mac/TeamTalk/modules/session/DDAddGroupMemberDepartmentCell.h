//
//  DDAddGroupMemberDepartmentCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-4.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDAddGroupMemberDepartmentCell : NSTableCellView
@property (nonatomic,weak)IBOutlet NSTextField* name;

- (void)setItem:(id)item;

@end
