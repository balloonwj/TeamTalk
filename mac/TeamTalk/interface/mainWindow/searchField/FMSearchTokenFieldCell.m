//
//  FMSearchTokenFieldCell.m
//  Duoduo
//
//  Created by zuoye on 14-1-23.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "FMSearchTokenFieldCell.h"
#define kIconImageSize		18.0

#define kImageOriginXOffset 4
#define kImageOriginYOffset 1

#define kTextOriginXOffset	2
#define kTextOriginYOffset	2
#define kTextHeightAdjust	4


@implementation FMSearchTokenFieldCell
@synthesize buttonPressed = _buttonPressed;

- (id)init
{
    self = [super init];
    if (self) {
        [self setBordered:YES];
        [self setEditable:YES];
        [self setBezeled:YES];
        [self setBezelStyle:NSTextFieldRoundedBezel];
        [self setScrollable:YES];
        [self setUsesSingleLineMode:YES];
        self.buttonPressed = NO;
    }
    return self;
}
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    [super drawWithFrame:cellFrame inView:controlView];
    [NSGraphicsContext saveGraphicsState];
    NSRect imageRect ;
    NSRect buttonRect;
    
    [self divideFrame:cellFrame ToImageRect:&imageRect textRect:nil buttonRect:&buttonRect callFromView:NO];
     DDLog(@"\n\n\nNSStringFromRect%@\n\n\n",NSStringFromRect(imageRect));
    [self drawImageIn:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
    
    ////////////////////////////////////////////
    /*
    rbx = rdi;      //self
    var_112 = rbx;      //
    var_120 = *0x1002c3b60;
    [[&var_112 super] drawWithFrame:edx inView:ecx];
    r14 = *objc_msgSend;
    [NSGraphicsContext saveGraphicsState];
    rdx = &var_80;      //cellFrame
    (*objc_msgSend)(rbx, @selector(divideFrame:ToImageRect:textRect:buttonRect:callFromView:), rdx, 0x0, &var_48, 0x0);
    [rbx sideIntervalIn:rdx];       //self rbx
    xmm1 = xmm0;
    var_40 = xmm1;
    var_80 = var_80 + xmm1;
    var_96 = var_96 - xmm1;
    [rbx drawImageIn:rdx];
    var_64 = var_64 - var_40;
    [rbx drawButtonIn:rdx];
    rax = [NSGraphicsContext restoreGraphicsState];
    return rax;
     */
}

-(void)drawImageIn:(NSRect)rect {
    
    [[NSColor darkGrayColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:1 yRadius:1];
    [path setLineWidth:1];
    [path stroke];
    NSBezierPath *path2 =[NSBezierPath bezierPath];
    [path2 moveToPoint:NSMakePoint(1, 1)];
    [path2 lineToPoint:NSMakePoint(1, 10)];
    [path2 setLineWidth:1];
    [path2 stroke];
    
    /*
    var_32 = arg_0 + *0x1001bcdd8;
    var_40 = arg_8;
    r14 = *objc_msgSend;
    rax = [NSColor darkGrayColor];
    [rax setStroke];
    rax = 0x4022000000000000;
    var_48 = var_32;
    var_56 = *0x1001bd1d8 + var_40;
    var_64 = rax;
    var_72 = rax;
    rcx = var_56;
    rax = [NSBezierPath bezierPathWithRoundedRect:rdx xRadius:rcx yRadius:r8];
    rbx = rax;
    [rbx setLineWidth:rdx];
    [rbx stroke];
    rax = [NSBezierPath bezierPath];
    rbx = rax;
    xmm0 = var_40 + *0x1001bcdd8;
    var_40 = xmm0;
    [rbx moveToPoint:rdx];
    [rbx lineToPoint:rdx];
    [rbx setLineWidth:rdx];
    rax = [rbx stroke];
    return rax;
     */
}



-(void)sideIntervalIn:(NSRect)rect{
    [self cellSizeForBounds:rect];
}



/*
 $rdi == arg0 (ObjC: self)
 $rsi == arg1 (ObjC: op, or _cmd)
 $rdx == arg2 (ObjC: first arg of method)
 $rcx == arg3 (ObjC: second arg of method) cell
 $r8 == arg4 第三个参数
 $r9 == arg5 第四个
 */
//划分frame.
-(void)divideFrame:(NSRect)frame ToImageRect:(NSRect *)imageFrame textRect:(NSRect *)textFrame buttonRect:(NSRect *)buttonFrame callFromView:(BOOL)callFromView{
    
    
  /*  -(void)divideFrame:(NSRect)frame intoImageFrame:(NSRect*)imageFrame textFrame:(NSRect*)textFrame
	*/
    NSImage* image = self.image;
	NSSize imageSize = [image size];
	
	NSDivideRect(frame, imageFrame, textFrame, 3 + imageSize.width, NSMinXEdge);
	
	imageFrame->origin.x += kImageOriginXOffset;
	imageFrame->origin.y -= kImageOriginYOffset;
	imageFrame->size = imageSize;
	
	imageFrame->origin.y += ceil((textFrame->size.height - imageFrame->size.height) / 2);
	
	textFrame->origin.x += kTextOriginXOffset;
	textFrame->origin.y += kTextOriginYOffset;
	textFrame->size.height -= kTextHeightAdjust;
   
   
    /*
    r14 = r8;       //textFrame
    r15 = rcx;      //imageFrame
    r13 = rdx;      //frame
    rbx = rdi;      //self
    var_64 = rbx;
    var_72 = *0x1002c3b60;
    rdx = @selector(titleRectForBounds:);
    rcx = arg_8;
    objc_msgSendSuper2_stret(&var_120, &var_64, rdx, rcx);
    rax = [rbx sideIntervalIn:rdx];
    asm{ cvttss2si  eax, xmm0 };
    xmm0 = rax;
    xmm1 = var_144;
    xmm2 = *0x1001b0d68 + xmm1 + xmm0;
    xmm5 = var_136 - xmm2 - xmm0 + xmm1 + *0x1001bce28;
    xmm2 = xmm2 + var_120 + *(int32_t *)0x1001bd1e0;
    xmm1 = xmm1;
    xmm3 = var_128;
    xmm5 = xmm5;
    if (r9 != 0x1) {
        xmm6 = xmm2 + xmm5 + *(int32_t *)0x1001bd1e0;
    }
    else {
        xmm6 = xmm2 + *(int32_t *)0x1001bd1e4 + xmm5 + *(int32_t *)0x1001bd1e8 + *(int32_t *)0x1001bd1e0 + *(int32_t *)0x1001bd1e4;
    }
    if (r13 != 0x0) {
        *r13 = xmm7;
        *(r13 + 0x8) = xmm3;
        *(r13 + 0x10) = xmm4;
        *(r13 + 0x18) = xmm1;
    }
    if (r15 != 0x0) {
        *r15 = xmm2;
        *(r15 + 0x8) = xmm3;
        *(r15 + 0x10) = xmm5;
        *(r15 + 0x18) = xmm1;
    }
    if (r14 != 0x0) {
        *r14 = xmm6;
        *(r14 + 0x8) = xmm3;
        *(r14 + 0x10) = xmm8;
        *(r14 + 0x18) = xmm1;
    }
    return rax;
     */
}




-(void)drawButtonIn {
    
    /*
    if (rdi.fieldEditor != 0x0) {
        rax = [rdi string];
        rax = [rax length];
        if (rax != 0x0) {
            rax = &arg_0;
            var_56 = *(rax + 0x8) + *0x1001b0c18;
            var_48 = *rax + *0x1001b0c30;
            if (rbx.buttonPressed == 0x1) {
                rsi = @selector(grayColor);
            }
            else {
                rsi = @selector(lightGrayColor);
            }
            rdi = *bind__OBJC_CLASS_$_NSColor;
            rbx = *objc_msgSend;
            rax = (*objc_msgSend)(rdi, rsi);
            [rax setFill];
            var_64 = var_48;
            var_72 = var_56;
            rax = 0x402c000000000000;
            var_80 = rax;
            var_88 = rax;
            r14 = *objc_msgSend;
            rcx = var_72;
            rax = [NSBezierPath bezierPathWithRoundedRect:rdx xRadius:rcx yRadius:r8];
            [rax fill];
            rax = [NSBezierPath bezierPath];
            rbx = rax;
            var_40 = var_48 + *0x1001b0c10;
            var_32 = var_56 + *0x1001b0c60;
            [rbx moveToPoint:rdx];
            var_48 = var_48 + *0x1001b0c60;
            var_56 = var_56 + *0x1001b0c10;
            [rbx lineToPoint:rdx];
            [rbx moveToPoint:rdx];
            [rbx lineToPoint:rdx];
            rax = [NSColor whiteColor];
            [rax setStroke];
            [rbx setLineWidth:rdx];
            rax = [rbx stroke];
        }
    }
    return rax;
     */
}



@end
