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

typedef enum {
	AIUnknownFileType = -9999,
	AITIFFFileType = NSTIFFFileType,
    AIBMPFileType = NSBMPFileType,
    AIGIFFileType = NSGIFFileType,
    AIJPEGFileType = NSJPEGFileType,
    AIPNGFileType = NSPNGFileType,
    AIJPEG2000FileType = NSJPEG2000FileType
} AIBitmapImageFileType;


@interface NSImage (AIImageAdditions)

+ (NSImage *)imageNamed:(NSString *)name forClass:(Class)inClass;
+ (NSImage *)imageNamed:(NSString *)name forClass:(Class)inClass loadLazily:(BOOL)flag;

+ (NSImage *)imageForSSL;

+ (AIBitmapImageFileType)fileTypeOfData:(NSData *)inData;
+ (NSString *)extensionForBitmapImageFileType:(AIBitmapImageFileType)inFileType;

- (NSData *)JPEGRepresentation;
- (NSData *)JPEGRepresentationWithCompressionFactor:(float)compressionFactor;
/*!
 * @brief Obtain a JPEG representation which is sufficiently compressed to have a size <= a given size in bytes
 *
 * The image will be increasingly compressed until it fits within maxByteSize. The dimensions of the image are unchanged,
 * so for best quality results, the image should be sized (via -[NSImage(AIImageDrawingAdditions) imageByScalingToSize:])
 * before calling this method.
 *
 * @param maxByteSize The maximum size in bytes
 *
 * @result An NSData JPEG representation whose length is <= maxByteSize, or nil if one could not be made.
 */
- (NSData *)JPEGRepresentationWithMaximumByteSize:(NSUInteger)maxByteSize;
- (NSData *)PNGRepresentation;
- (NSData *)GIFRepresentation;
- (NSData *)BMPRepresentation;
- (NSData *)bestRepresentationByType;
- (NSBitmapImageRep *)largestBitmapImageRep;
- (NSData *)representationWithFileType:(NSBitmapImageFileType)fileType
					   maximumFileSize:(NSUInteger)maximumSize;

/*
 * Writes Application Extension Block and modifies Graphic Control Block for a GIF image
 */
- (void)writeGIFExtensionBlocksInData:(NSMutableData *)data forRepresenation:(NSBitmapImageRep *)bitmap;

/*
 * Properties for a GIF image
 */
- (NSDictionary *)GIFPropertiesForRepresentation:(NSBitmapImageRep *)bitmap;

@end

//Defined in AppKit.framework
@interface NSImageCell(NSPrivateAnimationSupport)
- (BOOL)_animates;
- (void)_setAnimates:(BOOL)fp8;
- (void)_startAnimation;
- (void)_stopAnimation;
- (void)_animationTimerCallback:fp8;
@end
