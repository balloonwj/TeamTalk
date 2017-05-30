//
//  DDLeftBarItem.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLeftBarItem.h"
#import "DDCornerRadiusTextField.h"
@interface DDLeftBarItem(privateAPI)

- (void)p_selectedTheItem:(id)sender;

@end

@implementation DDLeftBarItem
{
    NSImage* _selectedImage;
    NSImage* _unselectedImage;
    
    DDCornerRadiusTextField* _hasMessageRed;
}

- (instancetype)initWithFrame:(NSRect)frameRect
                selectedImage:(NSImage*)selectedImage
              unSelectedImage:(NSImage*)unselectedImage
                          tag:(NSInteger)tag
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _selectedImage = selectedImage;
        _unselectedImage = unselectedImage;
        [self setImage:_unselectedImage];
        NSButton* button = [[NSButton alloc] initWithFrame:frameRect];
        [button setBordered:NO];
        [button setTarget:self];
        [button setAction:@selector(p_selectedTheItem:)];
        [button setTitle:nil];
        [button setTransparent:YES];
        [self addSubview:button];
        
        _hasMessageRed = [[DDCornerRadiusTextField alloc] initWithFrame:CGRectMake(45, 50, 8, 8)];
        [_hasMessageRed setBackgroundColor:[NSColor clearColor]];
        [_hasMessageRed setBordered:NO];
        [_hasMessageRed setFont:[NSFont systemFontOfSize:12]];
        [_hasMessageRed setEditable:NO];
        [_hasMessageRed setCornerRadius:4];
        [_hasMessageRed setHidden:YES];
        [self addSubview:_hasMessageRed];
        self.tag = tag;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        [self setImage:_selectedImage];
    }
    else
    {
        [self setImage:_unselectedImage];
    }
}

- (void)hasUnreadMessage:(NSInteger)unreadMessageCount
{
    NSString* title = [NSString stringWithFormat:@"%li",unreadMessageCount];
    [_hasMessageRed setStringValue:title];
    
    BOOL hidden = unreadMessageCount == 0 ? YES : NO;
    [_hasMessageRed setHidden:hidden];
}

#pragma mark - privateAPI
- (void)p_selectedTheItem:(id)sender
{
    [self setSelected:YES];
    [self.delegate selectedItem:self];
}
@end
