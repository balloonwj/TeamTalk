//
//  DDChattingInputView.m
//  Duoduo
//
//  Created by zuoye on 13-12-3.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDChattingInputView.h"
#import "AIAttributedStringAdditions.h"
#import "NSString+DDStringAdditions.h"
#import "AITextAttachmentExtension.h"
#import "AIPasteboardAdditions.h"
#import "DDAtUserListViewController.h"
#import "AIImageAdditions.h"
#import "AFHTTPRequestOperation.h"
#import "MTUserEntity.h"
#import "MTMessageModule.h"
#import "DDEmotionAttachment.h"
#import "DDWindowAdditions.h"
#import "NSAttributedString+Message.h"
#import "MTDatabaseUtil.h"
#import "DDSendP2PCmdAPI.h"
#import "DDChangableAttactment.h"
#import "DDPathHelp.h"
#import "MTImageCache.h"
#define MAX_HISTORY					25	// Number of messages to remember in history
#define FILES_AND_IMAGES_TYPES [NSArray arrayWithObjects: \
NSFilenamesPboardType, AIiTunesTrackPboardType, NSTIFFPboardType, NSPDFPboardType, nil]

#define PASS_TO_SUPERCLASS_DRAG_TYPE_ARRAY [NSArray arrayWithObjects: \
NSRTFPboardType, NSStringPboardType, nil]

@interface DDChattingInputView()

@end

#pragma mark -

@interface NSMutableAttributedString (DDChattingInputViewAdditions)

- (void)convertForPasteWithTraitsUsingAttributes:(NSDictionary *)inAttributes;
- (NSAttributedString *)attributedStringWithAITextAttachmentExtensionsFromRTFDData:(NSData *)data;
- (NSAttributedString *)attributedStringWithTextAttachmentExtension:(AITextAttachmentExtension *)attachment;
- (void)addAttachmentsFromPasteboard:(NSPasteboard *)pasteboard;
- (void)addAttachmentOfPath:(NSString *)inPath;
- (void)addAttachmentOfImage:(NSImage *)inImage;
- (DDEmotionAttachment*)emotionAttachmentForFileName:(NSString*)fileName;


@end

#pragma mark - DDChattingInputView

@implementation DDChattingInputView
{
    BOOL isAt;
    NSPopover* _atPopover;
    DDAtUserListViewController *_atUserListViewController;
}


- (NSPopover*)atPopover
{
    if (!_atPopover)
    {
        _atPopover = [[NSPopover alloc] init];
        _atPopover.animates = YES;
        _atPopover.appearance = NSPopoverAppearanceMinimal;
        _atPopover.behavior = NSPopoverBehaviorTransient;
        if (!_atUserListViewController) {
            _atUserListViewController = [[DDAtUserListViewController alloc] initWithNibName:@"DDAtUserListViewController" bundle:nil ];
        }
        _atPopover.contentViewController =_atUserListViewController;
    }
    return _atPopover;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[self setTextContainerInset:NSMakeSize(1, 5)];
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

// Init the text view
- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)aTextContainer
{
  
	if ((self = [super initWithFrame:frameRect textContainer:aTextContainer])) {
		[self _initMessageEntryTextView];
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
        isAt= YES;
	}
	
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
   
	if ((self = [super initWithCoder:coder])) {
		[self _initMessageEntryTextView];
	}
	
	return self;
}

- (BOOL)resignFirstResponder
{
    if (sessonEntity.sessionType == SessionTypeSessionTypeSingle)
    {

        DDSendP2PCmdAPI* sendP2PCmdAPI = [[DDSendP2PCmdAPI alloc] init];
        NSString *fromUserId = [[DDClientState shareInstance] userID];
        NSString *toId = sessonEntity.originID;
        NSString* content = [DDSendP2PCmdAPI contentFor:INPUTING_SERVICEID commandID:STOP_INPUTTING_COMMAND content:STOP_INPUTING];
        NSArray* object = @[fromUserId,toId,content,@(1000)];
        log4CInfo(@"message ack from userID：%@",fromUserId);
        
        [sendP2PCmdAPI requestWithObject:object Completion:nil];
    }
    return YES;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{

}

- (NSDragOperation)dragOperationForDraggingInfo:(id <NSDraggingInfo>)dragInfo type:(NSString *)type
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if ( [sender draggingSource] != self ) {
        //set the image using the best representation we can get from the pasteboard
        
        //if the drag comes from a file, set the window title to the filename
        if ([NSURL URLFromPasteboard: [sender draggingPasteboard]])
        {
            NSURL* fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
            
            NSString* urlAbsoluteURL = [fileURL absoluteString];
            if ([urlAbsoluteURL hasPrefix:@"file://"])
            {
                NSString* filePath = [fileURL path];
                NSAttributedString* attribute = [NSAttributedString imageAttributedString:filePath realImageURL:nil compressImage:NO];
                [self insertText:attribute];

            }
            else if ([urlAbsoluteURL hasPrefix:@"http://"])
            {
                NSString* filePath = [[MTImageCache shareInstance] filePathWithKey:urlAbsoluteURL];
                if (filePath)
                {
                    NSAttributedString* attribute = [NSAttributedString imageAttributedString:filePath realImageURL:nil compressImage:NO];
                    [self insertText:attribute];
                }
                else
                {
                    //图片没有下载好
//                    NSAttributedString* attribute = [NSAttributedString imageAttributedString:urlAbsoluteURL realImageURL:nil compressImage:NO];
//                    [self insertText:attribute];
                }
            }
        }
        else
        {
            NSPasteboard *pb = [sender draggingPasteboard];
            NSArray* pasteItems = [pb pasteboardItems];
            NSPasteboardItem* lastItem = [pasteItems lastObject];
            NSData* data = [lastItem dataForType:NSPasteboardTypeRTFD];
            NSAttributedString* dragAttribute = [[NSAttributedString alloc] initWithRTFD:data documentAttributes:NULL];
            if ([dragAttribute length] > 0)
            {
                [self insertText:dragAttribute];
                return YES;
            }

            if ([[pb types] containsObject:NSPasteboardTypeString])
            {
                NSString* draggedString = [pb stringForType:NSPasteboardTypeString];
                [self insertText:draggedString];
                [self setSelectedRange:NSMakeRange([self.textStorage length], 0)];
                return YES;
            }
        }
    }
    return YES;
}

- (void)setSessionEntity: (MTSessionEntity *)session
{
    sessonEntity = session;
}

- (NSImage *)currentImage
{
    
    NSAttributedString *text = self.textStorage;

   // NSRange selectedRange = self.selectedRange;
    
    //find images from text.
    DDLog(@" text.length:%lu",text.length);
    if (text.length ) {
        for (int i=0; i<text.length; i++) {
            NSTextAttachment *attachment = [text attribute:NSAttachmentAttributeName atIndex:i effectiveRange:NULL];
            
            if (attachment) {
                NSImage *image = nil;
                
                if ([attachment respondsToSelector:@selector(image)])
                    image = [attachment performSelector:@selector(image)];
                else if ([[attachment attachmentCell] respondsToSelector:@selector(image)])
                    image = [[attachment attachmentCell] performSelector:@selector(image)];
                
                return image;
            }

        }
    }
    
	
	return nil;
}


- (void)_initMessageEntryTextView
{
	historyArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
    sendQueue = [[NSMutableArray alloc] initWithObjects:@"", nil];
	currentHistoryLocation = 0;

    [self setRichText:NO];
}

-(void)keyDown:(NSEvent *)inEvent{
    NSString *charactersIgnoringModifiers = [inEvent charactersIgnoringModifiers];
    
    
    if ([charactersIgnoringModifiers length]) {
		unichar		 inChar = [charactersIgnoringModifiers characterAtIndex:0];
		NSUInteger flags = [inEvent modifierFlags];
		
		 if (inChar == NSEnterCharacter || inChar == NSCarriageReturnCharacter) {
			//Make shift+enter work the same as option+enter
			if (flags & NSShiftKeyMask) {
				[super insertLineBreak:self];
			} else {
				[super keyDown:inEvent];
			}
			
		} else {
			[super keyDown:inEvent];
		}
	} else {
		[super keyDown:inEvent];
	}

    /*
    if (isAt &&  [[inEvent characters] isEqualToString:@"@"]) {
        NSLog(@"可以@出一个人");
        
        [self.atPopover showRelativeToRect:NSMakeRect(self.selectedRange.location, 5, 1, 1)
                                    ofView:[self superview]
                             preferredEdge:NSMinYEdge];
    }
    if([[inEvent characters] isEqualToString:@" "]){
        isAt= YES;
    }else{
        isAt=NO;
    }
     */
}

-(void)insertText:(id)insertString{
    [super insertText:insertString];
}

// Update history when content is sent
- (IBAction)sendContent:(id)sender
{
	NSAttributedString	*textStorage = [self textStorage];
	
	// Add to history if there is text being sent
	[historyArray insertObject:[textStorage copy] atIndex:1];
	if ([historyArray count] > MAX_HISTORY) {
		[historyArray removeLastObject];
	}
    
    
    
	currentHistoryLocation = 0; // Move back to bottom of history
    
	// Send the content
	[super sendContent:sender];
	
	// Clear the undo/redo stack as it makes no sense to carry between sends (the history is for that)
	[[self undoManager] removeAllActions];
}

- (void)pasteAsPlainTextWithTraits:(id)sender
{
	NSDictionary	*attributes = [[self typingAttributes] copy];
	
	NSPasteboard	*generalPasteboard = [NSPasteboard generalPasteboard];
	NSString		*type;
    
	NSArray *supportedTypes =
    [NSArray arrayWithObjects:NSURLPboardType, NSRTFDPboardType, NSRTFPboardType, NSHTMLPboardType, NSStringPboardType,
     NSFilenamesPboardType, NSTIFFPboardType, NSPDFPboardType, nil];
    
	type = [[NSPasteboard generalPasteboard] availableTypeFromArray:supportedTypes];
	
	if ([type isEqualToString:NSRTFPboardType] ||
		[type isEqualToString:NSRTFDPboardType] ||
		[type isEqualToString:NSHTMLPboardType] ||
		[type isEqualToString:NSStringPboardType]) {
		NSData *data;
		
		@try {
			data = [generalPasteboard dataForType:type];
		} @catch (NSException *localException) {
			data = nil;
		}
		
		// Failed. Try again with the string type.
		if (!data && ![type isEqualToString:NSStringPboardType]) {
			if ([[[NSPasteboard generalPasteboard] types] containsObject:NSStringPboardType]) {
				type = NSStringPboardType;
				@try {
					data = [generalPasteboard dataForType:type];
				} @catch (NSException *localException) {
					data = nil;
				}
			}
		}
		
		if (!data) {
			// We still didn't get valid data... maybe super can handle it
			@try {
				[self paste:sender];
			} @catch (NSException *localException) {
				NSBeep();
				return;
			}
		}
		
		NSMutableAttributedString *attributedString;
		
		if ([type isEqualToString:NSStringPboardType]) {
			NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			attributedString = [[NSMutableAttributedString alloc] initWithString:string
																	  attributes:[self typingAttributes]];
			
		} else {
			@try {
				if ([type isEqualToString:NSRTFPboardType]) {
					attributedString = [[NSMutableAttributedString alloc] initWithRTF:data
																   documentAttributes:NULL];
				} else if ([type isEqualToString:NSRTFDPboardType]) {
					attributedString = [[NSMutableAttributedString alloc] initWithRTFD:data
																	documentAttributes:NULL];
				} else /* NSHTMLPboardType */ {
					attributedString = [[NSMutableAttributedString alloc] initWithHTML:data
																	documentAttributes:NULL];
				}
			} @catch (NSException *localException) {
				// Error while reading the RTF or HTML data, which can happen. Fall back on plain text
				if ([[[NSPasteboard generalPasteboard] types] containsObject:NSStringPboardType]) {
					data = [generalPasteboard dataForType:NSStringPboardType];
					NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					attributedString = [[NSMutableAttributedString alloc] initWithString:string
																			  attributes:[self typingAttributes]];
				} else {
					attributedString = nil;
				}
			}
            
			if (!attributedString) {
				NSBeep();
				return;
			}
            
			[attributedString convertForPasteWithTraitsUsingAttributes:[self typingAttributes]];
		}
		
		NSRange			selectedRange = [self selectedRange];
		NSTextStorage	*textStorage = [self textStorage];
		
		// Prepare the undo operation
		NSUndoManager	*undoManager = [self undoManager];
		[[undoManager prepareWithInvocationTarget:textStorage]
         replaceCharactersInRange:NSMakeRange(selectedRange.location, [attributedString length])
         withAttributedString:[textStorage attributedSubstringFromRange:selectedRange]];
		[undoManager setActionName:@"Paste"];
		
		// Perform the paste
        
        for (NSInteger index = 0; index < [attributedString length];index ++)
        {
            NSTextAttachment *attachment = [attributedString attribute:NSAttachmentAttributeName atIndex:index effectiveRange:NULL];
            NSString* preferredFileName = attachment.fileWrapper.preferredFilename;
            if (preferredFileName)
            {
                
            }
            DDLog(@"asd,%@",attachment.fileWrapper.preferredFilename);
        }
        
		[textStorage replaceCharactersInRange:selectedRange
						 withAttributedString:attributedString];
		// Align our text properly (only need to if the first character was changed)
			// Notify that we changed our text
		[[NSNotificationCenter defaultCenter] postNotificationName:NSTextDidChangeNotification
															object:self];
        
	} else if ([FILES_AND_IMAGES_TYPES containsObject:type]) {
		if (![self handlePasteAsRichText]) {
			[super paste:sender];
		}
	} else if ([type isEqualToString:NSURLPboardType])
    {
//        NSString* url = [generalPasteboard stringForType:type];
        NSArray* propertys = [generalPasteboard propertyListForType:type];
        if ([propertys count] > 0)
        {
            NSString* url = propertys[0];
            url = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                        (CFStringRef)url,
                                                                                                        CFSTR(""),
                                                                                                        kCFStringEncodingUTF8));
            if ([url hasPrefix:@"file://localhost"])
            {
                NSString* filePath = [url substringFromIndex:16];
                NSAttributedString* attribute = [NSAttributedString imageAttributedString:filePath realImageURL:nil compressImage:NO];
                [self insertText:attribute];
            }
            else if ([url hasPrefix:@"http://msfs.tt.mogujie.org/"])
            {
                NSString* filePath = [[MTImageCache shareInstance] filePathWithKey:url];
                if (filePath)
                {
                    NSAttributedString* attribute = [NSAttributedString imageAttributedString:filePath realImageURL:nil compressImage:NO];
                    [self insertText:attribute];
                }
                else
                {
                    [super paste:sender];
                }
            }
            else if ([url hasPrefix:@"file://"])
            {
                NSString* filePath = [url substringFromIndex:7];
                NSAttributedString* attribute = [NSAttributedString imageAttributedString:filePath realImageURL:nil compressImage:NO];
                [self insertText:attribute];
            }
            else
            {
                [super paste:sender];
            }
        }
    }
    else {
		// If we didn't handle it yet, let super try to deal with it
		[super paste:sender];
	}
    
	if (attributes) {
		[self setTypingAttributes:attributes];
	}
    
    [self scrollToEndOfDocument:nil];
    
//	[self scrollRangeToVisible:[self selectedRange]];
}

-(void)copy:(id)sender{
    NSRange range = [self selectedRange];
    if (range.length!=0) {
        NSMutableAttributedString *mat = [[NSMutableAttributedString alloc] init];
        [mat appendAttributedString:[[self textStorage] attributedSubstringFromRange:range]];
        if ([mat length]!=0) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            NSArray *arrgy = [NSArray arrayWithObject:mat];
            [pasteboard writeObjects:arrgy];
        }
    }
}

- (void)paste:(id)sender{
    DDLog(@" >>>>>>> paste>>>>>>> ");
    [self pasteAsPlainTextWithTraits:sender];
}


- (void)addAttachmentsFromPasteboard:(NSPasteboard *)pasteboard
{
	NSString *availableType;
	if ((availableType = [pasteboard availableTypeFromArray:[NSArray arrayWithObjects:NSFilenamesPboardType, AIiTunesTrackPboardType, nil]])) {
		// The pasteboard points to one or more files on disc.  Use them directly.
		NSArray	*files = nil;
        
		if ([availableType isEqualToString:NSFilenamesPboardType]) {
			files = [pasteboard propertyListForType:NSFilenamesPboardType];
			
		} else if ([availableType isEqualToString:AIiTunesTrackPboardType]) {
			files = [pasteboard filesFromITunesDragPasteboard];
		}
		NSString *path;
		for (path in files) {
			[self addAttachmentOfPath:path];
		}
	} else {
		// The pasteboard contains image data with no corresponding file.
		NSImage	*image = [[NSImage alloc] initWithPasteboard:pasteboard];
		[self addAttachmentOfImage:image];
	}	
}


#pragma mark touch
- (void)rightMouseDown:(NSEvent *)theEvent
{
    DDLog(@"right mouse down");
    NSMenu* menu = [[NSMenu alloc] init];
    
    NSMenuItem* saveItem = [[NSMenuItem alloc] initWithTitle:@"保存" action:@selector(p_saveImageSource) keyEquivalent:@""];
    [saveItem setTarget:self];
    
    NSMenuItem* savePathItem = [[NSMenuItem alloc] initWithTitle:@"另存为" action:@selector(p_saveImageAtPath) keyEquivalent:@""];
    [savePathItem setTarget:self];
    
//    if ([self.textStorage.string length] >= self.currentIndex)
//    {
//        [super rightMouseDown:theEvent];
//        return;
//    }
    
    @try {
        AITextAttachmentExtension* attachment = [self.textStorage attribute:NSAttachmentAttributeName atIndex:self.currentIndex effectiveRange:NULL];
        NSData* fileData = [[attachment fileWrapper] regularFileContents];
        if (fileData)
        {
            [saveItem setEnabled:YES];
            [savePathItem setEnabled:YES];
            [menu addItem:saveItem];
            [menu addItem:savePathItem];
            [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
        }
        else
        {
            [super rightMouseDown:theEvent];
        }
    }
    @catch (NSException *exception) {
        self.currentIndex = 0;
        [super rightMouseDown:theEvent];
    }
    @finally {
        
    }
    
}


#pragma mark - Attachments

/*!
 * @brief Add an attachment of the file at inPath at the current insertion point
 *
 * @param inPath The full path, whose contents will not be loaded into memory at this time
 */
- (void)addAttachmentOfPath:(NSString *)inPath
{
	if ([[inPath pathExtension] caseInsensitiveCompare:@"textClipping"] == NSOrderedSame) {
		inPath = [inPath stringByAppendingString:@"/..namedfork/rsrc"];
        
		NSData *data = [NSData dataWithContentsOfFile:inPath];
		
        if (data) {
			data = [data subdataWithRange:NSMakeRange(260, [data length] - 260)];
			
			NSAttributedString *clipping = [[NSAttributedString alloc] initWithRTF:data documentAttributes:nil];
			
            if (clipping) {
				NSDictionary *attributes = [[self typingAttributes] copy];
				
				[self insertText:clipping];
                
				if (attributes) {
					[self setTypingAttributes:attributes];
				}
			}
		}
	} else {
		AITextAttachmentExtension   *attachment = [[AITextAttachmentExtension alloc] init];
		[attachment setPath:inPath];
		[attachment setString:[inPath lastPathComponent]];
		[attachment setShouldSaveImageForLogging:YES];
		
		// Insert an attributed string into the text at the current insertion point
		[self insertText:[self attributedStringWithTextAttachmentExtension:attachment]];
	}
}

/*!
 * @brief Add an attachment of inImage at the current insertion point
 */
- (void)addAttachmentOfImage:(NSImage *)inImage
{
	AITextAttachmentExtension   *attachment = [[AITextAttachmentExtension alloc] init];
	
	[attachment setImage:inImage];
	[attachment setShouldSaveImageForLogging:YES];

	
	// Insert an attributed string into the text at the current insertion point
	[self insertText:[self attributedStringWithTextAttachmentExtension:attachment]];
	
}


- (BOOL)handlePasteAsRichText
{
	NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
	BOOL		 handledPaste = NO;
	
	// Types is ordered by the preference for handling of the data; enumerating it lets us allow the sending application's hints to be followed.
	for (NSString *type in generalPasteboard.types) {
		if ([type isEqualToString:NSRTFDPboardType]) {
			NSData *data = [generalPasteboard dataForType:NSRTFDPboardType];
			[self insertText:[self attributedStringWithAITextAttachmentExtensionsFromRTFDData:data]];
			handledPaste = YES;
			
		} else if ([PASS_TO_SUPERCLASS_DRAG_TYPE_ARRAY containsObject:type]) {
			// When we hit a type we should let the superclass handle, break without doing anything
			break;
			
		} else if ([FILES_AND_IMAGES_TYPES containsObject:type]) {
			[self addAttachmentsFromPasteboard:generalPasteboard];
			handledPaste = YES;
		} else if ([type isEqualToString:NSHTMLPboardType]) {
			NSData *htmlData = [generalPasteboard dataForType:NSHTMLPboardType];
			[self insertText:[[NSAttributedString alloc] initWithData:htmlData
															  options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
                                                                        NSWebResourceLoadDelegateDocumentOption: self}
												   documentAttributes:NULL error:NULL]];
			handledPaste = YES;
		}
		
		if (handledPaste) break;
		
	}
	
	return handledPaste;
}

/*!
 * @brief Given RTFD data, return an NSAttributedString whose attachments are all AITextAttachmentExtension objects
 */
- (NSAttributedString *)attributedStringWithAITextAttachmentExtensionsFromRTFDData:(NSData *)data
{
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithRTFD:data
                                                                               documentAttributes:NULL];
	if ([attributedString length] && [attributedString containsAttachments]) {
		NSUInteger							currentLocation = 0;
		NSRange						attachmentRange;
		
		NSString					*attachmentCharacterString = [NSString stringWithFormat:@"%C",(unichar)NSAttachmentCharacter];
		
		// Find each attachment
		attachmentRange = [[attributedString string] rangeOfString:attachmentCharacterString
														   options:0
															 range:NSMakeRange(currentLocation,
																			   [attributedString length])];
		while (attachmentRange.length != 0) {
			// Found an attachment in at attachmentRange.location
			NSTextAttachment	*attachment = [attributedString attribute:NSAttachmentAttributeName
                                                               atIndex:attachmentRange.location
                                                        effectiveRange:nil];
            
			// If it's not already an AITextAttachmentExtension, make it into one
			if (![attachment isKindOfClass:[AITextAttachmentExtension class]]) {
				NSAttributedString	*replacement;
				NSFileWrapper		*fileWrapper = [attachment fileWrapper];
				NSString			*destinationPath;
				NSString			*preferredName = [fileWrapper preferredFilename];
				
				// Get a unique folder within our temporary directory
				destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
				[[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:NULL];
				destinationPath = [destinationPath stringByAppendingPathComponent:preferredName];
				
				// Write the file out to it
				[fileWrapper writeToFile:destinationPath
							  atomically:NO
						 updateFilenames:NO];
				
				// Now create an AITextAttachmentExtension pointing to it
				AITextAttachmentExtension   *textAttachment = [[AITextAttachmentExtension alloc] init];
				[textAttachment setPath:destinationPath];
				[textAttachment setString:preferredName];
				[textAttachment setShouldSaveImageForLogging:YES];
                
				// Insert an attributed string into the text at the current insertion point
				replacement = [self attributedStringWithTextAttachmentExtension:textAttachment];
				
				// Remove the NSTextAttachment, replacing it the AITextAttachmentExtension
				[attributedString replaceCharactersInRange:attachmentRange
									  withAttributedString:replacement];
				
				attachmentRange.length = [replacement length];
			}
			
			currentLocation = attachmentRange.location + attachmentRange.length;
			
			
			// Find the next attachment
			attachmentRange = [[attributedString string] rangeOfString:attachmentCharacterString
															   options:0
																 range:NSMakeRange(currentLocation,
																				   [attributedString length] - currentLocation)];
		}
	}
    
	return attributedString;
}

/*!
 * @brief Generate an NSAttributedString which contains attachment and displays it using attachment's iconImage
 */
- (NSAttributedString *)attributedStringWithTextAttachmentExtension:(AITextAttachmentExtension *)attachment
{
	NSTextAttachmentCell		*cell = [[NSTextAttachmentCell alloc] initImageCell:[attachment iconImage]];
	
	[attachment setHasAlternate:NO];
	[attachment setAttachmentCell:cell];
	
	return [NSAttributedString attributedStringWithAttachment:attachment];
    
}

#pragma mark -
#pragma mark privateAPI
- (void)p_saveImageSource
{
    
    for(int i = 0;i < [self.textStorage length]; i ++)
    {
        if (i == self.currentIndex)
        {
            AITextAttachmentExtension* attachment = [self.textStorage attribute:NSAttachmentAttributeName atIndex:self.currentIndex effectiveRange:NULL];
            NSData* fileData = [[attachment fileWrapper] regularFileContents];
            if (fileData)
            {
                NSString* copyFileName = [NSString stringWithFormat:@"TeamTalk-Image-%li.png",(NSUInteger)[[NSDate date] timeIntervalSince1970]];
                NSString* copyFilePath = [[DDPathHelp downLoadPath] stringByAppendingPathComponent:copyFileName];
                [fileData writeToFile:copyFilePath atomically:YES];

            }
        }
    }
}

- (void)p_saveImageAtPath
{
    __block NSSavePanel *panel = [NSSavePanel savePanel];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for(int i = 0;i < [self.textStorage length]; i ++)
            {
                if (i == self.currentIndex)
                {
                    AITextAttachmentExtension* attachment = [self.textStorage attribute:NSAttachmentAttributeName atIndex:self.currentIndex effectiveRange:NULL];
                    NSData* fileData = [[attachment fileWrapper] regularFileContents];
                    if (fileData)
                    {
                        NSString* savePath = [[panel URL] path];
                        NSString* lastComponent = [savePath lastPathComponent];
                        if ([lastComponent rangeOfString:@".png"].length == 0)
                        {
                            savePath = [savePath stringByAppendingString:@".png"];
                        }
                        [fileData writeToFile:savePath atomically:YES];
                    }
                }
            }
        }
        
        panel=nil;
    }];
}

@end



#pragma mark -

@implementation NSMutableAttributedString (DDChattingInputViewAdditions)

- (void)convertForPasteWithTraitsUsingAttributes:(NSDictionary *)typingAttributes;
{
	NSRange fullRange = NSMakeRange(0, [self length]);
    
	// Remove non-trait attributes
	if ([typingAttributes objectForKey:NSBackgroundColorAttributeName]) {
		[self addAttribute:NSBackgroundColorAttributeName
					 value:[typingAttributes objectForKey:NSBackgroundColorAttributeName]
					 range:fullRange];
        
	} else {
		[self removeAttribute:NSBackgroundColorAttributeName range:fullRange];
	}
    
	if ([typingAttributes objectForKey:NSForegroundColorAttributeName]) {
		[self addAttribute:NSForegroundColorAttributeName
					 value:[typingAttributes objectForKey:NSForegroundColorAttributeName]
					 range:fullRange];
		
	} else {
		[self removeAttribute:NSForegroundColorAttributeName range:fullRange];
	}
    
	if ([typingAttributes objectForKey:NSParagraphStyleAttributeName]) {
		[self addAttribute:NSParagraphStyleAttributeName
					 value:[typingAttributes objectForKey:NSParagraphStyleAttributeName]
					 range:fullRange];
		
	} else {
		[self removeAttribute:NSParagraphStyleAttributeName range:fullRange];
	}
    
	[self removeAttribute:NSBaselineOffsetAttributeName range:fullRange];
	[self removeAttribute:NSCursorAttributeName range:fullRange];
	[self removeAttribute:NSExpansionAttributeName range:fullRange];
	[self removeAttribute:NSKernAttributeName range:fullRange];
	[self removeAttribute:NSLigatureAttributeName range:fullRange];
	[self removeAttribute:NSObliquenessAttributeName range:fullRange];
	[self removeAttribute:NSShadowAttributeName range:fullRange];
	[self removeAttribute:NSStrokeWidthAttributeName range:fullRange];
	
	NSRange			searchRange = NSMakeRange(0, fullRange.length);
	NSFontManager	*fontManager = [NSFontManager sharedFontManager];
	NSFont			*myFont = [typingAttributes objectForKey:NSFontAttributeName];
    
	while (searchRange.location < fullRange.length) {
		NSFont *font;
		NSRange effectiveRange;
		font = [self attribute:NSFontAttributeName
					   atIndex:searchRange.location
		 longestEffectiveRange:&effectiveRange
					   inRange:searchRange];
        
		if (font) {
			NSFontTraitMask thisFontTraits = [fontManager traitsOfFont:font];
			NSFontTraitMask	traits = 0;
			
			if (thisFontTraits & NSBoldFontMask) {
				traits |= NSBoldFontMask;
			} else {
				traits |= NSUnboldFontMask;
			}
            
			if (thisFontTraits & NSItalicFontMask) {
				traits |= NSItalicFontMask;
			} else {
				traits |= NSUnitalicFontMask;
			}
			
			font = [fontManager fontWithFamily:[myFont familyName]
										traits:traits
										weight:[fontManager weightOfFont:myFont]
										  size:[myFont pointSize]];
            
			if (font) {
				[self addAttribute:NSFontAttributeName
							 value:font
							 range:effectiveRange];
			}
		}
        
		searchRange.location = effectiveRange.location + effectiveRange.length;
		searchRange.length = fullRange.length - searchRange.location;
	}
    
}

- (DDEmotionAttachment*)emotionAttachmentForFileName:(NSString*)fileName
{
    return nil;
}

@end