//
//  NSEvent+DDEventAdditions.m
//  Duoduo
//
//  Created by maye on 13-10-31.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "NSEvent+DDEventAdditions.h"

@implementation NSEvent (DDEventAdditions)
+ (BOOL)cmdKey{
    return ([NSEvent modifierFlags] & NSCommandKeyMask) != 0;
}

+ (BOOL)shiftKey{
    return ([NSEvent modifierFlags] & NSShiftKeyMask) != 0;
}

+ (BOOL)optionKey{
    return ([NSEvent modifierFlags] & NSAlternateKeyMask) != 0;
}

+ (BOOL)controlKey{
    return ([NSEvent modifierFlags] & NSControlKeyMask) != 0;
}

- (BOOL)cmdKey{
    return ([self modifierFlags] & NSCommandKeyMask) != 0;
}

- (BOOL)shiftKey{
    return ([self modifierFlags] & NSShiftKeyMask) != 0;
}

- (BOOL)optionKey{
    return ([self modifierFlags] & NSAlternateKeyMask) != 0;
}

- (BOOL)controlKey{
    return ([self modifierFlags] & NSControlKeyMask) != 0;
}

@end
