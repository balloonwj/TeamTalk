//
//  DDLoginWindow.m
//  Duoduo
//
//  Created by jianqing.du on 14-2-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginWindow.h"

@implementation DDLoginWindow

@synthesize loginWindowController;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 36) {
        DDLog(@"press enter key");
        [loginWindowController login:nil];
        return YES;
    }
    
    return NO;
}

@end
