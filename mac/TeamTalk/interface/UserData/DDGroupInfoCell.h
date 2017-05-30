//
//  DDGroupInfoCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DDGroupInfoCell;
@protocol DDGroupInfoCellDelegate <NSObject>

- (void)groupInfoCell:(DDGroupInfoCell*)cell selectUserIndex:(NSInteger)index;

@end

@class MTUserEntity;
@interface DDGroupInfoCell : NSTableCellView
{
    __weak IBOutlet EGOImageView* _firstImageView;
    __weak IBOutlet EGOImageView* _secondImageView;
    __weak IBOutlet EGOImageView* _thirdImageView;
    __weak IBOutlet EGOImageView* _forthImageView;
    __weak IBOutlet EGOImageView* _fifthImageView;
    __weak IBOutlet EGOImageView* _sixthImageView;
    
    __weak IBOutlet NSTextField* _firstTextField;
    __weak IBOutlet NSTextField* _secondTextField;
    __weak IBOutlet NSTextField* _thirdTextField;
    __weak IBOutlet NSTextField* _forthTextField;
    __weak IBOutlet NSTextField* _fifthTextField;
    __weak IBOutlet NSTextField* _sixthTextField;
}
@property (nonatomic,assign)id<DDGroupInfoCellDelegate> delegate;
- (void)setUserAtIndex:(int)index withUser:(MTUserEntity*)user;

- (IBAction)clickTheUser:(id)sender;
@end
