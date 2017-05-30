//
//  DDSearchResultCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AvatorImageView;
@interface DDSearchResultCell : NSTableCellView
{
    __weak IBOutlet AvatorImageView* avatarImageView;
    __weak IBOutlet NSTextField* nameTextField;
}

- (void)configeWithObject:(id)object;
@end
