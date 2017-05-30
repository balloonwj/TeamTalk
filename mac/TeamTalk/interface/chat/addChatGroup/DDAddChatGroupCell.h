//
//  DDAddChatGroupCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AvatorImageView;
@interface DDAddChatGroupCell : NSTableCellView
@property (nonatomic,weak)IBOutlet AvatorImageView* avatar;
@property (nonatomic,weak)IBOutlet NSTextField* name;

- (void)setItem:(id)item;
@end
