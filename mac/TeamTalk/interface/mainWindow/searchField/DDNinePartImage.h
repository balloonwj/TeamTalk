//
//  DDNinePartImage.h
//  Duoduo
//
//  Created by zuoye on 14-1-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDNinePartImage : NSImage{
    NSImage *topLeftCornerImage;
    NSImage *topEdgeImage;
    NSImage *topRightCornerImage;
    NSImage *leftEdgeImage;
    NSImage *centerImage;
    NSImage *rightEdgeImage;
    NSImage *bottomLeftCornerImage;
    NSImage *bottomEdgeImage;
    NSImage *bottomRightCornerImage;
}

@end
