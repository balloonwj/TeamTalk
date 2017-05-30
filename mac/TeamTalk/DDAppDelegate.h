//
//  DDAppDelegate.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDLoginWindowController;
@interface DDAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet DDInterfaceController *interfaceController;
}

@property(nonatomic,strong)DDLoginWindowController* loginWindowController;
@property(nonatomic,strong)NSWindow* showWindow;
- (void)showMainWindowController;

@end




