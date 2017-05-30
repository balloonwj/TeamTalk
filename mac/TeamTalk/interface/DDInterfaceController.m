//
//  DDInterfaceController.m
//  Duoduo
//
//  Created by maye on 13-11-19.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDInterfaceController.h"
#import "DDWindowAdditions.h"
#import "DDChattingInputView.h"
#import "DDMessageReviewWindowController.h"


NSString* const notificationScreenCaptureOK = @"Notification_screen_capture_ok";


@implementation DDInterfaceController

-(id)init{
    if (self =[super init]) {

    }
    
    return self;
}

-(void)awakeFromNib{
    [_exitDuoDuo setTarget:nil];
    [_fileManagerWindowMenuItem setTarget:self];
    [_fileManagerWindowMenuItem setAction:@selector(showFileManagerWindow:)];
    [_fileManagerWindowMenuItem setEnabled:YES];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_screenCaptureOk:) name:notificationScreenCaptureOK object:nil];
}

//------------------------------------------------------------------------

- (void)p_screenCaptureOk:(NSNotification*)notification
{
    [self paste:nil];
    
}

- (IBAction)paste:(id)sender{
    [self _pasteWithPreferredSelector:@selector(pasteAsPlainTextWithTraits:) sender:sender];
}
- (void)_pasteWithPreferredSelector:(SEL)selector sender:(id)sender{
    NSWindow	*keyWin = [[NSApplication sharedApplication] keyWindow];
	NSResponder	*responder;
    
	//First, look for a responder which can handle the preferred selector
	if (!(responder = [keyWin earliestResponderWhichRespondsToSelector:selector
                                                       andIsNotOfClass:NSClassFromString(@"WebHTMLView")])) {
		//No responder found.  Try again, looking for one which will respond to paste:
		selector = @selector(paste:);
		responder = [keyWin earliestResponderWhichRespondsToSelector:selector
                                                     andIsNotOfClass:NSClassFromString(@"WebHTMLView")];
	}
    
	//Sending pasteAsRichText: to a non rich text NSTextView won't do anything; change it to a generic paste:
	/*
    if ([responder isKindOfClass:[NSTextView class]] && ![(NSTextView *)responder isRichText]) {
		selector = @selector(paste:);
	}
    */
	if (selector) {
		[keyWin makeFirstResponder:responder];
		[responder performSelector:selector
						withObject:sender];
	}
    
}

-(void)showPreferenceWindow:(id)sender{
    [[DDPreferenceWinController instance] showWindow:self];
}

- (IBAction)newDD:(id)sender {
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    NSURL *bundleURL = [[NSRunningApplication currentApplication] bundleURL];
    [workSpace launchApplicationAtURL:bundleURL options:NSWorkspaceLaunchNewInstance configuration: [NSDictionary dictionary] error:nil];
}

- (IBAction)showWindowMenuItems
{
    [_fileManagerWindowMenuItem setEnabled:YES];
}

- (IBAction)showFileManagerWindow:(id)sender
{
    //TODO:文件传输
}

- (IBAction)showMessageManagerWindow:(id)sender
{
    DDMessageReviewWindowController* messageReviewWindowController = [DDMessageReviewWindowController instance];
    [messageReviewWindowController.window makeKeyAndOrderFront:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem*)theMenuItem
{
    NSString* title = [theMenuItem title];
    if ([title isEqualToString:@"文件管理器"] || [title isEqualToString:@"消息管理器"])
    {
        
        if ([[DDClientState shareInstance] userID])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    BOOL enable = [self respondsToSelector:[theMenuItem action]];
    
    // disable "New" if the window is already up
	return enable;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationScreenCaptureOK object:nil];
}


@end
