//
//  DDSendingTextView.m
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDSendingTextView.h"
#import "NSString+DDStringAdditions.h"

@implementation DDSendingTextView
@synthesize sendingEnabled;


- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)aTextContainer
{
	if ((self = [super initWithFrame:frameRect textContainer:aTextContainer])) {
		[self _initSendingTextView];
	}
    
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder])) {
		[self _initSendingTextView];
	}
	
	return self;
}

- (void)_initSendingTextView
{
	nextIsReturn = NO;
	nextIsEnter = NO;
	optionPressedWithNext = NO;
    target = nil;
	selector = nil;
	sendingEnabled = YES;
    
    NSFont *font = [NSFont userFontOfSize:14];
    [self setFont:font];
}

- (void)setTarget:(id)inTarget action:(SEL)inSelector
{
    target = inTarget;
    selector = inSelector;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSendingTextView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)interpretKeyEvents:(NSArray *)eventArray{
    NSUInteger 	idx = 0;
	NSUInteger	numEvents = [eventArray count];
    
    while (idx < numEvents) {
		NSEvent		*theEvent = [eventArray objectAtIndex:idx];
		
        if ([theEvent type] == NSKeyDown) {
			unichar lastChar = [[theEvent charactersIgnoringModifiers] lastCharacter];
            if (lastChar == NSCarriageReturnCharacter || lastChar == NSEnterCharacter) {
				nextIsReturn = YES;
                
				optionPressedWithNext = ([theEvent modifierFlags] & NSAlternateKeyMask) != 0;
            }
        }
		
		idx++;
    }
	
    [super interpretKeyEvents:eventArray];
}

// special characters only work at the end of a string of input
- (void)insertText:(id)aString
{
	BOOL 		insertText = YES;
	NSString	*theString = nil;
	
	if ([aString isKindOfClass:[NSString class]]) {
        theString = aString;
    } else if ([aString isKindOfClass:[NSAttributedString class]]) {
        theString = [aString string];
    }
	
	if ((sendingEnabled) && nextIsReturn &&
		([theString hasSuffix:@"\n"] && !optionPressedWithNext)) {
		
		//Make sure we insert any applicable text first
		if ([theString length] > 1) {
			NSRange range = NSMakeRange(0, [theString length]-1);
			if ([aString isKindOfClass:[NSString class]]) {
				[super insertText:[aString substringWithRange:range]];
			} else if ([aString isKindOfClass:[NSAttributedString class]]) {
				[super insertText:[aString attributedSubstringFromRange:range]];
			}
		}
		
		//Now send
		[self sendContent:nil]; //Send the content
		insertText = NO;
	}
    
	if (insertText) [super insertText:aString];
}

//'Send' our content
- (IBAction)sendContent:(id)sender
{



    [target performSelector:selector withObject:self];
    
//    NSString *msg =[[self textStorage] string];
//    if (msg && [msg length]>0) {
//        [self setString:@""];
//        //fromUserId,toUserId.
//        NSMutableData *data =[MGJIMData getSendMsgData:userId toUser:[[duoduo accountController] getMyUserId] content:msg];
//        //发送之前需要经过过滤器处理一下,过滤掉发图..
//        
//        [duoduo sendMsgToServer:data];
//    }
}

//-(void)paste:(id)sender{
//    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
//    BOOL isExtractOK = [self extractContentFromPasteboard:pasteBoard isFilePrefered:NO];
//    if (!isExtractOK) {
//        [super paste:sender];
//    }
//}

-(BOOL)extractContentFromPasteboard:(NSPasteboard *)pasteBoard isFilePrefered:(BOOL)isFilePrefered{
    
   /*
    NSArray *typeArray = [[NSArray alloc] initWithObjects:[NSAttributedString class],[NSString class],[NSURL class],[self class],nil];
   NSArray *readObjectArray =  [pasteBoard readObjectsForClasses:typeArray options:[NSDictionary dictionary]];
    if (readObjectArray) {
        for (id readObjects in readObjectArray) {
            if ([readObjects isKindOfClass:[NSAttributedString class]]) {
                
            }else  if ([readObjects isKindOfClass:[NSAttributedString class]]) {
                
            }else if ([readObjects isKindOfClass:[NSString class]]) {
                
            }else  if ([readObjects isKindOfClass:[NSURL class]]) {
                
            }else  if ([readObjects isKindOfClass:[self class]]) {
                
            }
        }
    }
    
    var_24 = rdx;       //pasteBoard
    var_16 = rdi;       //self
    var_240 = **__stack_chk_guard;
    rax = [NSArray alloc];
    var_40 = rax;
    rbx = objc_msg_class;
    rax = [NSAttributedString class];
    r15 = rax;
    rax = [NSString class];
    r12 = rax;
    rax = [NSURL class];
    r13 = rax;
    rax = [*0x1002c2460 class];
    r14 = *objc_msgSend;
    r8 = r13;
    rax = [var_40 initWithObjects:r15];
    rbx = rax;
    var_8 = rbx;
    rax = [NSDictionary dictionary];
    rax = [var_24 readObjectsForClasses:rbx options:rax];
    var_40 = rax;
    if (rax != 0x0) {
        rax = [var_40 countByEnumeratingWithState:&var_176 objects:&var_48 count:0x10];
        if (rax != 0x0) {
            var_32 = *var_192;
            do {
                rbx = 0x0;
                do {
                    if (*var_192 != var_32) {
                        objc_enumerationMutation(var_40);
                    }
                    rax = [NSAttributedString class];
                    rax = [*(var_184 + rbx * 0x8) isKindOfClass:rax];
                    if (rax == 0x0) {
                        rax = [NSString class];
                        rax = [r13 isKindOfClass:rax];
                        if (rax == 0x0) {
                            rax = [NSURL class];
                            rax = [r13 isKindOfClass:rax];
                            if (rax == 0x0) {
                                rax = [*0x1002c2460 class];
                                [r13 isKindOfClass:rax];
                            }
                        }
                    }
                } while (rbx + 0x1 < r14);
                rax = [var_40 countByEnumeratingWithState:&var_176 objects:&var_48 count:0x10];
            } while (rax != 0x0);
        }
    }
    [var_8 release];
    r14 = *objc_msgSend;
    rax = [var_24 types];
    rax = [rax containsObject:**NSFilenamesPboardType];
    rbx = var_16;
    if (rax == 0x0) goto loc_0x10005eec5;
    goto loc_10005ee77;
    
loc_10005eec5:
    rax = [r15 containsObject:**NSStringPboardType];
    if (rax == 0x0) goto loc_0x10005ef0e;
    goto loc_10005eee3;
    
loc_10005ef0e:
    rax = [r15 containsObject:**NSTIFFPboardType];
    rcx = 0x0;
    if (rax == 0x0) goto loc_0x10005ef57;
    goto loc_10005ef2e;
    
loc_10005ef57:
    if (**__stack_chk_guard == var_240) {
        return rcx & 0xff;
    }
    else {
        rax = __stack_chk_fail();
    }
    return rax;
    
loc_10005ef2e:
    r14 = *objc_msgSend;
    rax = [rbx getImageArrayFromPasteboard:r12];
    rax = [rbx addImages:rax];
    
loc_10005ef55:
    rcx = 0x1;
    goto loc_10005ef57;
    
loc_10005eee3:
    r14 = *objc_msgSend;
    rax = [rbx getAttributeStringArrayFromPasteboard:r12];
    rax = [rbx addAttributeString:rax isFilePrefered:0x0];
    goto loc_10005ef55;
    
loc_10005ee77:
    rax = [rbx getFileArrayFromPasteboard:r12];
    if (rax == 0x0) goto loc_0x10005eec5;
    rax = [rbx getFileArrayFromPasteboard:r12];
    rcx = 0x1;
    if (rax == 0x0) goto loc_0x10005ef57;
    rax = [rbx addFiles:rax];
    goto loc_10005ef55;
    
    */
    
    return NO;
}

@end
