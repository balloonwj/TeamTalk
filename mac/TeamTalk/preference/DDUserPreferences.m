//
//  DDUserPreferences.m
//  Duoduo
//
//  Created by zuoye on 14-2-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserPreferences.h"
#import "MASShortcut+UserDefaults.h"
#import "MTScreenCaptureModule.h"

@implementation DDUserPreferences

static DDUserPreferences* _instance = nil;

+(DDUserPreferences *)defaultInstance{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        NSString *fileName = [NSString stringWithFormat:@"%@/%@.plist",[duoduo applicationSupportDirectory],PREFERENCES_FILE_NAME];
        _instance = [[self alloc] initWithFileName:fileName];
        [_instance initDefaultSetting];
    });
    
    return _instance;
}

-(void)initDefaultSetting{

}

- (void)resetShortcutRegistration
{

    
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:MASShowMainWindowShortcut handler:^{
            [[[DDMainWindowController instance] window] makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
        }];
    
    

        //截屏快捷键
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:MASCaptureScreenShortcut handler:^{
            [[MTScreenCaptureModule shareInstance] capture:nil];
        }];

        
}

    

-(void)setMsgSendKey:(UInt32) value {
    [self writeUInt32Value:value forKey:@"MsgSendKey"];
}
-(int32_t)msgSendKey {
    return [self readUInt32ValueForKey:@"MsgSendKey"];
}

-(BOOL)playNewMesageSound {
    return [self readBoolValueForKey:@"PlayNewMsgSoundKey" defaultValue:YES];
}
-(void)setPlayNewMesageSound:(BOOL)value {
    [self writeBoolValue:value forKey:@"PlayNewMsgSoundKey"];
}
-(BOOL)showBubbleHint {
    return [self readBoolValueForKey:@"ShowBubbleHintKey" defaultValue:YES];
}
-(void)setShowBubbleHint:(BOOL)value {
    [self writeBoolValue:value forKey:@"ShowBubbleHintKey"];
}


-(MASShortcut *)showMainWindowShortcut {
    NSString *shortcutKey = [self readStringForKey:@"ShowMainWindowShortcut"];
    NSData *data=[shortcutKey dataUsingEncoding:NSUTF8StringEncoding];
    return [MASShortcut shortcutWithData:data];
    //return [self readKeyCombinationForKey:@"ShowMainWindowShortcut" defaultValue:0x700120000];
}
-(void)setShowMainWindowShortcut:(MASShortcut *)shortcut {
    NSString *strShortcut = [[NSString alloc] initWithData:shortcut.data encoding:NSUTF8StringEncoding];
    [self writeString:strShortcut forKey:@"ShowMainWindowShortcut"];
}

-(void)setShortcut:(MASShortcut *)shortcut forKey:(NSString *)key {
  //  NSString *strShortcut = [[NSString alloc] initWithData:shortcut.data encoding:NSUTF8StringEncoding];
    [self writeNSData:shortcut.data forKey:key];
}
 
-(MASShortcut *)ShortcutforKey:(NSString *)key {
  //  NSString *shortcutKey = [self readStringForKey:key];
    NSData *data=[self readNSDataForKey:key];//[shortcutKey dataUsingEncoding:NSUTF8StringEncoding];
    return [MASShortcut shortcutWithData:data];
    //return [self readKeyCombinationForKey:@"ShowMainWindowShortcut" defaultValue:0x700120000];
}

-(void)freeInstance {

    @synchronized(self){
        if (_instance!=Nil) {
            [self save];
            _instance=nil;
        }
    }
}

@end
