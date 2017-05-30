//
//  DDWindowController.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDWindowController : NSWindowController<NSWindowDelegate>{
    
}
- (void)showOnWindow:(id)parentWindow;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)closeWindow:(id)sender;
- (BOOL)windowShouldClose:(id)sender;
- (NSString *)duoduoFrameAutosaveName;
- (NSString *)savedFrameString;
- (NSRect)savedFrameFromString:(NSString *)frameString;
- (void)windowDidLoad;
- (void)showWindowInFrontIfAllowed:(BOOL)inFront;

@end
