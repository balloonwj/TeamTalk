//
//  DDPreferenceWinController.h
//  Duoduo
//
//  Created by zuoye on 14-2-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//


#import "MASShortcutView.h"
#define PREFERENCES_FILE_NAME @"Preferences"	//preferences file name

@interface DDPreferenceWinController : NSWindowController
@property (weak) IBOutlet NSPopUpButton *msgSendKey;
@property (weak) IBOutlet NSButton *ckPlayNewMsgSound;
@property (weak) IBOutlet NSButton *showBubbleHint;

@property (weak) IBOutlet MASShortcutView *showMainWindowShortcutRecorder;
@property (weak) IBOutlet MASShortcutView *captureScreenShortcutRecorder;

+ (instancetype)instance;

- (IBAction)onSettingChanged:(id)sender;

@end
