//
//  DDAddChatGroupWindowController.h
//  Duoduo
//
//  Created by zuoye on 14-2-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDAddChatGroupModel.h"
@class DDMultiSelectedOutlineView;
@interface DDAddChatGroupWindowController : NSWindowController<NSOutlineViewDataSource,NSOutlineViewDelegate,NSTableViewDataSource,NSTableViewDelegate,NSControlTextEditingDelegate>{

}

@property (nonatomic,retain)DDAddChatGroupModel* model;
    
@property (strong) IBOutlet NSWindow *addChatGroupWindow;
@property (weak) IBOutlet DDMultiSelectedOutlineView *mainOutlineView;
@property (weak) IBOutlet NSTableView *selectUserTableView;
@property (weak) IBOutlet NSSearchField* searchField;
@property (strong) IBOutlet NSPanel *panelGroupName;
@property (weak) IBOutlet NSTextField *txtGroupName;
@property (weak) IBOutlet NSProgressIndicator* loadingIndicator;
- (IBAction)addGroupNameCancle:(id)sender;
- (IBAction)addGroupNameOk:(id)sender;

@property BOOL hasPressOK;
@property int addType;


- (IBAction)pressCancelBtnOnAddChatGroup:(id)sender;
- (IBAction)pressOKBtnOnAddChatGroup:(id)sender;

@property (strong) NSString *groupID;

@end