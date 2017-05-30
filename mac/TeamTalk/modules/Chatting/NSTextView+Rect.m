//
//  NSTextView+Rect.m
//  TextViewDemo
//
//  Created by 独嘉 on 14-3-7.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "NSTextView+Rect.h"

@implementation NSTextView (Rect)
- (NSRect)contentRect
{
    NSLayoutManager *layoutManager = [self layoutManager];
    NSPoint containerOrigin = [self textContainerOrigin];
    NSRange glyphRange, charRange, paragraphCharRange,
    paragraphGlyphRange, lineGlyphRange;
    NSRect paragraphRect, lineUsedRect;
    // Draw the background first, before the bubbles.
    NSRect rect = self.bounds;
    // Convert from view to container coordinates, then to the
    //corresponding glyph and character ranges.
    rect.origin.x -= containerOrigin.x;
    rect.origin.y -= containerOrigin.y;
    glyphRange = [layoutManager glyphRangeForBoundingRect:rect
                                          inTextContainer:[self textContainer]];
    charRange = [layoutManager characterRangeForGlyphRange:glyphRange
                                          actualGlyphRange:NULL];
    // Iterate through the character range, paragraph by paragraph.
    for (paragraphCharRange = NSMakeRange(charRange.location, 0);
         NSMaxRange(paragraphCharRange) < NSMaxRange(charRange);
         paragraphCharRange = NSMakeRange(NSMaxRange(paragraphCharRange), 0)) {
        // For each paragraph, find the corresponding character and glyph ranges.
        paragraphCharRange = [[[self textStorage] string]
                              paragraphRangeForRange:paragraphCharRange];
        paragraphGlyphRange = [layoutManager
                               glyphRangeForCharacterRange:paragraphCharRange
                               actualCharacterRange:NULL];
//        paragraphRect = NSZeroRect;
        // Iterate through the paragraph glyph range, line by line.
        for (lineGlyphRange = NSMakeRange(paragraphGlyphRange.location,0);
             NSMaxRange(lineGlyphRange) < NSMaxRange(paragraphGlyphRange);
             lineGlyphRange = NSMakeRange(NSMaxRange(lineGlyphRange), 0)) {
            // For each line, find the used rect and glyph range, and
            // add the used rect to the paragraph rect.
            lineUsedRect = [layoutManager
                            lineFragmentUsedRectForGlyphAtIndex:lineGlyphRange.location
                            effectiveRange:&lineGlyphRange];
            paragraphRect = NSUnionRect(paragraphRect, lineUsedRect);
            
        }
        // Convert back from container to view coordinates, then draw the bubble.
        paragraphRect.origin.x += containerOrigin.x;
        paragraphRect.origin.y += containerOrigin.y;
    }
    return paragraphRect;
}
@end
