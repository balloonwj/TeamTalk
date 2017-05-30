//
//  DDIntranetViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DDIntranetModule;
@class DDIntranetEntity;
@class DDIntranetViewController;
@protocol DDIntranetViewControllerDelegate <NSObject>

- (void)intranetViewController:(DDIntranetViewController*)intranetViewCOntroller selectIntranetEntity:(DDIntranetEntity*)intranet;

@end

@interface DDIntranetViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>
@property (nonatomic,weak)IBOutlet NSTableView* tableView;
@property (nonatomic,retain)DDIntranetModule* module;
@property (nonatomic,assign)id<DDIntranetViewControllerDelegate> delegate;

- (void)selectItemAtIndex:(NSUInteger)index;
@end
