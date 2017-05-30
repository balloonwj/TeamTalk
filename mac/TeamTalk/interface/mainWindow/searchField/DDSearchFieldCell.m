//
//  DDSearchFieldCell.m
//  Duoduo
//
//  Created by zuoye on 14-1-20.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSearchFieldCell.h"
#import "NSImage+Stretchable.h"


@implementation DDSearchFieldCell

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSImage *activeImage =[NSImage imageNamed:@"mainpanel_searchbar_active"];
        [activeImage setFlipped:YES];
        activeImageStrech = [activeImage stretchableImageWithSize:NSMakeSize(275, 25)                                               edgeInsets:NSEdgeInsetsMake(1, 1, 1, 1)];

        
        NSImage *normalImage =[NSImage imageNamed:@"mainpanel_searchbar_normal"];
                [normalImage setFlipped:YES];
        normalImageStrech = [normalImage stretchableImageWithSize:NSMakeSize(275, 25)                                               edgeInsets:NSEdgeInsetsMake(1, 1, 1, 1)];

    }
    return self;
    
    /*
     
     var_32 = arg_0;
     var_36 = *0xca0eb4;
     eax = [[&var_32 super] initWithCoder:arg_8];
     if (eax != 0x0) {
     eax = [TXNinePartImage alloc];
     edi = eax;
     eax = [NSImage imageNamed:@"mainpanel_searchbar_active"];
     eax = [edi initWithNSImage:eax leftPartWidth:0x41a80000 rightPartWidth:0x41a80000 topPartHeight:0x41580000 bottomPartHeight:0x41580000 flipped:0x1];
     *(esi + 0x60) = eax;
     eax = [TXNinePartImage alloc];
     edi = eax;
     eax = [NSImage imageNamed:@"mainpanel_searchbar_normal"];
     eax = [edi initWithNSImage:eax leftPartWidth:0x41a80000 rightPartWidth:0x41a80000 topPartHeight:0x41580000 bottomPartHeight:0x41580000 flipped:0x1];
     *(esi + 0x64) = eax;
     eax = *imp___nl_symbol_ptr__NSZeroRect;
     xmm0 = *(int64_t *)eax;
     xmm1 = *(int64_t *)(eax + 0x8);
     *(int64_t *)(esi + 0x80) = xmm1;
     *(int64_t *)(esi + 0x78) = xmm0;
     *(int64_t *)(esi + 0x70) = xmm1;
     *(int64_t *)(esi + 0x68) = xmm0;
     *(int8_t *)(esi + 0x88) = 0x0;
     }
     eax = esi;
     return eax;
     */
}

/*
 
 edi = arg_0;
 var_8 = edi;
 var_12 = *0xca0eb4;
 [[&var_8 super] dealloc];
 [*(edi + 0x60) release];
 eax = [*(edi + 0x64) release];
 return eax;
 */



/*
 $rdi == arg0 (ObjC: self)
 $rsi == arg1 (ObjC: op, or _cmd)
 $rdx == arg2 (ObjC: first arg of method)
 $rcx == arg3 (ObjC: second arg of method) cell
 $r8 == arg4 第三个参数
 $r9 == arg5 第四个
 */
-(NSRect)searchTextRectForBounds:(NSRect)rect{
    
    return rect;
    /*
    edi = arg_4;
    ebx = *imp___nl_symbol_ptr__NSZeroRect;
    eax = NSEqualRects(*(int64_t *)(edi + 0x70));
    ecx = arg_0;
    if (eax != 0x0) {
        ebx = *imp___nl_symbol_ptr__NSZeroRect;
        xmm0 = *(ebx + 0xc);
        xmm1 = *(ebx + 0x8);
        xmm2 = *ebx;
        xmm3 = *(ebx + 0x4);
    }
    else {
        xmm0 = *(edi + 0x74);
        xmm2 = *(edi + 0x68);
        xmm3 = *(edi + 0x6c);
        xmm1 = *(&arg_C + 0x8) + *0x96fd48;
    }
    *ecx = xmm2;
    *(ecx + 0x4) = xmm3;
    *(ecx + 0x8) = xmm1;
    *(ecx + 0xc) = xmm0;
    return eax;
     */
}


//-(NSRect)searchButtonRectForBounds:(NSRect)rect{
    /*
    esi = arg_4;
    edi = *imp___nl_symbol_ptr__NSZeroRect;
    eax = NSEqualRects(*(int64_t *)(esi + 0x80));
    ecx = arg_0;
    if (eax != 0x0) {
        edi = *imp___nl_symbol_ptr__NSZeroRect;
        xmm0 = *(edi + 0xc);
        xmm1 = *(edi + 0x8);
        xmm2 = *edi;
        xmm3 = *(edi + 0x4);
    }
    else {
        xmm0 = *(esi + 0x84);
        xmm1 = *(esi + 0x80);
        xmm2 = *(esi + 0x78);
        xmm3 = *(esi + 0x7c);
    }
    *ecx = xmm2;
    *(ecx + 0x4) = xmm3;
    *(ecx + 0x8) = xmm1;
    *(ecx + 0xc) = xmm0;
    return eax;
     */
  //  return rect;
//}

-(void)setDrawsBackground:(BOOL)flag{
    /*
    eax = arg_0;
    *(int8_t *)(eax + 0x88) = arg_8 != 0x0 ? 0xff : 0x0;
    return eax;
     */
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    
    if (NSIsEmptyRect(cellFrame)) {
        
    }
    
    [activeImageStrech drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [self drawInteriorWithFrame:cellFrame inView:controlView];
    
    /*
    STK31 = arg_8;
    eax = NSIsEmptyRect(arg_10);
    if (eax == 0x0) {
        ebx = &arg_8;
        if (*(int8_t *)(arg_0 + 0x88) != 0x0) {
            eax = *(edi + 0x60);
        }
        else {
            eax = *(edi + 0x64);
        }
        if (eax != 0x0) {
            [eax drawInRect:*(int64_t *)ebx fromRect:STK28 operation:*(int64_t *)(ebx + 0x8) fraction:STK26];
        }
        eax = [edi drawInteriorWithFrame:*(int64_t *)ebx inView:STK28];
    }
    return eax;
     */
}

-(void)setCellBackGroundActivePic:(NSImage *)activePic NormalPic:(NSImage *)normalPic{
    activeImageStrech = activePic;
    normalImageStrech = normalPic;
}


-(void)setCellSearchTextRect:(NSRect)textRect SearchButtonRect:(NSRect)buttonRect {
   /*
    eax = arg_0;
    *(int64_t *)(eax + 0x70) = arg_10;
    *(int64_t *)(eax + 0x68) = arg_8;
    *(int64_t *)(eax + 0x80) = arg_20;
    *(int64_t *)(eax + 0x78) = arg_18;
    return eax;
    
    */
}

@end
