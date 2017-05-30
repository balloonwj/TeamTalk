//
//  EGOImageView.m
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

#import "EGOImageView.h"
#import "EGOImageLoader.h"
#import "MTUserEntity.h"
#import "EGOCache.h"


@implementation EGOImageView
@synthesize imageURL, placeholderImage, delegate,onlineState,imageIndex,fromUserId;

- (id)initWithPlaceholderImage:(NSImage*)anImage {
	return [self initWithPlaceholderImage:anImage delegate:nil];
}

- (id)initWithPlaceholderImage:(NSImage*)anImage delegate:(id<EGOImageViewDelegate>)aDelegate {
	if(self = [super init]) {
		self.placeholderImage = anImage;
		self.delegate = aDelegate;
        onlineState = UserStatTypeUserStatusOffline ;
        imageIndex=0;
	}
	
	return  self;
}


- (void)setImageURL:(NSURL *)aURL {
	if(imageURL) {
		[[EGOImageLoader sharedImageLoader] removeObserver:self forURL:imageURL];
		[imageURL release];
		imageURL = nil;
	}
	
	if(!aURL) {
        if(UserStatTypeUserStatusOffline==onlineState && self.placeholderImage){
            //先不用灰色处理
          //  self.image = GrayImageFromNSImageWithAlpha(self.placeholderImage);
            self.image = self.placeholderImage;
        }else{
            self.image = self.placeholderImage;
        }

		imageURL = nil;
		return;
	} else {
		imageURL = [aURL retain];
	}

	[[EGOImageLoader sharedImageLoader] removeObserver:self];
	NSImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
	
	if(anImage) {
        if(UserStatTypeUserStatusOffline==onlineState){
           // self.image = GrayImageFromNSImageWithAlpha(anImage);
            self.image = anImage;
        }else{
            self.image = anImage;
        }

		// trigger the delegate callback if the image was found in the cache
		if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
			[self.delegate imageViewLoadedImage:self];
		}
	} else {
        if(UserStatTypeUserStatusOffline==onlineState){
            //self.image = GrayImageFromNSImageWithAlpha(self.placeholderImage);
             self.image = self.placeholderImage;
        }else{
            self.image = self.placeholderImage;
        }
	}
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
	[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
	[[EGOImageLoader sharedImageLoader] removeObserver:self forURL:self.imageURL];
}

- (void)imageLoaderDidLoad:(NSNotification*)notification {
    
    /*
     NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(connection.imageURL)
     object:self
     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",connection.imageURL,@"imageURL",nil]];
     */
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;

	NSImage* anImage = [[notification userInfo] objectForKey:@"image"];
   // NSString *imageURL =[[notification userInfo] objectForKey:@"imageURL"];
    if(UserStatTypeUserStatusOffline==onlineState){
       // self.image = GrayImageFromNSImageWithAlpha(anImage);
          self.image = anImage;
    }else{
        self.image = anImage;
    }
	[self setNeedsDisplay];
    
	if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
		[self.delegate imageViewLoadedImage:self];
	}	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
	
	if([self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) {
		[self.delegate imageViewFailedToLoadImage:self error:[[notification userInfo] objectForKey:@"error"]];
	}
}

-(NSString *)imageLocalPath{
    NSString *urlDescription =[imageURL description];
    NSRange firstPoint = [urlDescription rangeOfString:@"." options:0 range:NSMakeRange(0, 15)];
    NSString* correctURLKey = [urlDescription substringFromIndex:firstPoint.location];
    
     NSString *localPath=[[EGOCache currentCache] pathForKey:[NSString stringWithFormat:@"DDImageLoader-%lu.png", [correctURLKey hash]]];
    return localPath;
}

- (void)loadImageWithURL:(NSURL*)url setplaceholderImage:(NSString*)placeholderImageName
{
    if ([[url description] length] == 0)
    {
        [self setImage:[NSImage imageNamed:placeholderImageName]];
    }
    else
    {
        [self setPlaceholderImage:[NSImage imageNamed:placeholderImageName]];
        [self setImageURL:url];
    }
}

#pragma mark -
- (void)dealloc {
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
	self.delegate = nil;
	self.imageURL = nil;
	self.placeholderImage = nil;
    self.fromUserId=nil;
    [super dealloc];
}


///////////////////////////////////////////

#pragma mark -
#pragma mark image grey


CGImageRef CGImageRefCopyFromNSImage(NSImage* image)
{
	NSSize size = [image size];
	if(size.width == 0 || size.height ==0)
	{
        NSBitmapImageRep * rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
		NSSize imgSize = NSMakeSize([rep pixelsWide],[rep pixelsHigh]);
		[image setSize:imgSize];
	}
    
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef = nil;
    if(imageData)
    {
        CGImageSourceRef imageSource = 	CGImageSourceCreateWithData((__bridge CFDataRef)(imageData),  NULL);	 //need release
        imageRef = CGImageSourceCreateImageAtIndex( imageSource, 0, NULL);   //need release by caller
		
		CFRelease(imageSource);
    }
	
    return imageRef;
	
}

CGImageRef SourceDataImageRefCopyFromCGImageRef(CGImageRef img)
{
	CGColorSpaceRef colorspace = NULL;
	CGContextRef context = NULL;
	
	colorspace = CGColorSpaceCreateDeviceGray();  //need release
	size_t pixelsWide = CGImageGetWidth(img);
	size_t pixelsHigh = CGImageGetHeight(img);
	//int	bitmapBytesPerRow = pixelsWide * (enableAlaph ? 4 : 1);
	size_t bitmapBytesPerRow = pixelsWide;
	
	context = CGBitmapContextCreate(NULL,
									pixelsWide,
									pixelsHigh,
									8,
									bitmapBytesPerRow,
									colorspace,
									kCGImageAlphaNone);  //need release
	
	CGRect rect = {{0, 0}, {pixelsWide, pixelsHigh}};
	CGContextDrawImage(context, rect, img);
	
	CGImageRef test = CGBitmapContextCreateImage(context) ;  //need release out
	
	CGColorSpaceRelease(colorspace);
	CGContextRelease(context);
	return test;
}

CGImageRef AlphaDataImageRefCopyFromCGImageRef(CGImageRef img)
{
	CGContextRef context = NULL;
	
	size_t pixelsWide = CGImageGetWidth(img);
	size_t pixelsHigh = CGImageGetHeight(img);
	//int	bitmapBytesPerRow = pixelsWide * (enableAlaph ? 4 : 1);
	size_t bitmapBytesPerRow = pixelsWide ;
	
	context = CGBitmapContextCreate(NULL,
									pixelsWide,
									pixelsHigh,
									8,
									bitmapBytesPerRow,
									NULL,
									kCGImageAlphaOnly);  //need release
	
	CGRect rect = {{0, 0}, {pixelsWide, pixelsHigh}};
	CGContextDrawImage(context, rect, img);
	
	CGImageRef test = CGBitmapContextCreateImage(context) ;  //need release out
	CGContextRelease(context);
	return test;
}


NSImage* GrayImageFromNSImageWithAlpha(NSImage*image)
{
	CGImageRef inImage = CGImageRefCopyFromNSImage(image);  //need release
	CGImageRef imgSourceData = SourceDataImageRefCopyFromCGImageRef(inImage);//need release
	CGImageRef imgAlphaData = AlphaDataImageRefCopyFromCGImageRef(inImage);//need release
	
	CGImageRef imgResultData = CGImageCreateWithMask(imgSourceData, imgAlphaData);//need release
    
	NSImage *imgResult = nsImageFromCGImageRef(imgResultData);
	
	CGImageRelease(inImage);
	CGImageRelease(imgSourceData);
	CGImageRelease(imgAlphaData);
	CGImageRelease(imgResultData);
	
	return imgResult;
}

NSImage* nsImageFromCGImageRef(CGImageRef image)
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    // Create a new image to receive the Quartz image data.
	if(imageRect.size.height ==0 ||imageRect.size.width ==0)
	{
		DDLog(@"nsImageFromCGImageRef should not be here!!!,CGImageRef is %@",image);
	}
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
								  graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    return newImage;
}

@end
