/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */


@interface NSBezierPath (AIBezierPathAdditions) 

#pragma mark Rounded rectangles

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius;
+ (NSBezierPath *)bezierPathRoundedRectOfSize:(NSSize)backgroundSize;
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)bounds;
+ (NSBezierPath *)bezierPathWithRoundedTopCorners:(NSRect)rect radius:(CGFloat)radius;
+ (NSBezierPath *)bezierPathWithRoundedBottomCorners:(NSRect)rect radius:(CGFloat)radius;

#pragma mark Arrows

/* default metrics of the arrow (as returned by +bezierPathWithArrow):
 *    ^
 *   / \
 *  /   \
 * /_   _\ ___
 *   | |    | shaft length multiplier:
 *   | |    | 1.0
 *   | |    | equals shaft length:
 *   |_|   _|_0.5
 *
 *   default shaft width: 1/3
 * the bounds of this arrow are { { 0, 0 }, { 1, 1 } }.
 *
 * the other three methods allow you to override either or both of these metrics.
 */
+ (NSBezierPath *)bezierPathWithArrowWithShaftLengthMultiplier:(CGFloat)shaftLengthMulti shaftWidth:(CGFloat)shaftWidth;
+ (NSBezierPath *)bezierPathWithArrowWithShaftLengthMultiplier:(CGFloat)shaftLengthMulti;
+ (NSBezierPath *)bezierPathWithArrowWithShaftWidth:(CGFloat)shaftWidth;
+ (NSBezierPath *)bezierPathWithArrow;

#pragma mark Nifty things

//these three are in-place. they return self, so that you can do e.g. [[NSBezierPath bezierPathWithArrow] flipVertically].
- (NSBezierPath *)flipHorizontally;
- (NSBezierPath *)flipVertically;
- (NSBezierPath *)scaleToSize:(NSSize)newSize;

//these three return an autoreleased copy.
- (NSBezierPath *)bezierPathByFlippingHorizontally;
- (NSBezierPath *)bezierPathByFlippingVertically;
- (NSBezierPath *)bezierPathByScalingToSize:(NSSize)newSize;

@end
