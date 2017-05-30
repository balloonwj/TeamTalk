//
//  DDGroupDataWindow.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupDataWindow.h"
#import "DDGroupInfoCell.h"
#import "DDUserInfoManager.h"
#import "DDAlertWindowController.h"
#import "NSWindow+Addition.h"
#import "MTUserEntity.h"
@interface DDGroupDataWindow ()

@end

@implementation DDGroupDataWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setBackgroundColor:[NSColor controlBackgroundColor]];
    [_usersDataTableView setHeaderView:nil];
    [_usersDataTableView setBackgroundColor:[NSColor clearColor]];
    [_usersDataTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.window addCloseButtonAtTopLeft];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setModule:(DDGroupDataModule *)module
{
    if (_module)
    {
        _module = nil;
        _module = module;

    }
    else
    {
        _module = module;
        [_module addObserver:self forKeyPath:@"showGroup" options:0 context:nil];
    }
    
    [_titleTextField setStringValue:[self.module windowTitle]];
}

- (void)dealloc
{
    [_module removeObserver:self forKeyPath:@"showGroup"];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"showGroup"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_titleTextField setStringValue:[self.module windowTitle]];
            [_usersDataTableView reloadData];
        });
    }
}

#pragma mark DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.module rowNumber];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 76;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"DDGroupInfoCell";
    if ([identifier isEqualToString:@"GroupInfoColumn"])
    {
        DDGroupInfoCell* cell = (DDGroupInfoCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        cell.delegate = self;
        NSArray* usersInRow = [self.module usersForRow:row];
        int index = 0;
        while (index < 6)
        {
            MTUserEntity* user = nil;
            if ([usersInRow count] > index)
            {
                user = usersInRow[index];
            }
            [cell setUserAtIndex:index withUser:user];
            index ++;
        }
        return cell;
    }
    return nil;
}

#pragma mark GroupCell delegate
- (void)groupInfoCell:(DDGroupInfoCell *)cell selectUserIndex:(NSInteger)index
{
    NSInteger row = [_usersDataTableView rowForView:cell];
    NSArray* usersInRow = [self.module usersForRow:row];
    MTUserEntity* showUser = usersInRow[index];
    
    [[DDUserInfoManager instance] showUser:showUser forContext:self];
}
@end
