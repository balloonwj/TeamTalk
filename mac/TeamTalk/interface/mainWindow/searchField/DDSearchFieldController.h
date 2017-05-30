//
//  DDSearchFieldController.h
//  Duoduo
//
//  Created by zuoye on 14-1-26.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSearchFieldController : NSObject<NSTableViewDataSource,NSTableViewDelegate>{
    NSMutableArray			*allKeywords;
	NSMutableArray			*builtInKeywords;
    NSMutableDictionary     *userIdByName;
	
	BOOL					completePosting;
    BOOL					commandHandling;
    
    
}
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSSearchFieldCell* searchFieldCell;
@property (weak) IBOutlet NSTableView* tableView;
@property (weak) IBOutlet NSScrollView* scrollView;

//TODO:这里需要重构，把Model分离出来
@property (nonatomic,retain)dispatch_queue_t searchQueue;


@end
