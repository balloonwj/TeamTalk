//
//  DDGroupViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupViewController.h"
#import "DDGroupVCModule.h"
#import "DDGroupCell.h"
@interface DDGroupViewController ()

- (void)p_addObserver;
- (void)p_clickTheTableView;

@end

@implementation DDGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self p_addObserver];
    }
    return self;
}

- (void)awakeFromNib
{
    [_tableView setHeaderView:nil];
    [_tableView setTarget:self];
    [_tableView setAction:@selector(p_clickTheTableView)];
    
}

- (DDGroupVCModule*)module
{
    if (!_module)
    {
        _module = [[DDGroupVCModule alloc] init];
    }
    return _module;
}

- (void)dealloc
{
    [[DDClientState shareInstance] removeObserver:self forKeyPath:DD_DATA_STATE_KEYPATH];
}

#pragma mark - public
- (void)selectGroup:(MTGroupEntity*)group
{
    if ([self.module.groups containsObject:group]) {
        NSInteger row = [self.module indexAtGroups:group];
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [[DDMainWindowController instance] openGroupChatWithGroup:group.ID];
    }
}

- (void)selectRow:(NSUInteger)row
{
    if ([self.module.groups count] > row)
    {
        MTGroupEntity* group = self.module.groups[row];
        [self selectGroup:group];
    }
}

#pragma mark DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.module.groups count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 50;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"GroupCellIdentifier";
    if ([identifier isEqualToString:@"GroupColumnIdentifier"])
    {
        DDGroupCell* cell = (DDGroupCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        if (!cell)
        {
            NSNib* nib = [[NSNib alloc] initWithNibNamed:@"DDDepartmentTableViewCell" bundle:nil];
            [tableView registerNib:nib forIdentifier:cellIdentifier];
        }
        cell = (DDGroupCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        MTGroupEntity* group = self.module.groups[row];
        [cell configWithGroup:group];
        return cell;
    }
    return nil;
}

#pragma mark -
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_DATA_STATE_KEYPATH])
    {
        DDDataState oldDataState = [change[@"old"] intValue];
        DDDataState newDataState = [change[@"new"] intValue];
        if (!(oldDataState & DDLocalGroupDataReady) && (newDataState & DDLocalGroupDataReady))
        {
            //本地群数据加载完成
            [self.module loadGroups];
            [_tableView reloadData];
        }
        else if(!(oldDataState & DDRemoteFixGroupDataReady) && (newDataState & DDRemoteFixGroupDataReady))
        {
            //服务器端数据加载完成
            [self.module loadGroups];
            [_tableView reloadData];
        }
    }
}

#pragma mark private
- (void)p_clickTheTableView
{
    NSInteger clickRow = [_tableView selectedRow];
    if (clickRow >= 0)
    {
        MTGroupEntity* group = self.module.groups[clickRow];
        if (self.delegate)
        {
            [self.delegate groupViewController:self selectGroup:group];
        }
    }
}

- (void)p_addObserver
{
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_DATA_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}

@end
