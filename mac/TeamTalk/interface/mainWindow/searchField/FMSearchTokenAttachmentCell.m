//
//  FMSearchTokenAttachmentCell.m
//  Duoduo
//
//  Created by zuoye on 14-1-23.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "FMSearchTokenAttachmentCell.h"

@implementation FMSearchTokenAttachmentCell
/*
 $rdi == arg0 (ObjC: self)
 $rsi == arg1 (ObjC: op, or _cmd)
 $rdx == arg2 (ObjC: first arg of method)
 $rcx == arg3 (ObjC: second arg of method) cell
 $r8 == arg4 第三个参数
 $r9 == arg5 第四个
 */

-(NSRect)titleRectForBounds:(NSRect)theRect{
    /*
    *(rdi + 0x18) = arg_18;
    *(rdi + 0x10) = arg_10;
    *(rdi + 0x8) = arg_8;
    *rdi = arg_0;
    *rdi = *rdi + *0x1001b0ca8;
    *(rdi + 0x10) = *(rdi + 0x10) + *0x1001bca50;
    return rdi;
     */
    return NSZeroRect;
}


-(NSSize)cellSizeForBounds:(NSRect)theRect {
   return  [[self attributedStringValue] size];
}


-(NSRect)drawingRectForBounds:(NSRect) theRect {
    
    /*
    *(rdi + 0x18) = arg_18;
    *(rdi + 0x10) = arg_10;
    *(rdi + 0x8) = arg_8;
    *rdi = arg_0;
    *rdi = *rdi + *0x1001b0c30;
    *(rdi + 0x10) = *(rdi + 0x10) + *0x1001b0d78;
    return rdi;
    */
    return NSZeroRect;
}

@end
