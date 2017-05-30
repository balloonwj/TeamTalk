//
//  DDPreferenceWinController.m
//  Duoduo
//
//  Created by zuoye on 14-2-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDPreferenceWinController.h"

@interface DDPreferenceWinController ()

@end

@implementation DDPreferenceWinController


- (id)init
{
    self = [super init];
    if (self) {
        self = [super initWithWindowNibName:@"DDPreferenceWinController"];
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

@end
