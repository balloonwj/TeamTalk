//
//  DDClickCell.m
//  Duoduo
//
//  Created by zuoye on 14-2-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDClickCell.h"

#define kImageOriginXOffset     3
#define kImageOriginYOffset     1

#define kTextOriginXOffset      2
#define kTextOriginYOffset      2
#define kTextHeightAdjust       4

@interface DDClickCell ()
@property (readwrite, strong) NSImage *image;
@end

@implementation DDClickCell
@synthesize image,clickImage,alterClickImage;
@synthesize clickAction,clickOtherAreaAction;
@synthesize canSelect;
@synthesize clickType;              //clickType为0时加到选择列表中,为1时从选择列表中删除.
@synthesize cellType;
@synthesize bShowHighlightColor;


// -------------------------------------------------------------------------------
//	init
// -------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self)
    {
        [self setClickType:1];
        // we want a smaller font
        [self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    }
    return self;
}
    
    // -------------------------------------------------------------------------------
    //	copyWithZone:zone
    // -------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone
    {
        DDClickCell *cell = (DDClickCell *)[super copyWithZone:zone];
        cell.image = self.image;
        cell.clickImage = self.clickImage;
        cell.alterClickImage = self.clickImage;
        cell.cellType = self.cellType;
        cell.clickType = self.clickType;
        return cell;
    }
    
    // -------------------------------------------------------------------------------
    //	isGroupCell:
    // -------------------------------------------------------------------------------
- (BOOL)isGroupCell
    {
        return ([self image] == nil && [[self title] length] > 0);
    }
    
    // -------------------------------------------------------------------------------
    //	titleRectForBounds:cellRect
    //
    //	Returns the proper bound for the cell's title while being edited
    // -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
    {
        // the cell has an image: draw the normal item cell
        NSSize imageSize;
        NSRect imageFrame;
        
        imageSize = [self.image size];
        //将一个矩形划分为两个矩形?
        NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += kImageOriginXOffset;
        imageFrame.origin.y -= kImageOriginYOffset;
        imageFrame.size = imageSize;
        
        imageFrame.origin.y += ceil((cellRect.size.height - imageFrame.size.height) / 2);
        
        NSRect newFrame = cellRect;
        newFrame.origin.x += kTextOriginXOffset;
        newFrame.origin.y += kTextOriginYOffset;
        newFrame.size.height -= kTextHeightAdjust;
        
        return newFrame;
    }
    
    
    //可点击区域
-(NSRect)clickAreaRectForBounds:(NSRect)cellFrame {
        
    NSSize	imageSize;
    NSRect	imageFrame;
     NSRect newCellFrame = cellFrame;
    
    imageSize = [self.clickImage size];
    NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
    NSRect newImageFrame = imageFrame;
    newImageFrame.origin.y += 1;
    if (cellType==0) {
        newImageFrame.origin.x += cellFrame.size.width-newImageFrame.size.width;
    }else{
        newImageFrame.origin.x += cellFrame.size.width-newImageFrame.size.width-10;
    }

    newImageFrame.size =imageSize;
    return newImageFrame;
}

-(NSRect)closeAreaRectForBounds:(NSRect)cellFrame {
    NSSize	imageSize;
    NSRect	imageFrame;
    NSRect newCellFrame = cellFrame;
    
    imageSize = [self.clickImage size];
    NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
    NSRect newImageFrame = imageFrame;
    newImageFrame.origin.y += 1;
    if (cellType==0) {
            newImageFrame.origin.x += cellFrame.size.width-newImageFrame.size.width;
    }else{
            newImageFrame.origin.x += cellFrame.size.width-newImageFrame.size.width-10;
    }

    newImageFrame.size =imageSize;
    return newImageFrame;
}
    // -------------------------------------------------------------------------------
    //	editWithFrame:inView:editor:delegate:event
    // -------------------------------------------------------------------------------
//- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
//    {
//        //cell里可编辑的区域.
//        NSRect textFrame = [self titleRectForBounds:aRect];
//        [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
//    }

    // -------------------------------------------------------------------------------
    //	selectWithFrame:inView:editor:delegate:event:start:length
    // -------------------------------------------------------------------------------
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
    {
        //text可选择区域.
        NSRect textFrame = [self titleRectForBounds:aRect];
        [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
    }
    
    // -------------------------------------------------------------------------------
    //	drawWithFrame:cellFrame:controlView
    // -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
    {
        NSRect newCellFrame = cellFrame;
        if (self.image != nil)
        {
            
            NSSize	imageSize;
            NSRect	imageFrame;
            
            imageSize = [self.image size];
            NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
            if ([self drawsBackground])     //画背景
            {
                [[self backgroundColor] set];
                NSRectFill(imageFrame);
            }
            
            imageFrame.origin.y += 1;
            imageFrame.size = imageSize;
            
            [self.image drawInRect:imageFrame
                          fromRect:NSZeroRect
                         operation:NSCompositeSourceOver
                          fraction:1.0
                    respectFlipped:YES
                             hints:nil];
            
          //  NSRect newImageFrame = imageFrame;
           // newImageFrame.origin.x  += cellFrame.size.width-newImageFrame.size.width;
            NSRect newImageFrame = [self clickAreaRectForBounds:cellFrame];
            
//            [self.clickImage drawInRect:newImageFrame
//                                    fromRect:NSZeroRect
//                                   operation:NSCompositeSourceOver
//                                    fraction:1.0
//                              respectFlipped:YES
//                                       hints:nil];
            

            if (cellType==0) {
                if ([self isHighlighted]) {
                    [self.alterClickImage drawInRect:newImageFrame
                                            fromRect:NSZeroRect
                                           operation:NSCompositeSourceOver
                                            fraction:1.0
                                      respectFlipped:YES
                                               hints:nil];
                }else{
                    [self.clickImage drawInRect:newImageFrame
                                       fromRect:NSZeroRect
                                      operation:NSCompositeSourceOver
                                       fraction:1.0
                                 respectFlipped:YES
                                          hints:nil];
                }
            }else{
                [self.clickImage drawInRect:newImageFrame
                                   fromRect:NSZeroRect
                                  operation:NSCompositeSourceOver
                                   fraction:1.0
                             respectFlipped:YES
                                      hints:nil];
            }
            
            
            

        }
        else
        {
            if ([self isGroupCell])
            {
                // center the text in the cellFrame, and call super to do the work of actually drawing
                CGFloat yOffset = floor((NSHeight(newCellFrame) - [[self attributedStringValue] size].height) / 2.0);
                
                newCellFrame.origin.y += yOffset;
                newCellFrame.size.height -= (kTextOriginYOffset*yOffset);
            }
        }
        
        [super drawWithFrame:newCellFrame inView:controlView];
}
    
+ (BOOL)prefersTrackingUntilMouseUp{
    return YES;
}

    
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag{
    
    [self setControlView:controlView];      //???
    NSRect areaRect ;
    if (self.cellType==0) {       //左边的可选择cell
        areaRect = [self clickAreaRectForBounds:cellFrame];
    }else{              //右边的可关闭cell
        areaRect = [self closeAreaRectForBounds:cellFrame];
    }
    
    if ([theEvent type]!=NSLeftMouseUp) {
        do {
            NSPoint currentPoint = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
            if (NSMouseInRect(currentPoint, areaRect, [controlView isFlipped])) {
                if (self.clickAction) {
                    [NSApp sendAction:self.clickAction to:self.target from:self.controlView];
                }
                [controlView setNeedsDisplayInRect:areaRect];
                
            }else{
                if (self.clickOtherAreaAction) {        //
                    [NSApp sendAction:self.clickOtherAreaAction to:self.target from:self.controlView];
                }
            }
            NSEventType eventType =  [theEvent type];
            if (eventType == NSMouseEntered || eventType ==NSMouseExited) {
                [NSApp sendEvent:theEvent];
            }
            
            theEvent = [[controlView window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSMouseEnteredMask | NSMouseExitedMask)];

        } while ([theEvent type] != NSLeftMouseUp);
    }
    
    return YES;
}


-(NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView{
    if (self.canSelect == NO) {
        NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
        NSRect  imageFrame = [self closeAreaRectForBounds:cellFrame];
        if (NSMouseInRect(point, imageFrame, [controlView isFlipped])){
            return NSCellHitContentArea | NSCellHitTrackableArea;
        }
        
    }
     return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}


    // -------------------------------------------------------------------------------
    //	cellSize
    // -------------------------------------------------------------------------------
- (NSSize)cellSize
    {
        NSSize cellSize = [super cellSize];
        cellSize.width += (self.image ? [self.image size].width : 0) + 3;
        return cellSize;
    }

@end
