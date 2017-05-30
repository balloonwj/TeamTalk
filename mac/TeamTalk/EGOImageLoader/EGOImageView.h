//
//  EGOImageView.h
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//
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

#import <AppKit/AppKit.h>
#import "EGOImageLoader.h"

@protocol EGOImageViewDelegate;
@interface EGOImageView : NSImageView<EGOImageLoaderObserver> {
@private
	NSURL* imageURL;
	NSImage* placeholderImage;
	id<EGOImageViewDelegate> delegate;
    NSInteger onlineState;
    NSUInteger imageIndex;
    NSString *fromUserId;
}

- (id)initWithPlaceholderImage:(NSImage*)anImage; // delegate:nil
- (id)initWithPlaceholderImage:(NSImage*)anImage  delegate:(id<EGOImageViewDelegate>)aDelegate;
@property(nonatomic,retain) NSURL* imageURL;
@property(nonatomic,retain) NSImage* placeholderImage;
@property(nonatomic,assign) id<EGOImageViewDelegate> delegate;
@property(nonatomic)NSInteger onlineState;
@property (nonatomic,retain) NSString *fromUserId;
@property NSUInteger imageIndex;
-(NSString *)imageLocalPath;

- (void)loadImageWithURL:(NSURL*)url setplaceholderImage:(NSString*)placeholderImage;
@end

@protocol EGOImageViewDelegate<NSObject>
@optional
- (void)imageViewLoadedImage:(EGOImageView*)imageView;
- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error;
@end