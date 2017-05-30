//
//  DDWindowAdditions.h
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

@interface NSWindow (DDWindowAdditions)
- (void)setContentSize:(NSSize)aSize display:(BOOL)displayFlag animate:(BOOL)animateFlag;
@property (readonly, nonatomic) BOOL isBorderless;
- (void)betterCenter;
@property (readonly, nonatomic) CGFloat toolbarHeight;

- (NSResponder *)earliestResponderWhichRespondsToSelector:(SEL)selector andIsNotOfClass:(Class)classToAvoid;
- (NSResponder *)earliestResponderOfClass:(Class)targetClass;
@end