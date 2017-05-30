//
//  DDSearchFieldController.m
//  Duoduo
//
//  Created by zuoye on 14-1-26.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSearchFieldController.h"
#import "MTUserEntity.h"
#import "MTGroupEntity.h"
#import "MTSessionEntity.h"
#import "DDMainModule.h"
#import "DDHttpModule.h"
#import "NSView+Addition.h"
#import "DDSearchFieldResultCell.h"
#import "DDAlertWindowController.h"
#import "SpellLibrary.h"
#import "MTGroupModule.h"
#import "DDSearch.h"
#import "MTUserModule.h"
#define RESULT_LIST_MAX_HEIGHT                  400
#define CELL_HEIGHT                             50

@interface DDSearchFieldController(PrivateAPI)

- (void)fetchResultListSuccess:(void(^)(NSArray* result))success;
- (NSString*)getIDForObject:(id)sender;


- (void)doubleClickTableView:(id)sender;

- (void)beginChatWithUser:(id)object;
@end

@implementation DDSearchFieldController
{
    NSArray* _resultList;
}

-(void)awakeFromNib{
    _scrollView.layer.cornerRadius = 5;
    _scrollView.layer.masksToBounds = YES;
}

- (dispatch_queue_t)searchQueue
{
    if (!_searchQueue)
    {
        _searchQueue = dispatch_queue_create("com.mogujie.Duoduo.Search", NULL);
    }
    return _searchQueue;
}

#pragma mark -
#pragma mark Keyword search handling

// -------------------------------------------------------------------------------
//	allKeywords:
//
//	This method builds our keyword array for use in type completion (dropdown list
//	in NSSearchField).
// -------------------------------------------------------------------------------
- (NSArray *)allKeywords
{
    if (allKeywords == nil)
	{
        
        //导入所有的用户
        allKeywords = [NSMutableArray arrayWithArray:[[MTUserModule shareInstance] getAllOriginEntity ]];
        
        if (userIdByName==nil) {
            userIdByName =[[NSMutableDictionary alloc] init];
        }
        [allKeywords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MTUserEntity* user = (MTUserEntity*)obj;
            NSString* userID = user.ID;
            NSString* userName = user.name;
            [userIdByName setObject:userID forKey:userName];
        }];
        //添加所有组别
        /*
        DDGroupModule* groupModule = getDDGroupModule();
        NSArray* groups = [groupModule getAllGroups];
        [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GroupEntity* group = (GroupEntity*)obj;
            [allKeywords addObject:group];
            [userIdByName setObject:group.groupId forKey:group.name];
            [[SpellLibrary instance] addSpellForObject:group];
        }];

        
        NSArray* fixedGroups = [groupModule getAllFixedGroups];
        [fixedGroups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GroupEntity* group = (GroupEntity*)obj;
            if (![allKeywords containsObject:group])
            {
                [allKeywords addObject:group];
                [userIdByName setObject:group.groupId forKey:group.name];
                [[SpellLibrary instance] addSpellForObject:group];
            }
        }];
         */
    }
    return allKeywords;
}

// -------------------------------------------------------------------------------
//	control:textView:completions:forPartialWordRange:indexOfSelectedItem:
//
//	Use this method to override NSFieldEditor's default matches (which is a much bigger
//	list of keywords).  By not implementing this method, you will then get back
//	NSSearchField's default feature.
// -------------------------------------------------------------------------------
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(int*)index
{
    NSMutableArray*	matches = NULL;
    NSString*		partialString;
    NSArray*		keywords;
    NSUInteger	i,count;
    NSString*		string;
    
    partialString = [[textView string] substringWithRange:charRange];
    keywords      = [self allKeywords];
    count         = [keywords count];
    matches       = [NSMutableArray array];
    
    // find any match in our keyword array against what was typed -
	for (i=0; i< count; i++)
	{
        string = [keywords objectAtIndex:i];
        if ([string rangeOfString:partialString
						  options:NSAnchoredSearch | NSCaseInsensitiveSearch
							range:NSMakeRange(0, [string length])].location != NSNotFound)
		{
            [matches addObject:string];
        }
    }
	return matches;
}

// -------------------------------------------------------------------------------
//	control:textView:commandSelector
//
//	Handle all commend selectors that we can handle here
// -------------------------------------------------------------------------------
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveDown:"])
    {
        NSInteger selectedRow = [_tableView selectedRow];
        if (selectedRow < [_resultList count] - 1)
        {
            selectedRow ++;
        }
        else
        {
            selectedRow = 0;
        }
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        [_tableView scrollRowToVisible:selectedRow];
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"moveUp:"])
    {
        NSInteger selectedRow = [_tableView selectedRow];
        if (selectedRow > 0)
        {
            selectedRow --;
        }
        else
        {
            selectedRow = 0;
        }
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        [_tableView scrollRowToVisible:selectedRow];
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"])
    {
        NSInteger selectedRow = _tableView.selectedRow;
        if (selectedRow < 0)
        {
            if ([_resultList count] > 0)
            {
                id object = _resultList[0];
                [self beginChatWithUser:object];
            }
            else
            {
                [self searchOnline:textView.string];
            }
        }
        else
        {
            id object = _resultList[selectedRow];
            [self beginChatWithUser:object];
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

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSPoint mouseLocationInScreen = [NSEvent mouseLocation];
    NSPoint mouseLocationInWindow = [self.searchField.window convertScreenToBase:mouseLocationInScreen];
    if (!CGRectContainsPoint(_scrollView.frame, mouseLocationInWindow))
    {
        [_scrollView setHidden:YES];
    }
    return YES;
}

#pragma mark TableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_resultList count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return CELL_HEIGHT;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"SearchResultCellIdentifier";
    if ([identifier isEqualToString:@"ResultListColumnIdentifier"])
    {
        DDSearchFieldResultCell* cell = (DDSearchFieldResultCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        if (!cell)
        {
            NSNib* nib = [[NSNib alloc] initWithNibNamed:@"DDSearchResultCell" bundle:nil];
            [tableView registerNib:nib forIdentifier:cellIdentifier];
        }
        cell = (DDSearchFieldResultCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        MTUserEntity* user = _resultList[row];
        [cell setImageURL:[NSURL URLWithString:user.avatar]];
        [cell setName:user.name];
        return cell;
    }
    return nil;
}

- (void)searchOnline:(NSString *)userName {
    NSString *selectedUserName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([selectedUserName length]>0) {
       __block NSString *userId = [userIdByName objectForKey:selectedUserName];
        if (userId) {
            
        }else{      //本地查无此人.
            DDHttpModule *module = getDDHttpModule();
            NSMutableDictionary* dictParams = [NSMutableDictionary dictionary];
            [dictParams setObject:selectedUserName forKey:@"uname"];
            [module httpPostWithUri:@"mtalk/user/find" params:dictParams
                            success:^(NSDictionary *result)
             {
                 /*
                  网络上查找用户:{
                  avatar = "http://s6.mogujie.cn/b7/avatar/130927/ba68_kqywqzkwkfbgutcugfjeg5sckzsew_180x180.jpg";
                  status = 2;
                  uid = 1mke0;
                  uname = "\U4fee\U7f57";
                  userType = 1073741824;
                  */
                 userId=[NSString stringWithFormat:@"%@",[result objectForKey:@"uid"]];
                 NSString *userId = [result objectForKey:@"uid"];
                 NSString *name = [result objectForKey:@"uname"];
                 NSString *nick = [result objectForKey:@"uname"];
                 NSString *avatar = [result objectForKey:@"avatar"];
                 //为了区分小仙小侠帐号用.
                 NSInteger userType = (NSInteger)[result objectForKey:@"userType"];
                 //TT_3.0
                 /*
                 UserEntity *user = [[UserEntity alloc] init];
                 user.userId = userId;
                 user.name = name;
                 user.nick = nick;
                 user.avatar = avatar;
//                 user.userRole = userType;
                 [userListModule.recentlyUserIds addObject:user.userId];
                 [userListModule addUser:user];

                */
             }
                            failure:^(StatusEntity *error)
             {
                 [[DDAlertWindowController  defaultControler] showAlertWindow:nil title:@"提示" info:@"查无此人哦！" leftBtnName:@"" midBtnName:@"" rightBtnName:@"确定"];
            DDLog(@"serverUser fail,error code:%ld,msg:%@ userInfo:%@",error.code,error.msg,error.userInfo);
             }];
        }
    }
    [self.searchField setStringValue:@""];
}

- (void)fetchResultListSuccess:(void(^)(NSArray* result))success
{
    dispatch_async(self.searchQueue, ^{
        NSMutableArray*	matches = NULL;
        NSString*		partialString;
        NSArray*		keywords;
        NSUInteger	i,count;
        NSString*		string;
        
        partialString = [_searchField stringValue];
        keywords      = [self allKeywords];
        count         = [keywords count];
        matches       = [NSMutableArray array];
        
        // find any match in our keyword array against what was typed -
        NSMutableArray* matchIDs = [[NSMutableArray alloc] init];
        for (i=0; i< count; i++)
        {
            MTUserEntity* user = [keywords objectAtIndex:i];
            string = user.name;
            if ([string rangeOfString:partialString].length > 0)
            {
                NSString* ID;
                if ([user isKindOfClass:NSClassFromString(@"MTUserEntity")])
                {
                    ID = user.ID;
                }
                else if ([user isKindOfClass:NSClassFromString(@"GroupEntity")])
                {
                    ID = [(MTGroupEntity*)user ID];
                }
                else if ([user isKindOfClass:NSClassFromString(@"SessionEntity")])
                {
                    ID = [(MTSessionEntity*)user sessionID];
                }
                if (![matchIDs containsObject:ID])
                {
                    [matchIDs addObject:ID];
                    [matches addObject:user];
                }
            }
        }
        NSString* partialSpell = [[SpellLibrary instance] getSpellForWord:partialString];
        NSArray* userInSpellLibaray = [[SpellLibrary instance] checkoutForWordsForSpell:partialSpell];
        
        if ([userInSpellLibaray count] > 0)
        {
            [userInSpellLibaray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* objectID = [self getIDForObject:obj];
                if (!objectID)
                {
                    return;
                }
                if (![matchIDs containsObject:objectID]) {
                    [matches addObject:obj];
                    [matchIDs addObject:objectID];
                }
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(matches);
        });
    });
}

- (void)doubleClickTableView:(id)sender
{
    NSInteger selectedRow = [_tableView selectedRow];
    id object = _resultList[selectedRow];
    [self beginChatWithUser:object];
}

- (void)beginChatWithUser:(id)object
{
    [_searchField setStringValue:@""];
    NSString* objectID = [self getIDForObject:object];
    if (!objectID)
    {
        return;
    }
    [_scrollView setHidden:YES];
}

- (NSString*)getIDForObject:(id)sender
{
    NSString* objectID = nil;
    if ([sender isKindOfClass:NSClassFromString(@"MTUserEntity")])
    {
        objectID = [(MTUserEntity*)sender ID];
    }
    else if ([sender isKindOfClass:NSClassFromString(@"MTGroupEntity")])
    {
        objectID = [(MTGroupEntity*)sender ID];
    }
    else if ([sender isKindOfClass:NSClassFromString(@"SessionEntity")])
    {
        objectID =[(MTSessionEntity *)sender sessionID];
    }
    return objectID;
}

@end
