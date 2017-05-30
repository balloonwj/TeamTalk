//
//  DDNinePartImage.m
//  Duoduo
//
//  Created by zuoye on 14-1-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDNinePartImage.h"

@implementation DDNinePartImage

-(id)initWithNSImage:(NSImage *)image leftPartWidth:(CGFloat)leftWidth rightPartWidth:(CGFloat)rightWidth topPartHeight:(CGFloat)topHeight bottomPartHeight:(CGFloat)bottomHeight{
    return [self initWithNSImage:image leftPartWidth:leftWidth rightPartWidth:rightWidth topPartHeight:topHeight bottomPartHeight:bottomHeight flipped:NO];
}

-(id)initWithNSImage:(NSImage *)image leftPartWidth:(CGFloat)leftWidth rightPartWidth:(CGFloat)rightWidth topPartHeight:(CGFloat)topHeight bottomPartHeight:(CGFloat)bottomHeight flipped:(BOOL)flipped{
    self = [super init];
    if (self) {
        
        //size 是指块图片的大小.
     //   topLeftCornerImage = [DDNinePartImage getPartImage:image withSize:<#(NSSize)#> fromRect:<#(NSRect)#>]
    }
    return self;
}




/*
 
 function meth_TXNinePartImage_dealloc {
 edi = arg_0;
 [*(edi + 0x1c) release];   //topLeftCornerImage
 [*(edi + 0x20) release];   //topEdgeImage
 [*(edi + 0x24) release];   //topRightCornerImage
 [*(edi + 0x28) release];   //leftEdgeImage
 [*(edi + 0x2c) release];   //centerImage
 [*(edi + 0x30) release];   //rightEdgeImage
 [*(edi + 0x34) release];   //bottomLeftCornerImage
 [*(edi + 0x38) release];   //bottomEdgeImage
 [*(edi + 0x3c) release];   //bottomRightCornerImage
 var_8 = edi;
 var_12 = *0xca2ce4;
 eax = [[&var_8 super] dealloc];
 return eax;
 }
 */



-(void)drawInRect:(NSRect)rect fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta{
    [self drawInRect:rect compositingOperation:op alphaFraction:delta flipped:NO];
}

-(void)drawInRect:(NSRect)rect compositingOperation:(NSCompositingOperation)op alphaFraction:(CGFloat)alphaFraction flipped:(BOOL)isFlipped{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [context setShouldAntialias:YES];
    NSDrawNinePartImage(rect, topLeftCornerImage, topEdgeImage, topRightCornerImage, leftEdgeImage, centerImage, rightEdgeImage, bottomLeftCornerImage, bottomEdgeImage, bottomRightCornerImage, op, alphaFraction, isFlipped);
    [context restoreGraphicsState];
}

+(NSImage *)getPartImage:(NSImage *)image withSize:(NSSize)size fromRect:(NSRect)rect{
    NSImage *im = [[NSImage alloc] initWithSize:size];
    [im lockFocus];
    [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:rect operation:NSCompositeCopy fraction:1];
    [im unlockFocus];
    return im;
}


/*
 $rdi == arg0 (ObjC: self)
 $rsi == arg1 (ObjC: op, or _cmd)
 $rdx == arg2 (ObjC: first arg of method)
 $rcx == arg3 (ObjC: second arg of method) cell
 $r8 == arg4 第三个参数
 $r9 == arg5 第四个
 */
/*
function meth_TXNinePartImage_initWithNSImage_leftPartWidth_rightPartWidth_topPartHeight_bottomPartHeight_flipped_ {
    var_240 = arg_0;
    var_244 = *0xca2ce4;
    eax = [[&var_240 super] init];
    if (eax != 0x0) {
        ecx = arg_8;
        edi = ecx;
        eax = [ecx size];
        var_48 = eax;
        [edi size];
        floorf(edx);
        asm{ fstp       tword [ss:ebp-0x108+var_60] };
        floorf(arg_14);
        asm{ fstp       dword [ss:ebp-0x108+var_80] };
        asm{ fld        tword [ss:ebp-0x108+var_60] };
        asm{ fstp       dword [ss:ebp-0x108+var_92] };
        floorf(arg_C);
        asm{ fstp       dword [ss:ebp-0x108+var_72] };
        xmm3 = var_80;
        var_52 = xmm3;
        xmm0 = var_92 - xmm3;
        var_60 = xmm0;
        var_224 = 0x0;
        var_228 = xmm0;
        xmm0 = var_72;
        var_56 = xmm0;
        var_232 = xmm0;
        var_236 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm0 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x1c) = eax;
        floorf(var_48);
        var_36 = esi;
        var_208 = var_56;
        asm{ fstp       dword [ss:ebp-0x108+var_88] };
        floorf(arg_10);
        asm{ fstp       dword [ss:ebp-0x108+var_76] };
        var_212 = var_60;
        xmm0 = var_88;
        var_48 = xmm0;
        xmm1 = var_76;
        var_44 = xmm1;
        xmm0 = xmm0 - var_56 - xmm1;
        var_40 = xmm0;
        var_216 = xmm0;
        xmm3 = var_52;
        var_220 = xmm3;
        esi = var_36;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm0 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x20) = eax;
        xmm0 = var_44;
        xmm1 = var_48 - xmm0;
        var_48 = xmm1;
        var_192 = xmm1;
        var_196 = var_60;
        var_200 = xmm0;
        xmm3 = var_52;
        var_204 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm0 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x24) = eax;
        floorf(arg_18);
        asm{ fstp       dword [ss:ebp-0x108+var_84] };
        var_176 = 0x0;
        xmm1 = var_84;
        var_52 = xmm1;
        var_180 = xmm1;
        xmm2 = var_56;
        var_184 = xmm2;
        xmm0 = var_60 - xmm1;
        var_60 = xmm0;
        var_188 = xmm0;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm2 fromRect:xmm0];
        eax = [eax retain];
        *(esi + 0x28) = eax;
        var_160 = var_56;
        var_164 = var_52;
        xmm2 = var_40;
        var_168 = xmm2;
        xmm3 = var_60;
        var_172 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm2 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x2c) = eax;
        var_144 = var_48;
        var_148 = var_52;
        xmm2 = var_44;
        var_152 = xmm2;
        xmm3 = var_60;
        var_156 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm2 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x30) = eax;
        var_128 = 0x0;
        var_132 = 0x0;
        xmm2 = var_56;
        var_136 = xmm2;
        xmm3 = var_52;
        var_140 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm2 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x34) = eax;
        var_112 = var_56;
        var_116 = 0x0;
        xmm3 = var_40;
        var_120 = xmm3;
        xmm2 = var_52;
        var_124 = xmm2;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm3 fromRect:xmm2];
        eax = [eax retain];
        *(esi + 0x38) = eax;
        var_96 = var_48;
        var_100 = 0x0;
        xmm2 = var_44;
        var_104 = xmm2;
        xmm3 = var_52;
        var_108 = xmm3;
        eax = [TXNinePartImage getPartImage:edi withSize:xmm2 fromRect:xmm3];
        eax = [eax retain];
        *(esi + 0x3c) = eax;
        *(int8_t *)(esi + 0x40) = arg_1C;
    }
    eax = esi;
    return eax;
}
*/
@end
