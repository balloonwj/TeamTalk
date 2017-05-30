//
//  DDAddChatGroupWindowController.m
//  Duoduo
//
//  Created by zuoye on 14-2-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddChatGroupWindowController.h"
#import "DDAddChatGroupCell.h"
#import "DDAddGroupSelectedCell.h"
#import "ChildNode.h"
#import "DDHttpModule.h"
#import "MTUserEntity.h"
#import "DDAddChatGroup.h"
#import "SpellLibrary.h"
#import "TcpProtocolHeader.h"
#import "NSString+DDStringAdditions.h"
#import "DDTcpClientManager.h"
#import "DDAddGroupMemberDepartmentCell.h"
#import "DDMultiSelectedOutlineView.h"
#import "DDCreateGroupAPI.h"
#import "MTGroupChangeMemberAPI.h"
#import "MTSessionModule.h"
#import "MTGroupModule.h"
#import "MTUserModule.h"
#import "MTDatabaseUtil.h"
#define COLUMNID_NAME			@"NameColumn"	// the single column name in our outline view

// -------------------------------------------------------------------------------
//	TreeAdditionObj
//
//	This object is used for passing data between the main and secondary thread
//	which populates the outline view.
// -------------------------------------------------------------------------------
@interface TreeAdditionObj : NSObject
    {
        NSIndexPath *__unsafe_unretained indexPath;
        NSString	*__unsafe_unretained userId;
        NSString	*__unsafe_unretained nodeName;
        BOOL		selectItsParent;
    }
    
    @property (unsafe_unretained, readonly) NSIndexPath *indexPath;
    @property (unsafe_unretained, readonly) NSString *userId;
    @property (unsafe_unretained, readonly) NSString *nodeName;
    @property (readonly) BOOL selectItsParent;
    
    @end


#pragma mark -

@implementation TreeAdditionObj
    
    @synthesize indexPath, userId, nodeName, selectItsParent;
    
    // -------------------------------------------------------------------------------
    //  initWithURL:url:name:select
    // -------------------------------------------------------------------------------
- (id)initWithURL:(NSString *)uid withName:(NSString *)name selectItsParent:(BOOL)select
    {
        self = [super init];
        
        nodeName = name;
        userId = uid;
        selectItsParent = select;
        
        return self;
    }
    @end

@interface DDAddChatGroupWindowController ()

- (void)clickTheOutlineView:(id)sender;
- (void)p_createGroupFinished:(MTGroupEntity*)group;
- (void)p_addMemberInGroupFinished:(NSDictionary*)dic;

@end

@implementation DDAddChatGroupWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (DDAddChatGroupModel*)model
{
    if (!_model)
    {
        _model = [[DDAddChatGroupModel alloc] init];
    }
    return _model;
}

-(void)awakeFromNib{
	
	// make our outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[self.mainOutlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [self.mainOutlineView setAllowsMultipleSelection:YES];
}

- (void)windowDidLoad
{
    //加载worklist 数据
    [self.mainOutlineView setHidden:YES];
    [self.loadingIndicator setHidden:NO];
    [self.loadingIndicator startAnimation:nil];
    [self.model loadAllWorkListSuccess:^{
        [self.mainOutlineView setHidden:NO];
        [self.mainOutlineView reloadData];
        [self.loadingIndicator stopAnimation:nil];
        [self.loadingIndicator setHidden:YES];
    } Failure:^(NSError *error) {
        [self.mainOutlineView setHidden:YES];
    }];
    
    [self.mainOutlineView setAction:@selector(clickTheOutlineView:)];
    [self.mainOutlineView setTarget:self];
}

#pragma mark NSTextField Delegate
- (void)controlTextDidChange:(NSNotification *)obj
{
    //根据输入调整视图
    [self.model searchUser:_searchField.stringValue];
    
    
    [_mainOutlineView reloadData];
    if ([_searchField.stringValue length] > 0)
    {
        NSMutableArray* expandRow = [NSMutableArray array];
        for (int row = 0; row < [self.model.showGroups count]; row ++)
        {
            id item = [_mainOutlineView itemAtRow:row];
            [expandRow addObject:item];
        }
        
        [expandRow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_mainOutlineView expandItem:obj];
        }];
    }
    
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveDown:"])
    {
        
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveUp:"])
    {
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"])
    {
        if ([self.model.showGroups count] > 0) {
            DDAddChatGroup* group = self.model.showGroups[0];
            NSArray* user = group.users;
            id item = user[0];
            if (item)
            {
                [self.model selectItem:item];
                [_mainOutlineView reloadItem:nil
                              reloadChildren:YES];
                [_selectUserTableView reloadData];
            }
        }
    }
	else
    {
        if ([textView respondsToSelector:commandSelector])
        {
            [textView performSelector:commandSelector withObject:nil afterDelay:0];
        }
    }
    return YES;
}

//- (void)outlineViewSelectionDidChange:(NSNotification *)notification
//{
//    NSOutlineView* outView = [notification object];
////    [_mainOutlineView reloadData];
//    [_selectUserTableView reloadData];
//    [_selectUserTableView scrollToEndOfDocument:nil];
//}


#pragma mark - NSOutlineView delegate

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item)
    {
        return [self.model.showGroups count];
    }
    else if([item isKindOfClass:NSClassFromString(@"DDAddChatGroup")])
    {
        DDAddChatGroup* group = (DDAddChatGroup*)item;
        NSArray* users = group.users;
        return [users count];
    }
    else if ([item isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        return 0;
    }
    return 0;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 36;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item)
    {
        return self.model.showGroups[index];
    }
    else if ([item isKindOfClass:NSClassFromString(@"DDAddChatGroup")])
    {
        DDAddChatGroup* group = (DDAddChatGroup*)item;
        NSArray* user = group.users;
        return user[index];
    }
    else
    {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (!item || [item isKindOfClass:NSClassFromString(@"DDAddChatGroup")])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([item isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        NSString* identifier = [tableColumn identifier];
        NSString* cellIdentifier = @"DDAddChatGroupCellIdentifier";
        if ([identifier isEqualToString:@"NameColumn"])
        {
            DDAddChatGroupCell* cell = (DDAddChatGroupCell*)[outlineView makeViewWithIdentifier:cellIdentifier owner:self];
            [cell setItem:item];
            NSInteger row = [_mainOutlineView rowForItem:item];
            if ([self.model exitInSelectedUsers:item])
            {
                [_mainOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
            }
            else
            {
                [_mainOutlineView deselectRow:row];
            }
            return cell;
        }
    }
    else if ([item isKindOfClass:NSClassFromString(@"DDAddChatGroup")])
    {
        //DDAddGroupMemberDepartmentCellIdentifier
        NSString* identifier = [tableColumn identifier];
        NSString* cellIdentifier = @"DDAddGroupMemberDepartmentCellIdentifier";
        if ([identifier isEqualToString:@"NameColumn"])
        {
            DDAddGroupMemberDepartmentCell* cell = (DDAddGroupMemberDepartmentCell*)[outlineView makeViewWithIdentifier:cellIdentifier owner:self];
            [cell setItem:item];
            NSInteger row = [_mainOutlineView rowForItem:item];
            if ([self.model exitInSelectedUsers:item])
            {
                [_mainOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
            }
            else
            {
                [_mainOutlineView deselectRow:row];
            }
            return cell;
        }
    }
    return nil;
}

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
//{
//    if ([self.model couldSelected:item])
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}

#pragma mark NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.model.selectUsers count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 40;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"DDAddGroupSelectedCell";
    if ([identifier isEqualToString:@"selectedColumn"])
    {
        DDAddGroupSelectedCell * cell = (DDAddGroupSelectedCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
        MTUserEntity* user = self.model.selectUsers[row];
        [cell configeWithUser:user cancel:^{
            [self.model selectItem:user];
            [_mainOutlineView reloadData];
            [_selectUserTableView reloadData];
        }];
        
        return cell;
    }
    return nil;
}
#pragma mark IBAction
- (IBAction)pressCancelBtnOnAddChatGroup:(id)sender {
    self.hasPressOK = NO;
     [NSApp endSheet:self.addChatGroupWindow];
    [self.addChatGroupWindow close];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:nil];
}

- (IBAction)pressOKBtnOnAddChatGroup:(id)sender {
    
    [NSApp endSheet:self.addChatGroupWindow];
    if ([self.model.selectUsers count] == 0)
    {
        return;
    }
    self.hasPressOK = YES;
    if (_addType==0) {
        //初始化组名字
        
        NSMutableString* groupName = [[NSMutableString alloc] init];
        [self.model.initialGroupUsersIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTUserEntity* user = (MTUserEntity *)[[MTUserModule shareInstance]getOriginEntityWithOriginID:obj];
            NSString* name = [user name];
            [groupName appendFormat:@"%@,",name];
        }];
        
        [self.model.selectUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* name = [(MTUserEntity*)obj name];
            [groupName appendFormat:@"%@,",name];
        }];
        NSString* name = [groupName substringToIndex:[groupName length] - 1];
        [_txtGroupName setStringValue:name];
        
        
        [NSApp beginSheet:self.panelGroupName modalForWindow:[[self window] parentWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }else{
        NSMutableArray *userIdList = [[NSMutableArray alloc] init];
        for (MTUserEntity* user in self.model.selectUsers)
        {
            [userIdList addObject:user.ID];
        }
        
        MTGroupChangeMemberAPI    *addMemberToGroupAPI = [[MTGroupChangeMemberAPI alloc] init];
        NSString* myID = [[DDClientState shareInstance]userID];
        NSArray* object = @[self.groupID,userIdList,@(GroupModifyTypeGroupModifyTypeAdd),myID];
        __weak DDAddChatGroupWindowController* weakSelf = self;
        [addMemberToGroupAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error && response)
            {
                [weakSelf p_addMemberInGroupFinished:response];
            }
            [NSApp endSheet:self.panelGroupName];
        }];
        
    }
    
    
    
}

- (IBAction)addGroupNameCancle:(id)sender {
    [NSApp endSheet:self.panelGroupName];

}

- (IBAction)addGroupNameOk:(id)sender {
    
    NSString* chectGroupName = [self.txtGroupName stringValue];
    
    if ([chectGroupName allSpaceAllNewLine])
    {
        return;
    }
    NSMutableArray *userIdList = [[NSMutableArray alloc] init];
    for (MTUserEntity* user in self.model.selectUsers)
    {
        [userIdList addObject:user.ID];
    }
    if (_addType==0) {      //创建
        //创建的时候,加上自己,加当
        NSString *myUserId = [[DDClientState shareInstance] userID];
        [userIdList addObject:myUserId];
        
        //加上初始选中的人
        for (NSString* userID in self.model.initialGroupUsersIDs)
        {
            if (![userID isEqualToString:myUserId])
            {
                [userIdList addObject:userID];
                break;
            }
        }
        DDCreateGroupAPI* createGroupAPI = [[DDCreateGroupAPI alloc] init];
        NSArray* object = @[[self.txtGroupName stringValue],@"",userIdList];
        __weak DDAddChatGroupWindowController* weakSelf = self;
        [createGroupAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (response && !error)
            {
                [weakSelf p_createGroupFinished:response];
            }
        }];
//        NSMutableData *dataReadAckData = [TcpProtocolPack getCreateTmpGroupRequest:[self.txtGroupName stringValue] groupAvatar:@"" userList:userIdList];
//        [[DDTcpClientManager instance] writeToSocket:dataReadAckData];
    }
//    else{
//        DDAddMemberToGroupAPI* addMemeberToGroupAPI = [[DDAddMemberToGroupAPI alloc] init];
//        NSArray* object = @[_sessionId,userIdList];
//        [addMemeberToGroupAPI requestWithObject:object Completion:^(id response, NSError *error) {
//            
//        }];
////        NSMutableData *dataReadAckData = [TcpProtocolPack getChangeGroupMemberRequest:CMD_ID_GROUP_JOIN_GROUP_REQ groupId:_sessionId userList:userIdList ];
////        [[DDTcpClientManager instance] writeToSocket:dataReadAckData];
//    }
     [NSApp endSheet:self.panelGroupName];
}

- (void)clickTheOutlineView:(id)sender
{
    NSInteger clickRow = [_mainOutlineView clickedRow];
    id item = [_mainOutlineView itemAtRow:clickRow];
    if (![self.model couldSelected:item])
    {
        [_mainOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:clickRow] byExtendingSelection:YES];
        return;
    }
    if (![self.model exitInSelectedUsers:item])
    {
        [_mainOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:clickRow] byExtendingSelection:YES];
    }
    else
    {
        [_mainOutlineView deselectRow:clickRow];
    }
    [self.model selectItem:item];
    
    [_mainOutlineView reloadItem:item];
    [_mainOutlineView reloadItem:item reloadChildren:YES];

    [_selectUserTableView reloadData];
    [_selectUserTableView scrollToEndOfDocument:nil];
}

- (void)p_createGroupFinished:(MTGroupEntity*)group
{
    
    if (group) {
        NSArray* originEntities = [[NSArray alloc] initWithObjects:group, nil];
        [[MTDatabaseUtil instance] insertGroups:originEntities];
        [[MTGroupModule shareInsatnce] addMaintainOriginEntities:originEntities];
        [[DDMainWindowController instance] openGroupChatWithGroup:group.ID];
    }
}

- (void)p_addMemberInGroupFinished:(NSDictionary*)dic
{
    NSString* groupID = dic[@"groupID"];
    NSArray* userIDs = dic[@"userIDs"];
    MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
    group.groupUserIds = [NSMutableArray arrayWithArray:userIDs];
    [[MTDatabaseUtil instance] insertGroups:@[group]];
    
}

@end
