//
//  DDSearchViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSearchViewController.h"
#import "DDSearchResultCell.h"

static CGFloat const rowHeight = 36;
@interface DDSearchViewController(PrivateAPI)

- (void)p_doubleClickTheTableView:(id)sender;

@end

@implementation DDSearchViewController
{
    NSArray* _resultList;
}


- (void)awakeFromNib
{
    [_tableView setHeaderView:nil];
    [self.view.layer setShadowColor:[NSColor blackColor].CGColor];
    [self.view.layer setShadowOffset:CGSizeMake(10, 10)];
    [_tableView setTarget:self];
    
    [_tableView setDoubleAction:@selector(p_doubleClickTheTableView:)];
}

#pragma mark public
- (void)setShowData:(NSArray *)data
{
    _resultList = data;
    [_tableView reloadData];
}

- (CGFloat)rowHeight
{
    return  rowHeight;
}

- (void)selectNext
{
    NSInteger selectedRow = [_tableView selectedRow];
    if ([_resultList count] > selectedRow + 1)
    {
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow + 1] byExtendingSelection:NO];
        [_tableView scrollRowToVisible:selectedRow + 1];
    }
}

- (void)selectLast
{
    NSInteger selectedRow = [_tableView selectedRow];
    if (selectedRow <= 0)
    {
        [_tableView deselectRow:0];
    }
    else
    {
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow - 1] byExtendingSelection:NO];
        [_tableView scrollRowToVisible:selectedRow - 1];
    }
}

- (id)selectedObject
{
    NSInteger selectedRow = [_tableView selectedRow];
    selectedRow = selectedRow < 0 ? 0 : selectedRow;

    return _resultList[selectedRow];
}

#pragma mark TableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_resultList count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return rowHeight;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"SearchResultCellIdentifier";
    if ([identifier isEqualToString:@"ResultListColumnIdentifier"])
    {
        DDSearchResultCell* cell = (DDSearchResultCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        id object = _resultList[row];
        [cell configeWithObject:object];
        return cell;
    }
    return nil;
}

- (void)p_doubleClickTheTableView:(id)sender
{
    NSInteger selectedRow = [_tableView selectedRow];
    selectedRow = selectedRow < 0 ? 0 : selectedRow;
    
    id object = _resultList[selectedRow];
    if (self.delegate)
    {
        [self.delegate selectTheSearchResultObject:object];
    }
}

@end
