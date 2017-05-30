//
//  DDIntranetViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetViewController.h"
#import "DDIntranetModule.h"
#import "DDIntranetCell.h"
#import "MTMessageModule.h"
@interface DDIntranetViewController(privateAPI)

- (void)p_clickTheTableView;
- (void)n_receiveP2PIntranetMessage:(NSNotification*)notification;

@end

@implementation DDIntranetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.module loadIntranetsCompletion:^{
            [_tableView reloadData];
        }];
    }
    return self;
}

- (DDIntranetModule*)module
{
    if (!_module)
    {
        _module = [[DDIntranetModule alloc] init];
    }
    return _module;
}

- (void)awakeFromNib
{
    [_tableView setHeaderView:nil];
    [_tableView setTarget:self];
    [_tableView setAction:@selector(p_clickTheTableView)];
}

- (void)selectItemAtIndex:(NSUInteger)index
{
    DDIntranetEntity* intranetEntity = self.module.intranets[0];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
//    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
//    [_tableView scrollRowToVisible:0];
    [self.delegate intranetViewController:self selectIntranetEntity:intranetEntity];
}

#pragma mark DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.module.intranets count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 50;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    NSString* cellIdentifier = @"IntranentCellIdentifier";
    if ([identifier isEqualToString:@"IntranentColumnIdentifier"])
    {
        DDIntranetCell* cell = (DDIntranetCell*)[tableView makeViewWithIdentifier:cellIdentifier owner:self];
        DDIntranetEntity* intranet = self.module.intranets[row];
        [cell configWithIntranet:intranet];
        return cell;
    }
    return nil;
}

#pragma mark -
#pragma mark KVO

#pragma mark -
#pragma mark PrivateAPI
- (void)p_clickTheTableView
{
    NSInteger clickRow = [_tableView selectedRow];
    if (clickRow >= 0)
    {
        DDIntranetEntity* intranet = self.module.intranets[clickRow];
        if (self.delegate)
        {
            [self.delegate intranetViewController:self selectIntranetEntity:intranet];
        }
    }
}

@end
