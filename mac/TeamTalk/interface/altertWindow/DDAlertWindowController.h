//
//  DDAlertWindowController.h
//  Duoduo
//
//  Created by zuoye on 14-1-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DDAlertWindowDelegate <NSObject>

@optional
-(void)didEndWindow:(NSInteger)alertResult sender:(id)sender;

@end

@interface DDAlertWindowController : NSWindowController
@property (assign) NSInteger tag;
@property (assign) BOOL isShow;
@property (weak) NSWindow *parentWindow;
@property (assign) NSInteger alertResult;
@property (weak) IBOutlet NSButton *btnLeft;
@property (weak) IBOutlet NSButton *btnMiddle;
@property (weak) IBOutlet NSButton *btnRight;
@property (weak) IBOutlet NSTextField *tfInfo;
@property (weak) IBOutlet NSTextField *tfTitle;
@property (weak) id<DDAlertWindowDelegate> delegate;
- (IBAction)buttonDown:(id)sender;
@property (strong) IBOutlet NSWindow *alertWindow;

+(id)defaultControler;

-(void)setAlertWindowController:(NSWindow*)win title:(NSString *)title info:(NSString*)info  leftBtnName:(NSString *)leftBtnName midBtnName:(NSString *)midBtnName rightBtnName:(NSString *)rightBtnName;
-(void)showAlertWindow:(NSWindow*)win title:(NSString *)title info:(NSString*)info leftBtnName:(NSString *)leftBtnName midBtnName:(NSString *)midBtnName rightBtnName:(NSString *)rightBtnName;
-(void)closeAlertWindow;

@end
