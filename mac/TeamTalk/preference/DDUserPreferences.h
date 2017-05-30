//
//  DDUserPreferences.h
//  Duoduo
//
//  Created by zuoye on 14-2-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDOptionsBase.h"
#define PREFERENCES_FILE_NAME @"Preferences"	// preferences file name
#define MASShowMainWindowShortcut  @"ShowMainWindowShortcut"
#define  MASCaptureScreenShortcut  @"CaptureScreenShortcut"

@class MASShortcut;
@interface DDUserPreferences : DDOptionsBase{
    
}
+(DDUserPreferences*)defaultInstance;
-(void)setMsgSendKey:(UInt32) value;
-(int32_t)msgSendKey;
-(BOOL)playNewMesageSound;
-(void)setPlayNewMesageSound:(BOOL)value;
-(BOOL)showBubbleHint;
-(void)setShowBubbleHint:(BOOL)value;
-(MASShortcut *)showMainWindowShortcut ;
-(void)setShowMainWindowShortcut:(MASShortcut *)shortcut ;
-(void)setShortcut:(MASShortcut *)shortcut forKey:(NSString *)key;
-(MASShortcut *)ShortcutforKey:(NSString *)key ;
- (void)resetShortcutRegistration;
@end
