//
//  PullToRefreshScrollView.h
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

#import <AppKit/AppKit.h>
#import "PullToRefreshDelegate.h"

#define REFRESH_HEADER_HEIGHT 52.0f


@interface PullToRefreshScrollView : NSScrollView {
	BOOL isRefreshing;
	BOOL overHeaderView;
	
	NSView *refreshHeader;
	NSView *refreshArrow;
    NSView *releaseArrow;
	NSProgressIndicator *refreshSpinner;
	
    id <PullToRefreshDelegate> delegate;
	SEL selector;
}

@property (nonatomic, weak) id delegate;
@property (assign) id target;
@property (assign) SEL selector;
@property (readonly) BOOL isRefreshing;

@property (readonly) NSView *refreshHeader;
@property (readonly) NSProgressIndicator *refreshSpinner;
@property (readonly) NSView *refreshArrow;
@property (readonly) NSView *releaseArrow;

- (void)startLoading;
- (void)stopLoading;

- (BOOL)overRefreshView;
- (void)createHeaderView;
- (void)viewBoundsChanged:(NSNotification*)note;

- (CGFloat)minimumScroll;

- (void)refreshPTRScrollViewContents;

@end
