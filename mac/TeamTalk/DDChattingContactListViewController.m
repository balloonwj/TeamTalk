//
//  DDChattingContactListViewController.m
//  Duoduo
//
//  Created by zuoye on 14-1-9.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDChattingContactListViewController.h"
#import "ImageAndTextCell.h"
#import "MTSessionModule.h"
#import "DDMainModule.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "MTGroupModule.h"
#import "MTSessionEntity.h"
#import "DDUserInfoManager.h"
#import "DDChattingContactListCell.h"
#import "TcpProtocolHeader.h"
#import "DDTcpClientManager.h"
#import "DDChattingContactListModule.h"
#import "MTGroupChangeMemberAPI.h"
#import "MTDatabaseUtil.h"

@implementation DDChattingContactListViewController
-(id)init{
    self =[super init];
    if (self) {
        _observerUserOnlineState=NO;
    }
    return self;
}


- (void)setGroupEntity:(MTGroupEntity *)groupEntity
{
    if (_groupEntity)
    {
        [_groupEntity removeObserver:self forKeyPath:@"groupUserIds"];
        _groupEntity = nil;
    }
    _groupEntity = groupEntity;
    self.module.groupEntity = groupEntity;
    
    [self.module.groupEntity addObserver:self
                              forKeyPath:@"groupUserIds"
                                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                 context:nil];
    
    [self reloadContactListTableView];
    

}

- (DDChattingContactListModule*)module
{
    if (!_module)
    {
        _module = [[DDChattingContactListModule alloc] init];
    }
    return _module;
}

-(void)awakeFromNib{
    ImageAndTextCell *celll = [[ImageAndTextCell alloc] init];
    [[self contactListColumn] setDataCell:celll];
    [self.contactListTableView setDataSource:self];
    [self.contactListTableView setTarget:self];
    [self.contactListTableView setDoubleAction:@selector(onParticipanListDoubleClicked:)];
    [self.contactListTableView setDelegate:self];
    [self.listViewTitleTextField setEditable:NO];
    [self.listViewTitleTextField setBackgroundColor:[NSColor clearColor]];
    [self.contactListTableView setBackGroundImage:[NSImage imageNamed:@"panel_bg_theme_gray"]];

    _observerUserOnlineState = YES;
    
    if (!_observerUserOnlineState)
    {
        [[StateMaintenanceManager instance] addObserver:self
                                             forKeyPath:DD_USER_ONLINE_STATE_KEYPATH
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:nil];
    }
}

- (void)onParticipanListDoubleClicked:(id)sender{
    NSInteger clickedRow = [_contactListTableView clickedRow];
    if (clickedRow >= 0)
    {
        NSArray* groupUsers = [self.module getGroupUserList];
        MTUserEntity* selectUser = [groupUsers objectAtIndex:clickedRow];
        if([[[DDClientState shareInstance]userID ] isEqualToString:selectUser.ID]){    //点击的是自己,弹出自己的用户信息面板.
            
        }else{
            
            [[DDMainWindowController instance] openUserChatWithUser:selectUser.ID];
             
        }
    }
}

-(void)updateContactList:(NSNotification*)notification
{
    NSDictionary* changedUserState = [notification object];
    __block BOOL change = NO;
    [[changedUserState allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self.module.getGroupUserList containsObject:obj])
        {
            change = YES;
            *stop = YES;
        }
    }];
    if (!change)
    {
        return;
    }
    [self reloadContactListTableView];
}

-(void)updateTitle{
    ;
   NSString *title = [NSString stringWithFormat:@"参与人(%ld/%ld)",[self.module getOnlineUserListCount],[[self.module getGroupUserList] count]];
    [self.listViewTitleTextField setStringValue:title];
    [self setLabelAttribute:self.listViewTitleTextField];
}

-(void)setLabelAttribute:(NSTextField *)textField{
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[textField attributedStringValue]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor whiteColor]];
    [shadow setShadowOffset:NSMakeSize(1, 1)];
    NSRange fullRange = NSMakeRange(0, [[textField stringValue] length]);
    [titleAttributedString addAttribute:@"NSShadowAttributeName" value:shadow range:fullRange];
}

- (void)dealloc
{
    if (_observerUserOnlineState) {
        [[StateMaintenanceManager instance] removeObserver:self forKeyPath:DD_USER_ONLINE_STATE_KEYPATH];
    }
    [_contactListTableView setDataSource:nil];
    [_contactListTableView setDelegate:nil];
    [self.module.groupEntity removeObserver:self forKeyPath:@"groupUserIds"];
}

#pragma mark - NSSearchField
- (void)controlTextDidChange:(NSNotification *)obj
{
    [self.module searchContent:_searchField.stringValue completion:^{
        [_contactListTableView reloadData];
    }];
    
}

#pragma mark - NSMenu Delegate
- (void)menuWillOpen:(NSMenu *)menu
{
    NSString* myID = [[DDClientState shareInstance]userID];
    MTGroupEntity* currentGroup =self.module.groupEntity;
//    (MTGroupEntity *)[groupModule getOriginEntityWithOriginID:self.module.session.originID];
    //若为群主则可以移除群成员
    NSMenuItem* deleteUserMenuItem = [menu itemAtIndex:3];
    BOOL meIsGroupCreator = [myID isEqualToString:currentGroup.groupCreatorId];
    
    NSUInteger clickRow = [_contactListTableView clickedRow];

    NSArray* showGroupUsers = [self.module getGroupUserList];
    MTUserEntity* user =(MTUserEntity *)[[MTUserModule shareInstance]getOriginEntityWithOriginID:[[showGroupUsers objectAtIndex:clickRow]ID]];
    BOOL clickNotMe = ![user.ID isEqualToString:myID];
    
    if (clickNotMe && meIsGroupCreator)
    {
        [deleteUserMenuItem setHidden:NO];
    }
    else
    {
        [deleteUserMenuItem setHidden:YES];
    }

}

#pragma mark NSTableView Delegate mothed
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{

    NSArray* groupUsers = [self.module getGroupUserList];
    return [groupUsers count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = @"DDChattingContactListCellIdentifier";
    DDChattingContactListCell* cell = (DDChattingContactListCell*)[tableView makeViewWithIdentifier:identifier owner:self];
    NSArray* groupUsers = [self.module getGroupUserList];
    MTUserEntity *userEntity = groupUsers[row] ;
    [cell configeWithUser:userEntity];
    return cell;
}

-(NSImage *)getOnlineStateIcon:(NSString *)userId{
    
    return nil;
}

- (IBAction)sendMsgToUsers:(id)sender {
    [self onParticipanListDoubleClicked:self];
}

- (IBAction)viewUserInfo:(id)sender
{
//    NSInteger rowNumber = [_contactListTableView selectedRow];
//    if(rowNumber < 0)
//        return;
    NSInteger clickedRow = [_contactListTableView clickedRow];
    if (clickedRow >= 0)
    {
        NSArray* groupUsers = [self.module getGroupUserList];
        MTUserEntity* showUser = [groupUsers objectAtIndex:clickedRow];
        [[DDUserInfoManager instance] showUser:showUser forContext:self];
    }
}

- (IBAction)deleteGroupMember:(id)sender
{
    NSInteger clickedRow = [_contactListTableView clickedRow];
    if (clickedRow >= 0)
    {
        NSArray* groupUsers = [self.module getGroupUserList];
        MTUserEntity* user = groupUsers[clickedRow];
        NSString* selectUserId = user.ID;
        
        MTGroupChangeMemberAPI* deleteMemberAPI = [[MTGroupChangeMemberAPI alloc] init];
        NSString* myID = [[DDClientState shareInstance]userID];
        NSArray* array = @[_groupEntity.ID,@[selectUserId],@(GroupModifyTypeGroupModifyTypeDel),myID];
        [deleteMemberAPI requestWithObject:array Completion:^(id response, NSError *error) {
        
            if (!error)
            {
                if (response)
                {
                    NSString* groupID = response[@"groupID"];
                    NSArray* userIDs = response[@"userIDs"];
                    MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:groupID];
                    group.groupUserIds = [[NSMutableArray alloc] initWithArray:userIDs];
                    [[MTDatabaseUtil instance] insertGroups:@[group]];
                }
            }
        }];
    }
}

- (void)reloadContactListTableView
{
    [self.module sortGroupUserCompletion:^{
        
    }];
    [self updateTitle];
    [_contactListTableView reloadData];

}

#pragma mark
#pragma kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:DD_USER_ONLINE_STATE_KEYPATH]) {
        [self reloadContactListTableView];
    }
    else if ([keyPath isEqualToString:@"groupUserIds"])
    {
        [self.module updateData];
        [self reloadContactListTableView];
    }
}

@end
