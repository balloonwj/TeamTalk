//
//  NSEvent+DDEventAdditions.h
//  Duoduo
//
//  Created by maye on 13-10-31.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (DDEventAdditions)
+ (BOOL)cmdKey;
+ (BOOL)shiftKey;
+ (BOOL)optionKey;
+ (BOOL)controlKey;
- (BOOL)cmdKey;
- (BOOL)shiftKey;
- (BOOL)optionKey;
- (BOOL)controlKey;
@end
