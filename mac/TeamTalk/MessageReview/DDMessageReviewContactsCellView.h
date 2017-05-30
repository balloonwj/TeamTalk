//
//  DDMessageReviewContactsCellView.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AvatorImageView;
@interface DDMessageReviewContactsCellView : NSTableCellView
{
    __weak IBOutlet AvatorImageView* _avatarImageView;
    __weak IBOutlet NSTextField* _nameTextField;
}

- (void)configWithObject:(id)object;
@end
