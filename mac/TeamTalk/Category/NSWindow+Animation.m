//
//  NSWindow+Animation.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NSWindow+Animation.h"
#import <Quartz/Quartz.h>

static NSInteger const numberOfShakes = 20;
static float const durationOfShake = 0.5f;
static float const vigourOfShake = 0.01f;
static float const halfheight = 10;

@implementation NSWindow (Animation)
- (void)beginShakeAnimation
{
    
    CGRect frame = self.frame;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    int index;
    for (index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    
    
    [self setAnimations:@{@"frameOrigin" : shakeAnimation}];
    [[self animator] setFrameOrigin:self.frame.origin];
}

- (void)fadeInAnimation
{
    NSViewAnimation *theAnim;
    NSMutableDictionary* firstViewDict;
    
    {
        // Create the attributes dictionary for the first view.
        firstViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
        
        // Specify which view to modify.
        [firstViewDict setObject:self forKey:NSViewAnimationTargetKey];
        
        // Specify the starting position of the view.
        [firstViewDict setObject:NSViewAnimationFadeInEffect
                          forKey:NSViewAnimationEffectKey];
        
    
    }
    
    // Create the view animation object.
    theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
                                                               arrayWithObjects:firstViewDict,nil]];
    
    // Set some additional attributes for the animation.
    [theAnim setDuration:0.5];    // One and a half seconds.
    [theAnim setAnimationCurve:NSAnimationEaseIn];
    
    // Run the animation.
    [theAnim startAnimation];
    
}
@end
