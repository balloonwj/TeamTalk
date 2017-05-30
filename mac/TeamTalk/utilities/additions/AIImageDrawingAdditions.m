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

#import "AIImageDrawingAdditions.h"
#import "AIImageAdditions.h"
#import "AIBezierPathAdditions.h"

@implementation NSImage (AIImageDrawingAdditions)


// Draw this image in a rect, tiling if the rect is larger than the image
- (void)tileInRect:(NSRect)rect
{
    NSSize	size = [self size];
    NSRect	destRect = NSMakeRect(rect.origin.x, rect.origin.y, size.width, size.height);
    CGFloat	top = rect.origin.y + rect.size.height;
    CGFloat	right = rect.origin.x + rect.size.width;
    
    // Tile vertically
    while (destRect.origin.y < top) {
		// Tile horizontally
		while (destRect.origin.x < right) {
			NSRect  sourceRect = NSMakeRect(0, 0, size.width, size.height);
			
			// Crop as necessary
			if ((destRect.origin.x + destRect.size.width) > right) {
				sourceRect.size.width -= (destRect.origin.x + destRect.size.width) - right;
			}
			
			if ((destRect.origin.y + destRect.size.height) > top) {
				sourceRect.size.height -= (destRect.origin.y + destRect.size.height) - top;
			}
			
			// Draw and shift
			[self drawAtPoint:destRect.origin fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
			destRect.origin.x += destRect.size.width;
		}
		
		destRect.origin.y += destRect.size.height;
    }
}

- (NSImage *)imageByScalingToSize:(NSSize)size
{
	return ([self imageByScalingToSize:size fraction:1.0f flipImage:NO proportionally:YES allowAnimation:YES]);
}

- (NSImage *)imageByScalingToSize:(NSSize)size DPI:(CGFloat)dpi
{
	CGFloat backingScaleFactor = dpi / 72.0;
	
	if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
		backingScaleFactor /= [[NSScreen mainScreen] backingScaleFactor];
	}
	
	return ([self imageByScalingToSize:NSMakeSize(size.width * backingScaleFactor, size.height * backingScaleFactor) fraction:1.0f flipImage:NO proportionally:YES allowAnimation:YES]);
}

- (NSImage *)imageByFadingToFraction:(CGFloat)delta
{
	return [self imageByScalingToSize:[self size] fraction:delta flipImage:NO proportionally:NO allowAnimation:YES];
}

- (NSImage *)imageByScalingToSize:(NSSize)size fraction:(CGFloat)delta
{
	return [self imageByScalingToSize:size fraction:delta flipImage:NO proportionally:YES allowAnimation:YES];
}

- (NSImage *)imageByScalingForMenuItem
{
	return [self imageByScalingToSize:NSMakeSize(16,16)
							 fraction:1.0f
							flipImage:NO
					   proportionally:YES
					   allowAnimation:NO];	
}

- (NSImage *)imageByScalingToSize:(NSSize)size fraction:(CGFloat)delta flipImage:(BOOL)flipImage proportionally:(BOOL)proportionally allowAnimation:(BOOL)allowAnimation
{
	NSSize originalSize = [self size];
	
	// Proceed only if size or delta are changing
	if ((NSEqualSizes(originalSize, size)) && (delta == 1.0) && !flipImage) {
		return [self copy];
		
	} else {
		NSImage *newImage;
		NSRect	newRect;
		
		// Scale proportionally (rather than stretching to fit) if requested and needed
		if (proportionally && (originalSize.width != originalSize.height)) {
			if (originalSize.width > originalSize.height) {
				// Give width priority: Make the height change by the same proportion as the width will change
				size.height = originalSize.height * (size.width / originalSize.width);
			} else {
				// Give height priority: Make the width change by the same proportion as the height will change
				size.width = originalSize.width * (size.height / originalSize.height);
			}
		}
		
		newRect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
		newImage = [[NSImage alloc] initWithSize:size];
		
		if (flipImage) {
			[newImage setFlipped:YES];		
		}
		
		NSImageRep *bestRep;
		
		if (allowAnimation &&
			(bestRep = [self bestRepresentationForRect:NSMakeRect(0, 0, self.size.width, self.size.height) context:nil hints:nil]) &&
			[bestRep isKindOfClass:[NSBitmapImageRep class]] && 
			(delta == 1.0) &&
			([[(NSBitmapImageRep *)bestRep valueForProperty:NSImageFrameCount] intValue] > 1) ) {
			
			// We've got an animating file, and the current alpha is fine.  Just copy the representation.
			NSMutableData *GIFRepresentationData = nil;

			unsigned frameCount = [[(NSBitmapImageRep *)bestRep valueForProperty:NSImageFrameCount] intValue];
			
			if (!frameCount) {
				frameCount = 1;
			}
			
			NSMutableArray *images = [NSMutableArray array];
			
			for (unsigned i = 0; i < frameCount; i++) {
				// Set current frame
				[(NSBitmapImageRep *)bestRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithUnsignedInt:i]];
				
				[newImage lockFocus];
				
				[self drawInRect:newRect
						fromRect:NSMakeRect(0.0f, 0.0f, originalSize.width, originalSize.height)
					   operation:NSCompositeCopy
						fraction:delta];
				
				[newImage unlockFocus];
				
				// Add frame representation
				[images addObject:[NSBitmapImageRep imageRepWithData:[newImage TIFFRepresentation]]];
			}
			
			GIFRepresentationData = [NSMutableData dataWithData:[NSBitmapImageRep representationOfImageRepsInArray:images
																										 usingType:NSGIFFileType
																										properties:[self GIFPropertiesForRepresentation:(NSBitmapImageRep *)bestRep]]];
			
			// Write GIF Extension Blocks
			[self writeGIFExtensionBlocksInData:GIFRepresentationData forRepresenation:(NSBitmapImageRep *)bestRep];
			
			newImage = [[NSImage alloc] initWithData:GIFRepresentationData];
		} else {
			[newImage lockFocus];
			// Highest quality interpolation
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			
			[self drawInRect:newRect
					fromRect:NSMakeRect(0.0f, 0.0f, originalSize.width, originalSize.height)
				   operation:NSCompositeCopy
					fraction:delta];
			
			[newImage unlockFocus];
		}
		
		return newImage;
	}
}

- (NSImage *)imageByFittingInSize:(NSSize)size
{
	return ([self imageByFittingInSize:size fraction:1.0f flipImage:NO proportionally:YES allowAnimation:YES]);
}

- (NSImage *)imageByFittingInSize:(NSSize)size fraction:(CGFloat)delta flipImage:(BOOL)flipImage proportionally:(BOOL)proportionally allowAnimation:(BOOL)allowAnimation
{
	NSSize originalSize = [self size];
	NSSize scaleSize = size;
	NSSize fitSize = size;
	
	// Proceed only if size or delta are changing
	if ((NSEqualSizes(originalSize, size)) && (delta == 1.0) && !flipImage) {
		return [self copy];
		
	} else {
		// Scale proportionally (rather than stretching to fit) if requested and needed
		if (proportionally && (originalSize.width != originalSize.height)) {
			if (originalSize.width > originalSize.height) {
				// Give width priority: Make the height change by the same proportion as the width will change
				scaleSize.height = originalSize.height * (size.width / originalSize.width);
			} else {
				// Give height priority: Make the width change by the same proportion as the height will change
				scaleSize.width = originalSize.width * (size.height / originalSize.height);
			}
		}
		
		// Fit
		if (proportionally && (originalSize.width != originalSize.height)) {
			if (originalSize.width > originalSize.height) {
				// Give width priority: Make the height change by the same proportion as the width will change
				fitSize.height = originalSize.height * (size.width / originalSize.width);
			} else {
				// Give height priority: Make the width change by the same proportion as the height will change
				fitSize.width = originalSize.width * (size.height / originalSize.height);
			}
		}
		
		NSRect scaleRect = NSMakeRect(0.0f, 0.0f, scaleSize.width, scaleSize.height);
		NSPoint fitFromPoint = NSMakePoint((size.width - scaleSize.width) / 2.0f, (size.height - scaleSize.height) / 2.0f);
		
		NSImage *newImage = [[NSImage alloc] initWithSize:size];
		NSImage *scaledImage = [[NSImage alloc] initWithSize:scaleSize];
		
		if (flipImage) {
			[newImage setFlipped:YES];		
		}
		
		NSImageRep *bestRep;
		
		if (allowAnimation &&
			(bestRep = [self bestRepresentationForRect:NSMakeRect(0, 0, self.size.width, self.size.height) context:nil hints:nil]) &&
			[bestRep isKindOfClass:[NSBitmapImageRep class]] && 
			(delta == 1.0) &&
			([[(NSBitmapImageRep *)bestRep valueForProperty:NSImageFrameCount] intValue] > 1) ) {
			
			// We've got an animating file, and the current alpha is fine.  Just copy the representation.
			NSMutableData *GIFRepresentationData = nil;

			unsigned frameCount = [[(NSBitmapImageRep *)bestRep valueForProperty:NSImageFrameCount] intValue];
			
			if (!frameCount) {
				frameCount = 1;
			}
			
			NSMutableArray *images = [NSMutableArray array];
			
			for (unsigned i = 0; i < frameCount; i++) {
				// Set current frame
				[(NSBitmapImageRep *)bestRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithUnsignedInt:i]];
				
				[scaledImage lockFocus];
				
				// Scale
				[self drawInRect:scaleRect
						fromRect:NSMakeRect(0.0f, 0.0f, originalSize.width, originalSize.height)
					   operation:NSCompositeCopy
						fraction:delta];
				
				[scaledImage unlockFocus];
				[newImage lockFocus];
				
				// Fit
				[scaledImage drawAtPoint:fitFromPoint
						 fromRect:NSMakeRect(0.0f, 0.0f, newImage.size.width, newImage.size.height)
						operation:NSCompositeCopy
						 fraction:delta];
				
				[newImage unlockFocus];
				
				// Add frame representation
				[images addObject:[NSBitmapImageRep imageRepWithData:[newImage TIFFRepresentation]]];
			}
			
			GIFRepresentationData = [NSMutableData dataWithData:[NSBitmapImageRep representationOfImageRepsInArray:images
																										 usingType:NSGIFFileType
																										properties:[self GIFPropertiesForRepresentation:(NSBitmapImageRep *)bestRep]]];
			
			// Write GIF Extension Blocks
			[self writeGIFExtensionBlocksInData:GIFRepresentationData forRepresenation:(NSBitmapImageRep *)bestRep];

			newImage = [[NSImage alloc] initWithData:GIFRepresentationData];
		} else {
			[scaledImage lockFocus];
			// Highest quality interpolation
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			
			// Scale
			[self drawInRect:scaleRect
					fromRect:NSMakeRect(0.0f, 0.0f, originalSize.width, originalSize.height)
				   operation:NSCompositeCopy
					fraction:delta];
			
			[scaledImage unlockFocus];
			[newImage lockFocus];
			
			// Fit
			[scaledImage drawAtPoint:fitFromPoint
							fromRect:NSMakeRect(0.0f, 0.0f, newImage.size.width, newImage.size.height)
						   operation:NSCompositeCopy
							fraction:delta];
			
			[newImage unlockFocus];
		}
		
		return newImage;
	}
}

// Fun drawing toys
// Draw an image, altering and returning the available destination rect
- (NSRect)drawInRect:(NSRect)rect atSize:(NSSize)size position:(IMAGE_POSITION)position fraction:(CGFloat)inFraction
{
	// We use our own size for drawing purposes no matter the passed size to avoid distorting the image via stretching
	NSSize	ownSize = [self size];
	
	// If we're passed a 0,0 size, use the image's size for the area taken up by the image 
	// (which may exceed the actual image dimensions)
	if (size.width == 0 || size.height == 0) {
		size = ownSize;
	}
	
	NSRect drawRect = [self rectForDrawingInRect:rect atSize:size position:position];
	
	// If we are drawing in a rect wider than we are, center horizontally
	if (drawRect.size.width > ownSize.width) {
		drawRect.origin.x += (drawRect.size.width - ownSize.width) / 2;
		drawRect.size.width -= (drawRect.size.width - ownSize.width);
	}
	
	// If we are drawing in a rect higher than we are, center vertically
	if (drawRect.size.height > ownSize.height) {
		drawRect.origin.y += (drawRect.size.height - ownSize.height) / 2;
		drawRect.size.height -= (drawRect.size.height - ownSize.height);
	}
	
	// Draw
	[self drawInRect:drawRect
			fromRect:NSMakeRect(0, 0, ownSize.width, ownSize.height)
		   operation:NSCompositeSourceOver
			fraction:inFraction];
	
	// Shift the origin if needed, and decrease the available destination rect width, by the passed size
	// (which may exceed the actual image dimensions)
	if (position == IMAGE_POSITION_LEFT) {
		rect.origin.x += size.width;
	}
	
	rect.size.width -= size.width;
	
	return rect;
}

- (NSRect)rectForDrawingInRect:(NSRect)rect atSize:(NSSize)size position:(IMAGE_POSITION)position
{
	NSRect	drawRect;
	
	// If we're passed a 0,0 size, use the image's size
	if (size.width == 0 || size.height == 0) {
		size = [self size];
	}

	// Adjust the positioning
	switch (position) {
		case IMAGE_POSITION_LEFT:
			drawRect = NSMakeRect(rect.origin.x,
								  rect.origin.y + (int)((rect.size.height - size.height) / 2.0),
								  size.width,
								  size.height);
			break;
		case IMAGE_POSITION_RIGHT:
			drawRect = NSMakeRect(rect.origin.x + rect.size.width - size.width,
								  rect.origin.y + (int)((rect.size.height - size.height) / 2.0),
								  size.width,
								  size.height);
			break;
		case IMAGE_POSITION_LOWER_LEFT:
			drawRect = NSMakeRect(rect.origin.x,
								  rect.origin.y + (rect.size.height - size.height),
								  size.width,
								  size.height);
			break;
		case IMAGE_POSITION_LOWER_RIGHT:
			drawRect = NSMakeRect(rect.origin.x + (rect.size.width - size.width),
								  rect.origin.y + (rect.size.height - size.height),
								  size.width,
								  size.height);
			break;
	}
	
	return drawRect;
}

// General purpose draw image rounded in a NSRect.
- (NSRect)drawRoundedInRect:(NSRect)rect radius:(CGFloat)radius
{
	return [self drawRoundedInRect:rect atSize:NSMakeSize(0,0) position:0 fraction:1.0f radius:radius];
}

// Perhaps if you desired to draw it rounded in the tooltip.
- (NSRect)drawRoundedInRect:(NSRect)rect fraction:(CGFloat)inFraction radius:(CGFloat)radius
{
	return [self drawRoundedInRect:rect atSize:NSMakeSize(0,0) position:0 fraction:inFraction radius:radius];
}

// Draw an image, round the corner. Meant to replace the method above.
- (NSRect)drawRoundedInRect:(NSRect)rect atSize:(NSSize)size position:(IMAGE_POSITION)position fraction:(CGFloat)inFraction radius:(CGFloat)radius
{
	NSRect	drawRect;
	
	// We use our own size for drawing purposes no matter the passed size to avoid distorting the image via stretching
	NSSize	ownSize = [self size];
	
	// If we're passed a 0,0 size, use the image's size for the area taken up by the image 
	// (which may exceed the actual image dimensions)
	if (size.width == 0 || size.height == 0) {
		size = ownSize;
	}
	
	drawRect = [self rectForDrawingInRect:rect atSize:size position:position];
	
	// If we are drawing in a rect wider than we are, center horizontally
	if (drawRect.size.width > ownSize.width) {
		drawRect.origin.x += (drawRect.size.width - ownSize.width) / 2;
		drawRect.size.width -= (drawRect.size.width - ownSize.width);
	}
	
	// If we are drawing in a rect higher than we are, center vertically
	if (drawRect.size.height > ownSize.height) {
		drawRect.origin.y += (drawRect.size.height - ownSize.height) / 2;
		drawRect.size.height -= (drawRect.size.height - ownSize.height);
	}
	
	// Create Rounding.
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath	*clipPath = [NSBezierPath bezierPathWithRoundedRect:drawRect radius:radius];
	[clipPath addClip];
	
	// Draw
	[self drawInRect:drawRect
			fromRect:NSMakeRect(0, 0, ownSize.width, ownSize.height)
		   operation:NSCompositeSourceOver
			fraction:inFraction];
	
	[NSGraphicsContext restoreGraphicsState];
	
	// Shift the origin if needed, and decrease the available destination rect width, by the passed size
	// (which may exceed the actual image dimensions)
	if (position == IMAGE_POSITION_LEFT) {
		rect.origin.x += size.width;
	}
	
	rect.size.width -= size.width;
	
	return rect;
}

@end
