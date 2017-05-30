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

#import "AIWindowControllerAdditions.h"


@implementation NSWindowController (AIWindowControllerAdditions)

- (BOOL) canCustomizeToolbar
{
	return YES; //default implementation, should be overridden.
}

/*!
 * @brief Returns NO if another window should avoid taking over 
 * the key window from this controller without direct user interaction.
 *
 * Defaults to YES, allowing other windows to become the key window.
 * @see AIWindowController::showWindowInFrontIfAllowed:
 */
- (BOOL) shouldResignKeyWindowWithoutUserInput
{
	return YES;
}

@end
