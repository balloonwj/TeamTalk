//
//  DDRecentContactsViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRecentContactsViewController.h"
#import "DDRecentContactsCell.h"
#import "MTMessageModule.h"
#import "DDSearch.h"
#import "DDSearchViewController.h"
#import "DDHttpModule.h"
#import "MTUserEntity.h"
#import "DDAlertWindowController.h"
#import "MTGroupEntity.h"
#import "DDRecentContactsModule.h"
#import "MTSessionEntity.h"
#import "DDUserInfoManager.h"
#import "MTGroupModule.h"
#import "DDGroupInfoManager.h"
#import "NSView+LayerAddition.h"
#import "MTSessionModule.h"
#import "IMBaseDefine.pb.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "MTMessageModule.h"
#import "MTDatabaseUtil.h"
#import "DDContactsRowView.h"
@interface DDRecentContactsViewController ()

/**
 *  添加观察者
 */
- (void)p_addObserver;

- (void)p_clickTheTableView;
- (void)p_showSearchResultView;
- (void)p_searchOnline:(NSString*)content;

- (void)n_receiveReloadRecentContacts:(NSNotification*)notification;
- (void)n_receiveMessageNotification:(NSNotification*)notification;

- (void)p_resetSelectedRow;

- (void)p_receiveBoundsChanged:(NSNotification*)notification;
@end

@implementation DDRecentContactsViewController
{
    NSString* _selectedSessionID;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _selectedSessionID = @"";
    }
    return self;
}

- (void)awakeFromNib
{
    [_tableView setHeaderView:nil];
    [_tableView setTarget:self];
    [_tableView setAction:@selector(p_clickTheTableView)];

    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = _searchViewController;
    self.popover.behavior = NSPopoverBehaviorTransient;
}

- (DDRecentContactsModule*)module
{
    if (!_module)
    {
        _module = [[DDRecentContactsModule alloc] init];
    }
    return _module;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DDClientState shareInstance] removeObserver:self forKeyPath:DD_DATA_STATE_KEYPATH];
    [[StateMaintenanceManager instance] removeObserver:self forKeyPath:DD_USER_ONLINE_STATE_KEYPATH];
}
#pragma mark public API
- (void)selectSession:(NSString*)sessionID
{
    NSArray* recentSessionIDs = [[MTSessionModule shareInstance] sessions];
    NSInteger selectedRow = [recentSessionIDs indexOfObject:sessionID];
    if([recentSessionIDs containsObject:sessionID])
    {
        if (selectedRow >= 0)
        {
            NSString* sId = recentSessionIDs[selectedRow];
            _selectedSessionID = sId;
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            _selectedSessionID = sessionID;
            [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
            [_tableView scrollRowToVisible:selectedRow];
        }
    }
}

- (void)updateData
{
    [_tableView reloadData];
}

- (void)initialData
{
    [self p_addObserver];
}

#pragma mark -
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_DATA_STATE_KEYPATH])
    {
        DDDataState oldDataState = [change[@"old"] integerValue];
        DDDataState newDataState = [change[@"new"] integerValue];
        if ( !(oldDataState & DDLocalSessionDataReady) && (newDataState & DDRemoteSessionDataReady))
        {
            //本地session数据加载完成,这时候最近联系人界面都没有加载
            [self updateData];

        }
        else if ((!(oldDataState & DDRemoteSessionDataReady) && (newDataState & DDRemoteSessionDataReady)) ||
                 (!(oldDataState & DDRemoteSessionGroupDataReady) && (newDataState & DDRemoteSessionGroupDataReady)))
        {
            //远程数据加载完成
            [self updateData];
        }
    }
    else if ([keyPath isEqualToString:DD_USER_ONLINE_STATE_KEYPATH])
    {
        DDUserStateEntity* userState = change[@"new"];
        NSString* userID = userState.userId;
        NSString* sessionID = [MTSessionEntity getSessionIDForOriginID:userID sessionType:SessionTypeSessionTypeSingle];
        if ([[[MTSessionModule shareInstance]sessions] containsObject:sessionID]) {
            NSUInteger row = [[[MTSessionModule shareInstance] sessions] indexOfObject:sessionID];
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
}

#pragma mark - Menu Action
- (IBAction)removeSession:(id)sender
{
    NSInteger rowNumber = [_tableView clickedRow];
//    NSUInteger selectedRowNumber = [_tableView selectedRow];
    if (rowNumber < 0)
    {
        return;
    }
    NSString* sId = [[MTSessionModule shareInstance] sessions][rowNumber];
    MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sId];
    
    [[MTSessionModule shareInstance]deleteSessionID:session.originID sessionType:session.sessionType completion:^(BOOL result) {
        if (result)
        {
            DDLog(@"删除成功");
            
            [[MTMessageModule shareInstance] clearUnreadMessagesForSessionID:sId];
            [self updateData];
            if ([[[MTSessionModule shareInstance] currentChatingSessionID] isEqualToString:session.sessionID])
            {
                //在当前聊天页面，则自动选择到最顶部的session
                if ([[MTSessionModule shareInstance].sessions count] > 0)
                {
                    NSString* firstSession = [MTSessionModule shareInstance].sessions[0];
                    [self.delegate recentContactsViewController:self selectSession:firstSession];
                }
            }
        }
        else
        {
            DDLog(@"删除失败");
        }
    }];
}

- (IBAction)viewContact:(id)sender
{
    NSInteger rowNumber = [_tableView clickedRow];
    if(rowNumber < 0)
        return;
    
    
    NSString* sId = [[MTSessionModule shareInstance]sessions][rowNumber];
    
    if (![sId hasPrefix:@"group"])
    {
        MTUserEntity* showUser =(MTUserEntity *)[[MTUserModule shareInstance] getOriginEntityWithOriginID:sId];
        
        [[DDUserInfoManager instance] showUser:showUser forContext:self];
    }
    else
    {
        MTGroupModule* groupModule = [MTGroupModule shareInsatnce];
        MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sId];
        MTGroupEntity* group = (MTGroupEntity *)[groupModule getOriginEntityWithOriginID:session.originID];
        
        [[DDGroupInfoManager instance] showGroup:group context:self];
    }
    
}

-(IBAction)topSession:(id)sender
{
    NSInteger clickRow = [_tableView clickedRow];
    if(clickRow < 0)
        return;
    
    NSString* sId = [[MTSessionModule shareInstance]sessions][clickRow];
    [[MTSessionModule shareInstance] moveSessionIDToTop:sId];
    [[MTSessionModule shareInstance] sortSessions];
    //tt_3.0 刷新UI更新.
    [self updateData];
}

-(IBAction)cancelTopSession:(id)sender
{
    NSInteger rowNumber = [_tableView clickedRow];
    if(rowNumber < 0)
        return;
    
    NSString* sId = [[MTSessionModule shareInstance]sessions][rowNumber];
    
    [[MTSessionModule shareInstance] cancelTopSession:sId];
    [[MTSessionModule shareInstance] sortSessions];
    [self updateData];
}

-(IBAction)shieldSession:(id)sender
{
    NSInteger rowNumber = [_tableView clickedRow];
    if(rowNumber < 0)
        return;
    
    NSString* sId = [[MTSessionModule shareInstance]sessions][rowNumber];
    [[MTSessionModule shareInstance] shieldSessionID:sId shield:YES completion:^(BOOL result) {
        
    }];
    
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowNumber] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
}

-(IBAction)cancelShieldSession:(id)sender
{
    NSInteger rowNumber = [_tableView clickedRow];
    if(rowNumber < 0)
        return;
    
    NSString* sId = [[MTSessionModule shareInstance]sessions][rowNumber];
    
    [[MTSessionModule shareInstance] shieldSessionID:sId shield:NO completion:^(BOOL result) {
        
    }];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowNumber] columnIndexes:[NSIndexSet indexSetWithIndex:0]];

}

#pragma mark - DDSearchViewControllerDelegate
- (void)selectTheSearchResultObject:(id)obj
{
    DDOriginEntity *object = [_searchViewController selectedObject];
    if ([object isKindOfClass:[MTUserEntity class]])
    {
        NSString* userID = [(MTUserEntity*)obj ID];
        [[DDMainWindowController instance] openUserChatWithUser:userID];
    }
    else
    {
        NSString* groupID = [(MTGroupEntity*)obj ID];
        [[DDMainWindowController instance] openGroupChatWithGroup:groupID];
    }
    //[_searchViewController.view setHidden:YES];
    [self hiddenPopView];
    [_searchField setStringValue:@""];
}

#pragma mark - NSMenu Delegate
- (void)menuWillOpen:(NSMenu *)menu
{
    NSInteger rowNumber = [_tableView clickedRow];
    if(rowNumber < 0)
        return;
    
    //设置移除会话菜单
    NSString* sessionID = [[MTSessionModule shareInstance]sessions][rowNumber];
    MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sessionID];
    BOOL removeItemShow = YES;
    if (session.sessionType == SessionTypeSessionTypeSingle)
    {
//        UserEntity* user = [getDDUserlistModule() getUserById:session.orginId];
//        if((user.userRole & 0x20000000) != 0)
//        {
//            //公共帐号
//            removeItemShow = NO;
//        }
    }
    NSArray* topSession =[[MTSessionModule shareInstance]getTopSessionIDs];;
    if ([topSession containsObject:sessionID])
    {
        removeItemShow = NO;
    }
    
    NSMenuItem* removeMenuItem = [menu itemAtIndex:0];
    [removeMenuItem setHidden:!removeItemShow];
    
    
    //设置置顶菜单
    if ([topSession containsObject:sessionID])
    {
        NSMenuItem* topMenuItem = [menu itemAtIndex:2];
        [topMenuItem setHidden:YES];
        
        NSMenuItem* cancelMenuItem = [menu itemAtIndex:3];
        [cancelMenuItem setHidden:NO];
        
    }
    else
    {
        NSMenuItem* topMenuItem = [menu itemAtIndex:2];
        [topMenuItem setHidden:NO];
        
        
        NSMenuItem* cancelMenuItem = [menu itemAtIndex:3];
        [cancelMenuItem setHidden:YES];
        
    }
    //设置屏蔽菜单
    if (session.sessionType == SessionTypeSessionTypeSingle)
    {
        NSMenuItem* shieldMenuItem = [menu itemAtIndex:5];
        [shieldMenuItem setHidden:YES];
        
        NSMenuItem* cancelShieldMenuItem = [menu itemAtIndex:6];
        [cancelShieldMenuItem setHidden:YES];
    }
    NSArray* shieldSessions = [[MTSessionModule shareInstance] getShieldSessionIDs];
    if ([shieldSessions containsObject:sessionID])
    {
        NSMenuItem* shieldMenuItem = [menu itemAtIndex:5];
        [shieldMenuItem setHidden:YES];
        
        NSMenuItem* cancelShieldMenuItem = [menu itemAtIndex:6];
        [cancelShieldMenuItem setHidden:NO];
    }
    else
    {
        NSMenuItem* shieldMenuItem = [menu itemAtIndex:5];
        [shieldMenuItem setHidden:NO];
        
        NSMenuItem* cancelShieldMenuItem = [menu itemAtIndex:6];
        [cancelShieldMenuItem setHidden:YES];
    }
    
}

#pragma mark NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    DDSearch* search = [DDSearch instance];
    [search searchContent:_searchField.stringValue completion:^(NSArray *result, NSError *error) {
        if ([result count] == 0)
        {
            //[_searchViewController.view setHidden:YES];
            [self hiddenPopView];
        }
        else
        {
            [_searchViewController setShowData:result];
            CGFloat height = 0;
            if ([result count] > 10)
            {
                height = [_searchViewController rowHeight] * 10;
            }
            else
            {
                height = [_searchViewController rowHeight] * [result count] + 6;
            }
            [self.popover setContentSize:NSMakeSize(self.view.bounds.size.width, height)];
//            [_searchViewController.view setFrameSize:NSMakeSize(self.view.bounds.size.width, height)];
            [self p_showSearchResultView];
        }
    }];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveDown:"])
    {
        DDLog(@"select down");
        [_searchViewController selectNext];
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveUp:"])
    {
        [_searchViewController selectLast];
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"])
    {
        BOOL searchHidden = [_searchViewController.view isHidden];
        if (searchHidden)
        {
            [self p_searchOnline:textView.string];
        }
        else
        {
            DDOriginEntity *object = [_searchViewController selectedObject];
            [self selectTheSearchResultObject:object];
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

#pragma mark TableView DataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[MTSessionModule shareInstance] sessions] count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 50;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* sId = [[MTSessionModule shareInstance]sessions][row];
    MTSessionEntity* session = [[MTSessionModule shareInstance] getSessionBySessionID:sId];
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"RecentContactCellIdentifier";
    if ([identifier isEqualToString:@"RecentContactColumnIdentifier"])
    {
        DDRecentContactsCell* cell = (DDRecentContactsCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
       [cell configeCellWithObject:session];
        
        NSTableRowView* rowView = [tableView rowViewAtRow:row makeIfNecessary:YES];
        if ([sId isEqualToString:[MTSessionModule shareInstance].currentChatingSessionID])
        {
            rowView.selected = YES;
        }
        else
        {
            rowView.selected = NO;
        }
        return cell;
    }
    return nil;
}

#pragma mark privateAPI
- (void)p_addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveReloadRecentContacts:) name:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveMessageNotification:) name:DD_MESSAGE_MODULE_RECEIVE_MESSAGE object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveBoundsChanged:) name:NSViewBoundsDidChangeNotification object:nil];

    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_DATA_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                       context:nil];
    
    [[StateMaintenanceManager instance] addObserver:self
                                         forKeyPath:DD_USER_ONLINE_STATE_KEYPATH
                                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                            context:nil];
}


- (void)p_clickTheTableView
{
    NSInteger selectedRow = [_tableView selectedRow];
    if (selectedRow >= 0)
    {
        NSString* sId = [[MTSessionModule shareInstance]sessions][selectedRow];
        _selectedSessionID = sId;
        if (self.delegate)
        {
            [self.delegate recentContactsViewController:self selectSession:sId];
        }
    }
}

- (void)p_showSearchResultView
{
    if ([_searchField.stringValue length] == 0)
    {
        return;
    }
    [_searchViewController.view setHidden:NO];
    if (self.isShowPop == 0) {
            [self.popover showRelativeToRect:[self.searchField bounds] ofView:self.searchField preferredEdge:NSMaxXEdge];
        self.isShowPop =1;
    }
    [self.searchField becomeFirstResponder];
    [[self.searchField currentEditor] moveToEndOfLine:nil];
}

- (void)p_searchOnline:(NSString*)content
{
    
}

- (void)n_receiveReloadRecentContacts:(NSNotification*)notification
{
//    void (^ResetSelectedRow)() = ^{
//        NSString* currentSelectedSessionID = [[MTSessionModule shareInstance] currentChatingSessionID];
//        if ([[MTSessionModule shareInstance].sessions containsObject:currentSelectedSessionID])
//        {
//            NSUInteger row = [[MTSessionModule shareInstance].sessions indexOfObject:currentSelectedSessionID];
//            [_tableView selectColumnIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
//        }
//    };
    
    if ([notification object])
    {
        NSString* sessionID = [notification object];
        if ([[[MTSessionModule shareInstance] sessions] count] != [_tableView numberOfRows])
        {
            [[MTSessionModule shareInstance] sortSessions];
            [self updateData];
//            ResetSelectedRow();
        }
        else if ([[MTSessionModule shareInstance].sessions containsObject:sessionID])
        {
            NSUInteger row = [[MTSessionModule shareInstance].sessions indexOfObject:sessionID];
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
//            ResetSelectedRow();
        }
        else
        {
            [[MTSessionModule shareInstance] sortSessions];
            [self updateData];
//            ResetSelectedRow();
        }
        
    }
    else
    {
        [[MTSessionModule shareInstance] sortSessions];
        [self updateData];
//        ResetSelectedRow();
    }
}

- (void)n_receiveMessageNotification:(NSNotification*)notification
{
    MTMessageEntity* message = [notification object];
    NSString* sessionID = message.sessionID;
    if (![[MTSessionModule shareInstance].currentChatingSessionID isEqualToString:sessionID])
    {
        if ([[MTSessionModule shareInstance].sessions containsObject:sessionID])
        {
            NSUInteger row = [[MTSessionModule shareInstance].sessions indexOfObject:sessionID];
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
}

- (void)p_resetSelectedRow
{
    NSArray* recentSessionIDs = [[MTSessionModule shareInstance] sessions];
    [recentSessionIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:_selectedSessionID])
        {
            [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
            *stop = YES;
        }
    }];
}

- (void)p_receiveBoundsChanged:(NSNotification*)notification
{
    
//    id object = [notification object];
//    if ([object isEqual:self.clipView])
//    {
//        [self hiddenPopView];
//    }
}
-(void)hiddenPopView
{
    [_searchViewController.view setHidden:YES];
    [self.popover performClose:nil];
    self.isShowPop=0;
}
@end
