//
//  DDMessageReviewContactsViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageReviewContactsViewController.h"
#import "DDMessageReviewContactsCellView.h"
//#import "DDDatabaseUtil.h"
@interface DDMessageReviewContactsViewController ()

- (void)p_clickTableView;

@end

@implementation DDMessageReviewContactsViewController
{
    NSMutableArray* _contacts;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)updateContacts:(NSArray*)contacts
{
//    if (_contacts)
//    {
//        _contacts = nil;
//    }
//    _contacts = contacts;
//    [_tableView reloadData];
//    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
//    if (self.delegate && [contacts count] > 0)
//    {
//        [self.delegate contactsViewController:self selectObject:contacts[0]];
//    }
}

- (id)selectedContact
{
    NSInteger selectedRow = [_tableView selectedRow];
    id object = _contacts[selectedRow];
    return object;
}

- (void)awakeFromNib
{
    _contacts = [[NSMutableArray alloc] init];
    [_tableView setTarget:self];
    [_tableView setAction:@selector(p_clickTableView)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

#pragma mark NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_contacts count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 38;
}
- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = [tableColumn identifier];
    DDMessageReviewContactsCellView* cell = (DDMessageReviewContactsCellView*)[tableView makeViewWithIdentifier:identifier owner:self];
    id object = _contacts[row];
    [cell configWithObject:object];
    return cell;
}

#pragma mark privateAPI
- (void)p_clickTableView
{
    NSInteger clickRow = [_tableView clickedRow];
    id object  = _contacts[clickRow];
    if (self.delegate)
    {
        [self.delegate contactsViewController:self selectObject:object];
    }
}
@end
