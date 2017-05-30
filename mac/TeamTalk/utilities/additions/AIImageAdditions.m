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

#import "AIImageAdditions.h"

@interface NSImage (AIImageAdditions_PRIVATE)

- (NSBitmapImageRep *)bitmapRep;

@end

@implementation NSImage (AIImageAdditions)

+ (NSImage *)imageNamed:(NSString *)name forClass:(Class)inClass loadLazily:(BOOL)flag
{
	NSBundle *ownerBundle;
	
    // Get the bundle
    ownerBundle = [NSBundle bundleForClass:inClass];
	
    return [ownerBundle imageForResource:name];
}

// Returns an image from the owners bundle with the specified name
+ (NSImage *)imageNamed:(NSString *)name forClass:(Class)inClass
{	
	return [self imageNamed:name forClass:inClass loadLazily:NO];
}

+ (NSImage *)imageForSSL
{
	static NSImage *SSLIcon = nil;
	
	if (!SSLIcon) {
		NSBundle *securityInterfaceFramework = [NSBundle bundleWithIdentifier:@"com.apple.securityinterface"];
		
		if (!securityInterfaceFramework) {
			securityInterfaceFramework = [NSBundle bundleWithPath:@"/System/Library/Frameworks/SecurityInterface.framework"];
		}

		SSLIcon = [[NSImage alloc] initByReferencingFile:[securityInterfaceFramework pathForImageResource:@"CertSmallStd"]];
	}
	
	return SSLIcon;
}

+ (AIBitmapImageFileType)fileTypeOfData:(NSData *)inData
{
	const char *data = [inData bytes];
	NSUInteger len = [inData length];
	AIBitmapImageFileType fileType = AIUnknownFileType;
	
	if (len >= 4) {
		if (!strncmp((char *)data, "GIF8", 4))
			fileType = AIGIFFileType;
		else if (!strncmp((char *)data, "\xff\xd8\xff", 3)) /* 4th may be e0 through ef */
			fileType = AIJPEGFileType;
		else if (!strncmp((char *)data, "\x89PNG", 4))
			fileType = AIPNGFileType;
		else if (!strncmp((char *)data, "MM", 2) ||
				 !strncmp((char *)data, "II", 2))
			fileType = AITIFFFileType;
		else if (!strncmp((char *)data, "BM", 2))
			fileType = AIBMPFileType;
	}
	
	return fileType;
}

+ (NSString *)extensionForBitmapImageFileType:(AIBitmapImageFileType)inFileType
{
	NSString *extension = nil;
	
	switch (inFileType) {
		case AIUnknownFileType:
			break;
		case AITIFFFileType:
			extension = @"tif";
			break;
		case AIBMPFileType:
			extension = @"bmp";
			break;
		case AIGIFFileType:
			extension = @"gif";
			break;
		case AIJPEGFileType:
			extension = @"jpg";
			break;
		case AIPNGFileType:
			extension = @"png";
			break;
		case AIJPEG2000FileType:
			extension = @"jp2";
			break;
	}
	
	return extension;
}

// Create and return an opaque bitmap image rep, replacing transparency with [NSColor whiteColor]
- (NSBitmapImageRep *)opaqueBitmapImageRep
{
	NSImage				*tempImage = nil;
	NSBitmapImageRep	*imageRep = nil;
	NSSize				size = [self size];
	
	// Work with a temporary image so we don't modify self
	tempImage = [[NSImage alloc] initWithSize:size];
	
	// Lock before drawing to the temporary image
	[tempImage lockFocus];
	
	// Fill with a white background
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(0, 0, size.width, size.height));
	
	// Draw the image
	[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	// We're done drawing
	[tempImage unlockFocus];
	
	// Find an NSBitmapImageRep from the temporary image
	for (NSImageRep *rep in tempImage.representations) {
		if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
			imageRep = (NSBitmapImageRep *)rep;
		}
	}
	
	// Make one if necessary
	if (!imageRep) {
		imageRep = [NSBitmapImageRep imageRepWithData:[tempImage TIFFRepresentation]];
    }
	
	// 10.6 behavior: Drawing into a new image copies the display's color profile in.
	// Remove the color profile so we don't bloat the image size.
	[imageRep setProperty:NSImageColorSyncProfileData withValue:nil];
	
	return imageRep;
}

- (NSBitmapImageRep *)largestBitmapImageRep
{
	// Find the biggest image
	NSBitmapImageRep *bestRep = nil;
	Class NSBitmapImageRepClass = [NSBitmapImageRep class];
	CGFloat maxWidth = 0.0f;
	
	for (NSImageRep *rep in [self representations]) {
		if ([rep isKindOfClass:NSBitmapImageRepClass]) {
			CGFloat thisWidth = [rep size].width;
			
			if (thisWidth >= maxWidth) {
				// Cast explanation: GCC warns about us returning an NSImageRep here, presumably because it could be some other kind of NSImageRep if we don't check the class.
				// Fortunately, we have such a check. This cast silences the warning.
				bestRep = (NSBitmapImageRep *)rep;
				maxWidth = thisWidth;
			}
		}
	}
	
	// We don't already have one, so forge one from our TIFF representation.
	if (!bestRep) {
		bestRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
	}

	return bestRep;
}

- (NSData *)JPEGRepresentation
{	
	return [self JPEGRepresentationWithCompressionFactor:1.0f];
}

- (NSData *)JPEGRepresentationWithCompressionFactor:(float)compressionFactor
{
	/* JPEG does not support transparency, but NSImage does. We need to create a non-transparent NSImage
	 * before creating our representation or transparent parts will become black. White is preferable.
	 */
	return ([[self opaqueBitmapImageRep] representationUsingType:NSJPEGFileType 
													  properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:(float)compressionFactor] 
																							 forKey:NSImageCompressionFactor]]);	
}
- (NSData *)JPEGRepresentationWithMaximumByteSize:(NSUInteger)maxByteSize
{
	/* JPEG does not support transparency, but NSImage does. We need to create a non-transparent NSImage
	 * before creating our representation or transparent parts will become black. White is preferable.
	 */
	NSBitmapImageRep *opaqueBitmapImageRep = [self opaqueBitmapImageRep];
	NSData *data = nil;
	
	for (float compressionFactor = 0.99f; compressionFactor > 0.4f; compressionFactor -= 0.01f) {
		data = [opaqueBitmapImageRep representationUsingType:NSJPEGFileType 
												  properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionFactor] 
																						 forKey:NSImageCompressionFactor]];
		if (data && ([data length] <= maxByteSize)) {
			break;
		} else {
			data = nil;
		}
	}

	return data;
}

- (NSData *)PNGRepresentation
{
	/* PNG is easy; it supports everything TIFF does, and NSImage's PNG support is great. */
	NSBitmapImageRep *bitmapRep =  [self largestBitmapImageRep];

	return ([bitmapRep representationUsingType:NSPNGFileType properties:nil]);
}

- (NSData *)GIFRepresentation
{
	// GIF requires special treatment, as Apple doesn't allow you to save animations.
	
	NSMutableData *GIFRepresentation = nil;
	NSBitmapImageRep *bitmap = [[self representations] objectAtIndex:0];
	
	if (bitmap && [bitmap isKindOfClass:[NSBitmapImageRep class]]) {
		unsigned frameCount = [[bitmap valueForProperty:NSImageFrameCount] intValue];
		
		if (!frameCount) {
			frameCount = 1;
		}
		
		NSSize size = [self size];
		
		if (size.width > 0 && size.height > 0) {
			NSMutableArray *images = [NSMutableArray array];
			
			for (unsigned i = 0; i < frameCount; i++) {
				// Set current frame
				[bitmap setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithUnsignedInt:i]];
				// Add frame representation
				[images addObject:[NSBitmapImageRep imageRepWithData:[bitmap representationUsingType:NSGIFFileType properties:nil]]];
			}
			
			GIFRepresentation = [NSMutableData dataWithData:[NSBitmapImageRep representationOfImageRepsInArray:images
																									 usingType:NSGIFFileType
																									properties:[self GIFPropertiesForRepresentation:bitmap]]];
			
			// Write GIF Extension Blocks
			[self writeGIFExtensionBlocksInData:GIFRepresentation forRepresenation:bitmap];
		}
	}
	
	return GIFRepresentation;
}

- (NSData *)BMPRepresentation
{
	/* BMP does not support transparency, but NSImage does. We need to create a non-transparent NSImage
	 * before creating our representation or transparent parts will become black. White is preferable.
	 */

	return ([[self opaqueBitmapImageRep] representationUsingType:NSBMPFileType properties:nil]);
}

/*!
 * @brief Returns a GIF representation for GIFs, and PNG represenation for all other types
 */
- (NSData *)bestRepresentationByType
{
	NSData *data = nil;
	NSBitmapImageRep *bitmap = nil;
	
	if ((bitmap = [[self representations] objectAtIndex:0]) &&
		[bitmap isKindOfClass:[NSBitmapImageRep class]] &&
		([[bitmap valueForProperty:NSImageFrameCount] intValue] > 1)) {
		data = [self GIFRepresentation];
	} else {
		data = [self PNGRepresentation];
	}
	
	return data;
}

- (NSBitmapImageRep *)getBitmap
{
	[self lockFocus];
	
	NSSize size = [self size];
	NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
	NSBitmapImageRep *bm = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
	
	[self unlockFocus];
	
	return bm;
}

/*!
 * @brief Retrieve an image rep with a maximum size
 *
 * Returns the NSData of an image representation.
 *
 * @param fileType The NSBitmapImageFileType to be outputted for sizing
 * @param maximumSize The maximum size in bytes for the image
 *
 * @return the NSData representation using fileType
 */
- (NSData *)representationWithFileType:(NSBitmapImageFileType)fileType maximumFileSize:(NSUInteger)maximumSize
{
	NSBitmapImageRep *imageRep = [self largestBitmapImageRep];
	
	// If no rep is found, return nil.
	if (!imageRep)
		return nil;
	
	NSData *data = [imageRep representationUsingType:fileType properties:nil];
	
	// If no maximum size, return the base representation.
	if (!maximumSize)
		return data;
	
	// Ratio of height/width
	CGFloat ratio = (CGFloat)imageRep.pixelsHigh / (CGFloat)imageRep.pixelsWide;
	
	// Loop until we're small enough to fit into our max size
	while (data.length > maximumSize) {
		// New width/height using our ratio
		NSUInteger width = (imageRep.pixelsWide - 100);
		NSUInteger height = ((CGFloat)imageRep.pixelsWide - 100.0f)*ratio;
		
		// Create a new rep with the lowered size
		NSBitmapImageRep *newImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																				 pixelsWide:width
																				 pixelsHigh:height
																			  bitsPerSample:imageRep.bitsPerSample
																			samplesPerPixel:imageRep.samplesPerPixel
																				   hasAlpha:imageRep.hasAlpha
																				   isPlanar:imageRep.isPlanar
																			 colorSpaceName:NSCalibratedRGBColorSpace
																				bytesPerRow:imageRep.bytesPerRow
																			   bitsPerPixel:imageRep.bitsPerPixel];
		
		// Draw the old rep into the new rep
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:newImageRep]];
		[imageRep drawInRect:NSMakeRect(0, 0, width, height)];
		[NSGraphicsContext restoreGraphicsState];
		
		// Override the old rep
		imageRep = newImageRep;
		
		// Grab a new representation
		data = [imageRep representationUsingType:fileType properties:nil];
	}
	
	return data;
}

- (void)writeGIFExtensionBlocksInData:(NSMutableData *)data forRepresenation:(NSBitmapImageRep *)bitmap
{
	// GIF Application Extension Block - 0x21FF0B
	const char *GIFApplicationExtensionBlock = "\x21\xFF\x0B\x4E\x45\x54\x53\x43\x41\x50\x45\x32\x2E\x30\x03\x01\x00\x00\x00";
	// GIF Graphic Control Extension Block - 0x21F904
	NSData *GIFGraphicControlExtensionBlock = [NSData dataWithBytes:"\x00\x21\xF9\x04" length:4];

	NSRange blockRange;
    NSUInteger blockLocation = [data length];
	
	unsigned frameCount = [[bitmap valueForProperty:NSImageFrameCount] intValue];
	unsigned frameDuration;
	unsigned i = 0;
	
	while (!NSEqualRanges(blockRange = [data rangeOfData:GIFGraphicControlExtensionBlock options:NSDataSearchBackwards range:NSMakeRange(0, blockLocation)], NSMakeRange(NSNotFound, 0))) {
		// Set current frame
		[bitmap setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithUnsignedInt:i++]];

		// Frame Duration flag, 1/100 sec
		frameDuration = [[bitmap valueForProperty:NSImageCurrentFrameDuration] floatValue] * 100;

        blockLocation = blockRange.location;
		
		// Replace bytes in Graphic Extension Block
		[data replaceBytesInRange:NSMakeRange(NSMaxRange(blockRange) + 1, 2) withBytes:&frameDuration length:2];

		// Write Application Extension Block
		if (i == frameCount) {
            [data replaceBytesInRange:NSMakeRange(blockRange.location + 1, 0) withBytes:GIFApplicationExtensionBlock length:strlen(GIFApplicationExtensionBlock) + 3];
        }
		
		frameDuration = 0;
    }
}

- (NSDictionary *)GIFPropertiesForRepresentation:(NSBitmapImageRep *)bitmap
{
	NSNumber *frameCount = [bitmap valueForProperty:NSImageFrameCount];

	if (!frameCount) {
		frameCount = [NSNumber numberWithUnsignedInt:1];
	}

	// Setting NSImageLoopCount & NSImageCurrentFrameDuration through - NSDictionary *properties - is not allowed!
	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:frameCount,
																			[NSNumber numberWithUnsignedInt:0],
																			nil]
										forKeys:[NSArray arrayWithObjects:NSImageFrameCount,
																			NSImageCurrentFrame,
																			nil]];
}

@end
