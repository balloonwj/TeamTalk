//
//  DDLoginWindowController.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDWindowController.h"

@class DDLoginWindowControllerModule;

@interface DDLoginWindowController : DDWindowController<NSTableViewDelegate,NSTableViewDataSource,NSControlTextEditingDelegate>
{
}

@property (weak) IBOutlet NSTextField *txtUserName;
@property (weak) IBOutlet NSSecureTextField *txtPassword;
@property (weak) IBOutlet NSTextField *txtUrl;
@property (weak) IBOutlet EGOImageView *avatarIcon;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSProgressIndicator *loginLoading;
@property (weak) IBOutlet NSButton *advancedButton;

@property (nonatomic,retain)DDLoginWindowControllerModule* module;

- (IBAction)login:(id)sender;
- (IBAction)toCloseTheWindow:(id)sender;
@end