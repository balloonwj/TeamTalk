//
//  DDLoginWindowController.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDLoginWindowController.h"
#import "DDDictionaryAdditions.h"
#import "MTUserEntity.h"
#import "DDAlertWindowController.h"
#import "DDLoginWindow.h"
#import "DDLoginManager.h"

#import "DDLoginWindowControllerModule.h"
#import "DDAppDelegate.h"
#import "NSWindow+Addition.h"


//Preference Keys
#define NEW_USER_NAME		@"New User"		//Default name of a new user
#define LOGIN_WINDOW_NIB	@"LoginSelect"		//Filename of the login window nib


@interface DDLoginWindowController ()
@property (weak) IBOutlet NSView *advancedPanel;

@end

@implementation DDLoginWindowController
{
    BOOL _advancedViewShow;
}


- (DDLoginWindowControllerModule*)module
{
    if (!_module)
    {
        _module = [[DDLoginWindowControllerModule alloc] init];
    }
    return _module;
}

// Internal --------------------------------------------------------------------------------
// init the login controller
- (id)init
{
	if ((self = [super initWithWindowNibName:LOGIN_WINDOW_NIB]))
    {
        DDLoginWindow *loginWindow = (DDLoginWindow *)[self window];
        [loginWindow setLoginWindowController:self];
        
        _advancedViewShow = NO;
	}
	return self;
}

- (void)awakeFromNib
{
    [self.avatarIcon setWantsLayer:YES];
    [self.avatarIcon.layer setMasksToBounds:YES];
    [self.avatarIcon.layer setCornerRadius:self.avatarIcon.bounds.size.width / 2.0];
    [self.window addCloseButtonAtTopLeft];
    [self.window center];
}

#pragma mark login:
- (IBAction)login:(id)sender
{
    //TODO:用户输入合法性检测
    [self.loginButton setHidden:YES];
    [self.loginLoading setHidden:NO];
    [self.loginLoading startAnimation:nil];
    NSString* userName = [_txtUserName stringValue];
    NSString* pass = [_txtPassword stringValue];
    
    NSString *url = [_txtUrl stringValue];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([url length] != 0) {
        [DDLoginManager instance].accessUrl = url;
    }
    
    [self.module loginWithUserName:userName password:pass success:^{
        [self.loginLoading setHidden:YES];
        [self.loginButton setHidden:NO];
        [APP_DELEGATE showMainWindowController];
        
    } failure:^(NSString *info){
        if (!info)
        {
            info = @"用户登录失败";
        }
        [[DDAlertWindowController  defaultControler] showAlertWindow:[self window] title:@"提示" info:info leftBtnName:@"" midBtnName:@"" rightBtnName:@"确定"];
        [self.loginLoading setHidden:YES];
        [self.loginButton setHidden:NO];
    }];
    return;
}

- (IBAction)toCloseTheWindow:(id)sender
{
    [self.window close];
}

// set up the window before it is displayed
- (void)windowDidLoad
{
    [self.loginLoading setHidden:YES];
    
    //Center the window
    [[self window] center];
    
    if(self.module.lastuserName)
       [_txtUserName setStringValue:self.module.lastuserName];
    
    if(self.module.lastpassword)
       [_txtPassword setStringValue:self.module.lastpassword];
    
    NSURL* url = [NSURL URLWithString:self.module.lastavatar];
    [_avatarIcon loadImageWithURL:url setplaceholderImage:@"duoduo"];
    
    [self.txtUserName setFocusRingType:NSFocusRingTypeNone];
    [self.txtPassword setFocusRingType:NSFocusRingTypeNone];
    [self.txtUrl setFocusRingType: NSFocusRingTypeNone];
    
//    [self.advancedPanel setFrame:NSMakeRect(0, 126, 265, 116)];
}


// called as the window closes
- (void)windowWillClose:(id)sender
{
	[super windowWillClose:sender];
}

#pragma mark NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField* object = [obj object];
    if ([object isEqual:_txtUserName])
    {
        //用户名在变，更改用户头像
        NSString* name = [_txtUserName stringValue];
        NSString* avatar = [self.module getAvatarForUserName:name];
        NSURL* avatarURL = [NSURL URLWithString:avatar];
        [_avatarIcon loadImageWithURL:avatarURL setplaceholderImage:@"duoduo"];
    }
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return YES;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"])
    {
        [self login:nil];
        return NO;
    }
    else if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertTab:"])
    {
        [self.txtPassword becomeFirstResponder];
        return NO;
    }
    else
    {
        [textView performSelector:commandSelector withObject:textView];
    }
    return YES;
}

#pragma mark - Advanced
- (IBAction)advancedButtonClick:(id)sender {
    _advancedViewShow = !_advancedViewShow;
//    [self showAdvancedPanel:_advancedViewShow];
}

- (void) showAdvancedPanel: (BOOL) show {
    if (show) {
        [self.advancedPanel setHidden:NO];
        
        NSRect startFrame = self.advancedPanel.frame;
        NSRect endFrame = NSMakeRect(startFrame.origin.x, startFrame.origin.y - startFrame.size.height, startFrame.size.width, startFrame.size.height);
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    self.advancedPanel, NSViewAnimationTargetKey,
                                    [NSValue valueWithRect:startFrame], NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:endFrame], NSViewAnimationEndFrameKey,
                                    nil];
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        animation.duration = 0.75;
        [animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
        [animation startAnimation];
        
//        NSRect winStartFrame = self.window.frame;
//        NSRect winEndFrame = NSMakeRect(winStartFrame.origin.x, winStartFrame.origin.y - self.advancedPanel.frame.size.height, winStartFrame.size.width, winStartFrame.size.height + self.advancedPanel.frame.size.height);
//        NSDictionary *winDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                 self.window, NSViewAnimationTargetKey,
//                                 [NSValue valueWithRect:winStartFrame], NSViewAnimationStartFrameKey,
//                                 [NSValue valueWithRect:winEndFrame], NSViewAnimationEndFrameKey,
//                                 nil];
//        NSViewAnimation *winAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:winDict]];
//        winAnimation.duration = 0.75;
//        [winAnimation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
//        [winAnimation startAnimation];
    } else {
        NSRect startFrame = self.advancedPanel.frame;
        NSRect endFrame = NSMakeRect(startFrame.origin.x, startFrame.origin.y + startFrame.size.height, startFrame.size.width, startFrame.size.height);
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    self.advancedPanel, NSViewAnimationTargetKey,
                                    [NSValue valueWithRect:startFrame], NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:endFrame], NSViewAnimationEndFrameKey,
                                    nil];
        
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        animation.duration = 0.75;
        [animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
        [animation startAnimation];
        
//        NSRect winStartFrame = self.window.frame;
//        NSRect winEndFrame = NSMakeRect(winStartFrame.origin.x, winStartFrame.origin.y + self.advancedPanel.frame.size.height, winStartFrame.size.width, winStartFrame.size.height - self.advancedPanel.frame.size.height);
//        NSDictionary *winDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                 self.window, NSViewAnimationTargetKey,
//                                 [NSValue valueWithRect:winStartFrame], NSViewAnimationStartFrameKey,
//                                 [NSValue valueWithRect:winEndFrame], NSViewAnimationEndFrameKey,
//                                 nil];
//        NSViewAnimation *winAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:winDict]];
//        winAnimation.duration = 0.75;
//        [winAnimation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
//        [winAnimation startAnimation];
    }
}

@end
