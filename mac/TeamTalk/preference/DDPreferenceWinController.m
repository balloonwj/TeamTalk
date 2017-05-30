//
//  DDPreferenceWinController.m
//  Duoduo
//
//  Created by zuoye on 14-2-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//


#import "DDPreferenceWinController.h"
#import "DDUserPreferences.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"



@interface DDPreferenceWinController ()

- (void)n_receiveResignKeyNotification:(NSNotification*)notification;

@end

@implementation DDPreferenceWinController
@synthesize msgSendKey;
@synthesize ckPlayNewMsgSound;
@synthesize showBubbleHint;

+ (instancetype)instance
{
    static DDPreferenceWinController* g_preferenceController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_preferenceController = [[DDPreferenceWinController alloc] init];
    });
    return g_preferenceController;
}

- (id)init
{
    self = [super init];
    if (self) {
        self = [super initWithWindowNibName:@"DDPreferenceWinController"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveResignKeyNotification:) name:NSWindowDidResignKeyNotification object:nil];
    }
    return self;
}
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

    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib{
    [self loadGeneralSetting];
}

-(void)loadGeneralSetting{
    DDUserPreferences *prefernces =  [DDUserPreferences defaultInstance];
    [msgSendKey selectItemAtIndex:[prefernces msgSendKey]];
    [ckPlayNewMsgSound setState: [prefernces playNewMesageSound]];
    [showBubbleHint setState:[prefernces showBubbleHint]];
    //从Preferences.plist里读取默认值.
    // Uncomment the following lines to make Command-Shift-D the default shortcut
   //     MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:0x2 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
   //     [MASShortcut setGlobalShortcut:defaultShortcut forUserDefaultsKey:MASPreferenceKeyShortcut];
    
    // Shortcut view will follow and modify user preferences automatically
        self.showMainWindowShortcutRecorder.associatedUserDefaultsKey = MASShowMainWindowShortcut;
        self.captureScreenShortcutRecorder.associatedUserDefaultsKey = MASCaptureScreenShortcut;
    
    // Activate the global keyboard shortcut if it was enabled last time
   // [prefernces resetShortcutRegistration];

}


- (IBAction)onSettingChanged:(id)sender {
    if (msgSendKey==sender) {
       // NSInteger index = [msgSendKey indexOfSelectedItem];
        
    }else{
        
    }
    
    
    [self saveGeneralSetting];
}


-(void)saveGeneralSetting{
    NSInteger sendIndexKey = [self.msgSendKey indexOfSelectedItem];
    [[DDUserPreferences defaultInstance] setMsgSendKey:(unsigned int)sendIndexKey];
    [[DDUserPreferences defaultInstance] setPlayNewMesageSound:[self.ckPlayNewMsgSound state]];
    [[DDUserPreferences defaultInstance] setShowBubbleHint:[self.showBubbleHint state]];
   // [[self.showMainWindowShortcutRecorder]]
}


#pragma mark privateAPI
- (void)n_receiveResignKeyNotification:(NSNotification *)notification
{
    NSWindow* window = [notification object];
    if ([self.window isEqual:window])
    {
        [self.window close];
    }
}
@end
