//
//  DDAddGroupSelectedCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AvatorImageView;
@interface DDAddGroupSelectedCell : NSTableCellView
@property (nonatomic,weak)IBOutlet AvatorImageView* avatar;
@property (nonatomic,weak)IBOutlet NSTextField* name;

- (void)configeWithUser:(id)user cancel:(void(^)())cancel;

- (IBAction)cancelSelected:(id)sender;

@end
