//
//  FMSearchTokenField.m
//  Duoduo
//
//  Created by zuoye on 13-12-23.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "FMSearchTokenField.h"
#import "FMSearchTokenFieldCell.h"

@implementation FMSearchTokenField
@synthesize sendActionWhenEditing=_sendActionWhenEditing;
@synthesize alwaysSendActionWhenPressEnter=_alwaysSendActionWhenPressEnter;


+(void)initialize {
    [FMSearchTokenField setCellClass:[FMSearchTokenFieldCell class]];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sendActionWhenEditing = NO;
        self.alwaysSendActionWhenPressEnter = NO;
        self.m_tokenizingChar = 0x2c;
        /*
         var_32 = rdi;
         var_40 = *0x1002c3b58;
         rax = [[&var_32 super] initWithFrame:edx];
         if (rax != 0x0) {
         rbx.sendActionWhenEditing = 0x0;
         rbx.alwaysSendActionWhenPressEnter = 0x0;
         rax = [NSMutableString alloc];
         rax = [rax init];
         rbx.m_untokenizedStringValue = rax;
         rbx.m_tokenizingChar = 0x2c;  //44
         }
         rax = rbx;
         return rax;

         */
    }
    return self;
}

-(void)setTokenizingChars:(NSString *) chars{
    self.m_tokenizingChar = [chars characterAtIndex:0];
    [self setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:chars]];
}

/*
function methImpl_FMSearchTokenField_tokenCount {
    rbx = rdi;
    rax = [rdi tokenStyle];
    rcx = rax;
    rax = 0x1;
    if (rcx == 0x1) goto loc_0x100111ce7;
    goto loc_100111c3f;
    
loc_100111ce7:
    return rax;
    
loc_100111c3f:
    rax = [rbx currentEditor];
    if (rax == 0x0) goto loc_0x100111cf6;
    goto loc_100111c58;
    
loc_100111cf6:
    rax = [rbx attributedStringValue];
    rax = [rax length];
    
loc_100111c58:
    rax = [rax attributedString];
    rax = [rax length];
    r13 = 0x0;
    if (rax != 0x0) {
        rbx = 0x0;
        r13 = 0x0;
        do {
            rax = [r14 attribute:**NSAttachmentAttributeName atIndex:rbx effectiveRange:0x0];
            r13 = r13 - 0xff + CARRY(CF);
            rax = [r14 length];
        } while (rbx + 0x1 < rax);
    }
    rax = [r14 length];
    rax = ((rax != r13 ? 0xff : 0x0) & 0xff) + r13;
    goto loc_100111ce7;
}
*/

/*
 $rdi == arg0 (ObjC: self)
 $rsi == arg1 (ObjC: op, or _cmd)
 $rdx == arg2 (ObjC: first arg of method)
 $rcx == arg3 (ObjC: second arg of method) cell
 $r8 == arg4 第三个参数
 $r9 == arg5 第四个
 */
- (void)drawRect:(NSRect)dirtyRect{
    
    if([[self subviews] count]>0){
        NSView *view =  [[self subviews] objectAtIndex:0];
        if ([view isKindOfClass:[FMSearchTokenFieldCell class]]) {
            NSRect cellRect ;
            if ([self cell]) {
                cellRect = [[self cell] bounds];
            }
            NSRect imageRect ;
            NSRect textRect;
            
            [(FMSearchTokenFieldCell *)view divideFrame:cellRect ToImageRect:&imageRect textRect:&textRect buttonRect:nil callFromView:YES];
            [view setFrame:cellRect];
        }
    }
    
    /*
    r12 = rdi;
    rax = [rdi subviews];
    rax = [rax count];
    if (rax != 0x0) {
        rax = [rbx objectAtIndex:0x0];
        r14 = rax;
        rax = [*0x1002c29e8 class];
        rax = [r14 isKindOfClass:rax];
        if (rax != 0x0) {
            rax = [r12 cell];
            r15 = rax;
            if (r12 != 0x0) {
                var_80 = [r12 bounds];
            }
            else {
            }
            rbx = *objc_msgSend;
            rdx = 0x0;
            (*objc_msgSend)(r15, @selector(divideFrame:ToImageRect:textRect:buttonRect:callFromView:), rdx, &var_112, 0x0, 0x1);
            var_72 = var_136;
            var_64 = var_128;
            var_56 = var_120;
            var_48 = var_112;
            [r14 setFrame:rdx];
        }
    }
    rax = &arg_0;
    var_32 = r12;
    var_40 = *0x1002c3b58;
    rax = [[&var_32 super] drawRect:edx];
    return rax;
    */
    
	[super drawRect:dirtyRect];
	
}



/*
 function methImpl_FMSearchTokenField_dealloc {
 rbx = rdi;
 r14 = objc_msg_release;
 [rbx.m_buttonTrackingArea release];
 [rbx.m_untokenizedStringValue release];
 var_0 = rbx;
 var_8 = *0x1002c3b58;
 rax = [[&var_0 super] dealloc];
 return rax;
 }
 */

-(void)mouseDown:(NSEvent *)theEvent{
    
}

-(void)mouseUp:(NSEvent *)theEvent{
    
}

-(void)mouseEntered:(NSEvent *)theEvent{
    
}

-(void)mouseExited:(NSEvent *)theEvent{
    
}

-(BOOL)isFlipped{
    return NO;
}

@end

