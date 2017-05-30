//
//  DDLeftBarItem.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDLeftBarItem;
@protocol DDLeftBarItemDelegate<NSObject>

- (void)selectedItem:(DDLeftBarItem*)item;

@end
@interface DDLeftBarItem : NSImageView;
@property (nonatomic,assign)id<DDLeftBarItemDelegate> delegate;
- (instancetype)initWithFrame:(NSRect)frameRect
                selectedImage:(NSImage*)selectedImage
              unSelectedImage:(NSImage*)unselectedImage
                          tag:(NSInteger)tag;
- (void)setSelected:(BOOL)selected;

- (void)hasUnreadMessage:(NSInteger)unreadMessageCount;
@end
