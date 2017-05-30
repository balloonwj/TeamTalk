//
//  DDSearchViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DDSearchViewControllerDelegate <NSObject>

- (void)selectTheSearchResultObject:(id)object;

@end

@interface DDSearchViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>
@property(nonatomic,weak)IBOutlet NSTableView* tableView;
@property(nonatomic,weak)IBOutlet id<DDSearchViewControllerDelegate> delegate;
- (CGFloat)rowHeight;

- (void)setShowData:(NSArray*)data;

- (void)selectNext;
- (void)selectLast;

- (id)selectedObject;

@end
