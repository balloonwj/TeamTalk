//
//  DDIntranetCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DDIntranetEntity;
@interface DDIntranetCell : NSTableCellView
{
    __weak IBOutlet EGOImageView* avatarImageView;
    __weak IBOutlet NSTextField* nameTextField;
    __weak IBOutlet NSTextField* unreadMessageLabel;
    __weak IBOutlet NSImageView* unreadMessageBackgroundImageView;
}
- (void)configWithIntranet:(DDIntranetEntity*)intranet;
@end
