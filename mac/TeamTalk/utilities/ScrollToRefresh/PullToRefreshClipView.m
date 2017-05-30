//
//  PullToRefreshClipView.m
//  PullToRefresh
//
//  Created by Vincent Mac on 2/27/12.
//  Copyright (c) 2012 Vincent Mac, Simplicity.io.

//  Copyright (c) 2011 by Alex Zielenski.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

//  Code Modeled from:
//  Leah Culver - PullToRefresh https://github.com/leah/PullToRefresh
//  and Alex Zielenski - ScrollToRefresh https://github.com/alexzielenski/ScrollToRefresh

#import "PullToRefreshClipView.h"
#import "PullToRefreshScrollView.h"

@implementation PullToRefreshClipView

// this method determines the "elasticity" of the scroll view or how high it can scroll without resistence
- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin {
	NSPoint constrained = [super constrainScrollPoint:proposedNewOrigin];
	CGFloat scrollValue = proposedNewOrigin.y; // this is the y value where the top of the document view is
	BOOL over = scrollValue <= self.minimumScroll;
	
	if (self.isRefreshing && scrollValue <= 0) { // if we are refreshing
		if (over) // and if we are scrolled above the refresh view
			proposedNewOrigin.y = 0 - self.headerView.frame.size.height; // constrain us to the refresh view
		return NSMakePoint(constrained.x, proposedNewOrigin.y);
	}
	return constrained;
}

- (BOOL)isFlipped {
	return YES;
}

// this is to make scrolling feel more normal so that the spinner is within the scrolled area
- (NSRect)documentRect {
	NSRect sup = [super documentRect];
	if (self.isRefreshing) {
		sup.size.height += self.headerView.frame.size.height;
		sup.origin.y -= self.headerView.frame.size.height;
	}
	return sup;
}

- (BOOL)isRefreshing {
	return [(PullToRefreshScrollView *)self.superview isRefreshing];
}

- (NSView*)headerView {
	return [(PullToRefreshScrollView *)self.superview refreshHeader];
}

- (CGFloat)minimumScroll {
	return [(PullToRefreshScrollView *)self.superview minimumScroll];
}

@end
