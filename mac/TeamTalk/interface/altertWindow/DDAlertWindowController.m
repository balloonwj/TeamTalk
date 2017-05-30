//
//  DDAlertWindowController.m
//  Duoduo
//
//  Created by zuoye on 14-1-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAlertWindowController.h"

@interface DDAlertWindowController ()

@end

@implementation DDAlertWindowController

+(id)defaultControler{
    static dispatch_once_t pred = 0;
    __strong static DDAlertWindowController *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[DDAlertWindowController alloc] initWithWindowNibName:@"DDAlertWindowController"]; 
    });
    return _sharedObject;
}



- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {

    }
    return self;
}

- (void)windowDidLoad
{
   // [[self window] center];
    [super windowDidLoad];
}


-(void)showAlertWindow:(NSWindow*)win title:(NSString *)title info:(NSString*)info leftBtnName:(NSString *)leftBtnName midBtnName:(NSString *)midBtnName rightBtnName:(NSString *)rightBtnName{
    
    if (!self.isShow) {
        [[self window]setTitle:title];
        [self setAlertWindowController:win title:title info:info leftBtnName:leftBtnName midBtnName:midBtnName rightBtnName:rightBtnName];
        [NSApp activateIgnoringOtherApps:YES];
        if (self.parentWindow==nil) {
            [NSApp runModalForWindow:self.window];
        }else{
            [win makeKeyAndOrderFront:NO];
            [NSApp beginSheet:self.window modalForWindow:self.parentWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
            [self.window setIsVisible:YES];
        }
    }
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[self window] orderOut:NO];
    [self doOnDidEndWindow];
}

-(void)doOnDidEndWindow {
    self.isShow = NO;
    if([self.delegate respondsToSelector:@selector(didEndWindow:sender:)]){
        [self.delegate didEndWindow:self.alertResult sender:self];
    }
}

-(void)setAlertWindowController:(NSWindow*)win title:(NSString *)title info:(NSString*)info  leftBtnName:(NSString *)leftBtnName midBtnName:(NSString *)midBtnName rightBtnName:(NSString *)rightBtnName{
    self.parentWindow=win;
    [self.tfTitle setStringValue:title];
    [self.tfInfo setStringValue:info];
    [self initButton:self.btnLeft withString:leftBtnName];
    [self initButton:self.btnMiddle withString:midBtnName];
    [self initButton:self.btnRight withString:rightBtnName];
}

-(void)initButton:(NSButton *)btn withString:(NSString *)btnTitle {
    
    if ([btnTitle length]==0) {
        [btn setHidden:YES];
    }else{
        [btn setTitle:btnTitle];
        [btn setHidden:NO];
    }
}

-(void)closeAlertWindow
{
    [self buttonDown:nil];
}

- (IBAction)buttonDown:(NSButton *)sender {
       self.alertResult = sender.tag;
        if (self.parentWindow) {
            [NSApp endSheet:self.window];
        }
        else {
            [NSApp stopModal];
            [self.window orderOut:NO];
            [self doOnDidEndWindow];
        }
}
@end
