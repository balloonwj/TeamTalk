//
//  DDGroupCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AvatorImageView,MTGroupEntity;
@interface DDGroupCell : NSTableCellView
{
    __weak IBOutlet AvatorImageView* avatorImageView;
    
}
@property(nonatomic,weak)IBOutlet NSTextField* nameTextField;
- (void)configWithGroup:(MTGroupEntity*)group;
@end
