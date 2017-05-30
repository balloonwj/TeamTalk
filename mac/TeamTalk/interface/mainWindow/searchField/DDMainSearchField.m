//
//  DDMainSearchField.m
//  Duoduo
//
//  Created by zuoye on 14-1-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMainSearchField.h"

@implementation DDMainSearchField


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignKey:) name:@"NSWindowDidResignKeyNotification" object:[self window]];
    }
    return self;
}


-(void)handleResignKey:(NSNotification *)notification{
    if ([self window]== [notification object]) {
        [[self cell] setDrawsBackground:NO];
        [self setNeedsDisplay:YES];
    }
}

+(Class)cellClass{
    return [DDSearchFieldCell class];
}

-(void)setFrameHeight:(CGFloat)h {
    NSRect f = [self frame];
    f.size.height = h;
    [self setFrame:f];
}



-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObject:self];
}
@end
