//
//  AITextAttachmentExtension.h
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

@class EGOImageView;
@interface AITextAttachmentExtension : NSTextAttachment <NSCopying> {
	NSString	*stringRepresentation;
	BOOL	shouldSaveImageForLogging;
	BOOL	hasAlternate;
	NSString	*path;
	NSImage		*image;
	NSString	*imageClass; //set as class attribute in html, used to tell images apart for CSS
	BOOL		shouldAlwaysSendAsText;
}

+ (AITextAttachmentExtension *)textAttachmentExtensionFromTextAttachment:(NSTextAttachment *)textAttachment;

@property (readwrite, nonatomic, copy) NSString *string;
@property (readwrite, nonatomic, copy) NSString *imageClass;
@property (readwrite, nonatomic) BOOL shouldSaveImageForLogging;
@property (readwrite, nonatomic) BOOL hasAlternate;
@property (readwrite, nonatomic, copy) NSString *path;
@property (readwrite, nonatomic) NSImage *image;
@property (unsafe_unretained, readonly, nonatomic) NSImage *iconImage;
@property (readonly, nonatomic) BOOL attachesAnImage;
@property (readwrite, nonatomic) BOOL shouldAlwaysSendAsText;
@property (strong) EGOImageView *egoImageView;
@end
