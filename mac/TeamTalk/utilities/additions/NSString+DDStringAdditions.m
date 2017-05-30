//
//  NSString+DDStringAdditions.m
//  Duoduo
//
//  Created by maye on 13-10-31.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "NSString+DDStringAdditions.h"
#ifndef BSD_LICENSE_ONLY

//#import "AIColorAdditions.h"

#endif //ndef BSD_LICENSE_ONLY

enum characterNatureMask {
	whitespaceNature = (1 << 0), //space + \t\n\r\f\a
	shellUnsafeNature = (1 << 1), //backslash + !$`"'
	regexpUnsafeNature = (1 << 2), //backslash + |.*+?{}()$^
};
static const enum characterNatureMask characterNature[USHRT_MAX+1] = {
	['\a'] = whitespaceNature,
	['\t'] = whitespaceNature,
	['\n'] = whitespaceNature,
	['\v'] = whitespaceNature,
	['\f'] = whitespaceNature,
	['\r'] = whitespaceNature,
	[' ']  = whitespaceNature,
    
	['\''] = shellUnsafeNature,
	['"']  = shellUnsafeNature,
	['`']  = shellUnsafeNature,
	['!']  = shellUnsafeNature,
	['&']  = shellUnsafeNature,
    
	['\\'] = shellUnsafeNature | regexpUnsafeNature,
	['$']  = shellUnsafeNature | regexpUnsafeNature,
	['|']  = shellUnsafeNature | regexpUnsafeNature,
    
	['/']  = regexpUnsafeNature,
	['.']  = regexpUnsafeNature,
	['*']  = regexpUnsafeNature,
	['+']  = regexpUnsafeNature,
	['?']  = regexpUnsafeNature,
	['{']  = regexpUnsafeNature,
	['}']  = regexpUnsafeNature,
	['(']  = regexpUnsafeNature,
	[')']  = regexpUnsafeNature,
	['[']  = regexpUnsafeNature,
	['^']  = regexpUnsafeNature,
};

enum {
	LINE_FEED = '\n',
	FORM_FEED = '\f',
	CARRIAGE_RETURN = '\r',
	NEXT_LINE = 0x0085,
	LINE_SEPARATOR = 0x2028,
	PARAGRAPH_SEPARATOR = 0x2029,
    
	numberOfLineBreakCharacters = 6U
};

@implementation NSString (DDStringAdditions)

#ifndef BSD_LICENSE_ONLY

//Random alphanumeric string
+ (id)randomStringOfLength:(unsigned int)inLength
{
	srandom(TickCount());
    
	if (!inLength) return [self string];
    
	NSString *string = nil;
	char *buf = malloc(inLength);
    
	if (buf) {
		static const char alphanumeric[] = {
			'0', '1', '2', '3', '4', '5', '6', '7',
			'8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
			'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
			'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
			'W', 'X', 'Y', 'Z'
		};
		unsigned remaining = inLength;
		while (remaining--) {
			buf[remaining] = alphanumeric[random() % sizeof(alphanumeric)];
		}
		string = [self stringWithBytes:buf length:inLength encoding:NSASCIIStringEncoding];
		free(buf);
	}
    
	return string;
}

/*
 * @brief Read a string from a file, assuming it to be UTF8
 *
 * If it can not be read as UTF8, it will be read as ASCII.
 */
+ (id)stringWithContentsOfUTF8File:(NSString *)path
{
	if (!path) return nil;
    
	NSString	*string;
	
	NSError	*error = nil;
    
	string = [self stringWithContentsOfFile:path
								   encoding:NSUTF8StringEncoding
									  error:&error];
    
	if (error) {
		BOOL	handled = NO;
        
		if ([[error domain] isEqualToString:NSCocoaErrorDomain]) {
			NSInteger		errorCode = [error code];
            
			if (errorCode == NSFileReadNoSuchFileError) {
				string = nil;
				handled = YES;
                
			} else if (errorCode == NSFileReadInapplicableStringEncodingError) {
				NSError				*newError = nil;
                
				string = [self stringWithContentsOfFile:path
											   encoding:NSASCIIStringEncoding
												  error:&newError];
                
				//If there isn't a new error, we recovered reasonably successfully...
				if (!newError) {
					handled = YES;
				}
			}
		}
        
		if (!handled) {
			DDLog(@"Error reading %@:\n%@; %@.",path,
				  [error localizedDescription], [error localizedFailureReason]);
		}
	}
	
	return string;
}

+ (id)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
	return [[self alloc] initWithData:data encoding:encoding];
}
+ (id)stringWithBytes:(const void *)inBytes length:(unsigned)inLength encoding:(NSStringEncoding)inEncoding
{
	return [[self alloc] initWithBytes:inBytes length:inLength encoding:inEncoding];
}

+ (id)ellipsis
{
	return [self stringWithUTF8String:"\xE2\x80\xA6"];
}

- (NSString *)stringByAppendingEllipsis
{
	return [self stringByAppendingString:[NSString stringWithUTF8String:"\xE2\x80\xA6"]];
}

- (NSString *)stringByTranslatingByOffset:(int)offset
{
	NSMutableString	*newString = [NSMutableString string];
	NSUInteger		i, length = [self length];
    
	for (i = 0 ; i < length ; i++) {
		/* Offset by the desired amount */
		[newString appendFormat:@"%C",(unichar)([self characterAtIndex:i] + offset)];
	}
	
	return newString;
}

/*	compactedString
 *	returns the string in all lowercase without spaces
 */
- (NSString *)compactedString
{
	NSMutableString 	*outName;
	NSUInteger			pos = 0, len;
	NSRange				range = NSMakeRange(0, 0);
	
	outName = [self mutableCopy];
	CFStringLowercase((__bridge CFMutableStringRef)outName, /*locale*/ NULL);
	len = [outName length];
	
	while (pos < len) {
		if ([outName characterAtIndex:pos] == ' ') {
			if (range.length++ == 0) {
				range.location = pos;
			}
			++pos;
		} else {
			if (range.length) {
				[outName deleteCharactersInRange:range];
				pos  = range.location;
				len -= range.length;
				range.length = 0;
			} else {
				++pos;
			}
		}
	}
	
	return outName;
}

#define BUNDLE_STRING	@"$$BundlePath$$"
- (NSString *)stringByExpandingBundlePath
{
    if ([self hasPrefix:BUNDLE_STRING]) {
        return [[[[NSBundle mainBundle] bundlePath] stringByExpandingTildeInPath] stringByAppendingString:[self substringFromIndex:[BUNDLE_STRING length]]];
    } else {
        return [self copy];
    }
}

- (NSString *)stringByCollapsingBundlePath
{
    NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByExpandingTildeInPath];
    
    if ([self hasPrefix:bundlePath]) {
        return [BUNDLE_STRING stringByAppendingString:[self substringFromIndex:[bundlePath length]]];
    } else {
        return [self copy];
    }
}


- (NSString *)stringWithEllipsisByTruncatingToLength:(NSUInteger)length
{
	NSString *returnString;
	
	if (length < [self length]) {
		//Truncate and append the ellipsis
		returnString = [[self substringToIndex:length-1] stringByAppendingString:[NSString ellipsis]];
	} else {
		//We don't need to truncate, so don't append an ellipsis
		returnString = [self copy];
	}
	
	return (returnString);
}

- (NSString *)safeFilenameString
{
	NSUInteger length = [self length];
	
	if (!length)
		return self;
    
	if (length > NAME_MAX) {
		DDLog(@"-safeFilenameString called on a string longer than %u characters (it will be truncated): @\"%@\"", NAME_MAX, self);
		length = NAME_MAX;
	}
    
	NSMutableString *string = [self mutableCopy];
    
	[string replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, length)];
    
	return string;
}

//stringByEncodingURLEscapes
// Percent escape all characters except for a-z, A-Z, 0-9, '_', and '-'
// Convert spaces to '+'
/*
- (NSString *)stringByEncodingURLEscapes
{
	NSData				*UTF8Data = [self dataUsingEncoding:NSUTF8StringEncoding];
	const char			*UTF8 = [UTF8Data bytes];
	char				*destPtr;
	NSMutableData		*destData;
	unsigned	 sourceIndex = 0;
	NSUInteger			 sourceLength = [UTF8Data length];
	unsigned	 destIndex = 0;
    
	//this table translates plusses to spaces, and flags all characters that need hex-encoding with 0x00.
	static const char translationTable[256] = {
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
        ' ',  '!',  '"',  '#',   '$',  '%',  '&', '\'',
        '(',  ')',  '*',  ' ',   ',',  '-',  '.',  '/',
        '0',  '1',  '2',  '3',   '4',  '5',  '6',  '7',
        '8',  '9',  ':',  ';',   '<',  '=',  '>',  '?',
        '@',  'A',  'B',  'C',   'D',  'E',  'F',  'G',
        'H',  'I',  'J',  'K',   'L',  'M',  'N',  'O',
        'P',  'Q',  'R',  'S',   'T',  'U',  'V',  'W',
        'X',  'Y',  'Z',  '[',  '\\',  ']',  '^',  '_',
        '`',  'a',  'b',  'c',   'd',  'e',  'f',  'g',
        'h',  'i',  'j',  'k',   'l',  'm',  'n',  'o',
        'p',  'q',  'r',  's',   't',  'u',  'v',  'w',
        'x',  'y',  'z',  '{',   '|',  '}',  '~', 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
	};
    
	//Worst case scenario is 3 times the original length (every character escaped)
	destData = [NSMutableData dataWithLength:(sourceLength * 3)];
	destPtr  = [destData mutableBytes];
    
	while (sourceIndex < sourceLength) {
		unsigned char	ch = UTF8[sourceIndex];
		destPtr[destIndex++] = translationTable[ch];
        
		if (!translationTable[ch]) {
			//hex-encode.
			destPtr[destIndex-1] = '%';
			destPtr[destIndex++] = intToHex(ch / 0x10);
			destPtr[destIndex++] = intToHex(ch % 0x10);
		}
        
		sourceIndex++;
	}
    
	return [[NSString alloc] initWithBytes:destPtr length:destIndex encoding:NSASCIIStringEncoding];
}
 */

//stringByDecodingURLEscapes
// Remove percent escapes for all characters except for a-z, A-Z, 0-9, '_', and '-', converting to original character
// Convert '+' back to a space
/*
- (NSString *)stringByDecodingURLEscapes
{
	NSData				*UTF8Data = [self dataUsingEncoding:NSUTF8StringEncoding];
	const char			*UTF8 = [UTF8Data bytes];
	char				*destPtr;
	NSMutableData		*destData;
	unsigned	 sourceIndex = 0;
	NSUInteger			 sourceLength = [UTF8Data length];
	unsigned	 destIndex = 0;
    
	//this table translates spaces to plusses, and vice versa.
	static const char translationTable[256] = {
		0x00, 0x01, 0x02, 0x03,  0x04, 0x05, 0x06, 0x07,
		0x08, 0x09, 0x0a, 0x0b,  0x0c, 0x0d, 0x0e, 0x0f,
		0x10, 0x11, 0x12, 0x13,  0x14, 0x15, 0x16, 0x17,
		0x18, 0x19, 0x1a, 0x1b,  0x1c, 0x1d, 0x1e, 0x1f,
        '+',  '!',  '"',  '#',   '$',  '%',  '&', '\'',
        '(',  ')',  '*',  ' ',   ',',  '-',  '.',  '/',
        '0',  '1',  '2',  '3',   '4',  '5',  '6',  '7',
        '8',  '9',  ':',  ';',   '<',  '=',  '>',  '?',
        '@',  'A',  'B',  'C',   'D',  'E',  'F',  'G',
        'H',  'I',  'J',  'K',   'L',  'M',  'N',  'O',
        'P',  'Q',  'R',  'S',   'T',  'U',  'V',  'W',
        'X',  'Y',  'Z',  '[',  '\\',  ']',  '^',  '_',
        '`',  'a',  'b',  'c',   'd',  'e',  'f',  'g',
        'h',  'i',  'j',  'k',   'l',  'm',  'n',  'o',
        'p',  'q',  'r',  's',   't',  'u',  'v',  'w',
        'x',  'y',  'z',  '{',   '|',  '}',  '~', 0x7f,
		0x80, 0x81, 0x82, 0x83,  0x84, 0x85, 0x86, 0x87,
		0x88, 0x89, 0x8a, 0x8b,  0x8c, 0x8d, 0x8e, 0x8f,
		0x90, 0x91, 0x92, 0x93,  0x94, 0x95, 0x96, 0x97,
		0x98, 0x99, 0x9a, 0x9b,  0x9c, 0x9d, 0x9e, 0x9f,
		0xa0, 0xa1, 0xa2, 0xa3,  0xa4, 0xa5, 0xa6, 0xa7,
		0xa8, 0xa9, 0xaa, 0xab,  0xac, 0xad, 0xae, 0xaf,
		0xb0, 0xb1, 0xb2, 0xb3,  0xb4, 0xb5, 0xb6, 0xb7,
		0xb8, 0xb9, 0xba, 0xbb,  0xbc, 0xbd, 0xbe, 0xbf,
		0xc0, 0xc1, 0xc2, 0xc3,  0xc4, 0xc5, 0xc6, 0xc7,
		0xc8, 0xc9, 0xca, 0xcb,  0xcc, 0xcd, 0xce, 0xcf,
		0xd0, 0xd1, 0xd2, 0xd3,  0xd4, 0xd5, 0xd6, 0xd7,
		0xd8, 0xd9, 0xda, 0xdb,  0xdc, 0xdd, 0xde, 0xdf,
		0xe0, 0xe1, 0xe2, 0xe3,  0xe4, 0xe5, 0xe6, 0xe7,
		0xe8, 0xe9, 0xea, 0xeb,  0xec, 0xed, 0xee, 0xef,
		0xf0, 0xf1, 0xf2, 0xf3,  0xf4, 0xf5, 0xf6, 0xf7,
		0xf8, 0xf9, 0xfa, 0xfb,  0xfc, 0xfd, 0xfe, 0xff
	};
    
	//Best case scenario is 1/3 the original length (every character escaped); worst should be the same length
	destData = [NSMutableData dataWithLength:sourceLength];
	destPtr = [destData mutableBytes];
	
	while (sourceIndex < sourceLength) {
		unsigned char	ch = UTF8[sourceIndex++];
        
		if (ch == '%') {
			int firstHexValue = hexToInt(UTF8[sourceIndex]);
			int secondHexValue = hexToInt(UTF8[sourceIndex+1]);
			
			if ((firstHexValue != -1) && (secondHexValue != -1))
				destPtr[destIndex] = (firstHexValue  * 0x10 ) + secondHexValue;
			else
				destPtr[destIndex] = '?';
            
			sourceIndex += 2;
		} else {
			destPtr[destIndex] = translationTable[ch];
		}
        
		destIndex++;
	}
    
	return [[NSString alloc] initWithBytes:destPtr length:destIndex encoding:NSASCIIStringEncoding];
}
 */

- (NSString *)string
{
	return self;
}

#endif //ndef BSD_LICENSE_ONLY

//stringByEscapingForXMLWithEntities: and stringByUnescapingFromXMLWithEntities: were written by Peter Hosey and are explicitly released under the BSD license.
/*
 Copyright ¬© 2006 Peter Hosey
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Peter Hosey nor the names of his contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
- (NSString *)stringByEscapingForXMLWithEntities:(NSDictionary *)entities
{
	static const unichar nbsp = 0xa0;
	NSDictionary *realEntities = entities;
    
	if (!entities) {
		realEntities = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"amp",  @"&",
                        @"lt",   @"<",
                        @"gt",   @">",
                        @"quot", @"\"",
                        @"apos", @"'",
                        @"nbsp", [NSString stringWithCharacters:&nbsp length:1],
                        //Also escape whitespace. CF doesn't do this by default.
                        @"#x09", @"\t",
                        @"#x0a", @"\n",
                        @"#x0b", @"\v",
                        @"#x0c", @"\f",
                        @"#x0d", @"\r",
                        nil];
	}
    
	return (__bridge_transfer NSString *)CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault, (__bridge CFStringRef)self, (__bridge CFDictionaryRef)realEntities);
}
- (NSString *)stringByUnescapingFromXMLWithEntities:(NSDictionary *)entities
{
	return (__bridge_transfer NSString *)CFXMLCreateStringByUnescapingEntities(kCFAllocatorDefault, (__bridge CFStringRef)self, (__bridge CFDictionaryRef)entities);
}

#ifndef BSD_LICENSE_ONLY

- (NSString *)stringByEscapingForShell
{
	NSUInteger myLength = [self length];
	unichar *myBuf = malloc(sizeof(unichar) * myLength);
	if (!myBuf) return nil;
	[self getCharacters:myBuf];
	const unichar *myBufPtr = myBuf;
    
	size_t buflen = 0;
	unichar *buf = NULL;
    
	const size_t buflenIncrement = getpagesize() / sizeof(unichar);
    
	/*the boundary guard happens everywhere that i increases, and MUST happen
	 *	at the beginning of the loop.
	 *
	 *initialising buflen to 0 and buf to NULL as we have done above means that
	 *	realloc will act as malloc:
	 *	-	i is 0 at the beginning of the loop
	 *	-	so is buflen
	 *	-	and buf is NULL
	 *	-	realloc(NULL, ...) == malloc(...)
	 *
	 *oh, and 'SBEFS' stands for String By Escaping For Shell
	 *	(the name of this method).
	 */
#define SBEFS_BOUNDARY_GUARD \
do { \
if (i == buflen) { \
buf = reallocf(buf, sizeof(unichar) * (buflen += buflenIncrement)); \
if (buf == NULL) { \
DDLog(@"in stringByEscapingForShell: could not allocate %lu bytes", (unsigned long)(sizeof(unichar) * buflen)); \
free(myBuf); \
return nil; \
} \
} \
} while (0)
    
	unsigned i = 0;
	for (; myLength--; ++i) {
		SBEFS_BOUNDARY_GUARD;
        
		if (characterNature[*myBufPtr] & whitespaceNature) {
			//escape this character using a named escape
			static unichar escapeNames[] = {
				0, 0, 0, 0, 0, 0, 0,
				'a', //0x07 BEL: '\a'
				0,
				't', //0x09 HT: '\t'
				'n', //0x0a LF: '\n'
				'v', //0x0b VT: '\v'
				'f', //0x0c FF: '\f'
				'r', //0x0d CR: '\r'
				0, 0, //0x0e-0x0f
				0, 0, 0, 0,  0, 0, 0, 0, //0x10-0x17
				0, 0, 0, 0,  0, 0, 0, 0, //0x18-0x1f
				' ', //0x20 SP: '\ '
			};
			buf[i++] = '\\';
			SBEFS_BOUNDARY_GUARD;
			buf[i] = escapeNames[*myBufPtr];
		} else {
			if (characterNature[*myBufPtr] & shellUnsafeNature) {
				//escape this character
				buf[i++] = '\\';
				SBEFS_BOUNDARY_GUARD;
			}
            
			buf[i] = *myBufPtr;
		}
		++myBufPtr;
	}
    
#undef SBEFS_BOUNDARY_GUARD
    
	free(myBuf);
    
	NSString *result = [NSString stringWithCharacters:buf length:i];
	free(buf);
    
	return result;
}

- (NSString *)stringByEscapingForRegexp
{
	NSUInteger myLength = [self length];
	unichar *myBuf = malloc(sizeof(unichar) * myLength);
	if (!myBuf) return nil;
	[self getCharacters:myBuf];
	const unichar *myBufPtr = myBuf;
	
	size_t buflen = 0;
	unichar *buf = NULL;
	
	const size_t buflenIncrement = getpagesize() / sizeof(unichar);
	
	/*the boundary guard happens everywhere that i increases, and MUST happen
	 *	at the beginning of the loop.
	 *
	 *initialising buflen to 0 and buf to NULL as we have done above means that
	 *	realloc will act as malloc:
	 *	-	i is 0 at the beginning of the loop
	 *	-	so is buflen
	 *	-	and buf is NULL
	 *	-	realloc(NULL, ...) == malloc(...)
	 *
	 *oh, and 'SBEFR' stands for String By Escaping For Regexp
	 *	(the name of this method).
	 */
#define SBEFR_BOUNDARY_GUARD \
do { \
if (i == buflen) { \
buf = reallocf(buf, sizeof(unichar) * (buflen += buflenIncrement)); \
if (!buf) { \
DDLog(@"in stringByEscapingForRegexp: could not allocate %lu bytes", (unsigned long)(sizeof(unichar) * buflen)); \
free(myBuf); \
return nil; \
} \
} \
} while (0)
	
	unsigned i = 0;
	for (; myLength--; ++i) {
		SBEFR_BOUNDARY_GUARD;
		
		if (characterNature[*myBufPtr] & regexpUnsafeNature) {
			//escape this character
			buf[i++] = '\\';
			SBEFR_BOUNDARY_GUARD;
		}
		
		buf[i] = *myBufPtr;
		++myBufPtr;
	}
	
#undef SBEFR_BOUNDARY_GUARD
	
	free(myBuf);
	
	NSString *result = [NSString stringWithCharacters:buf length:i];
	free(buf);
	
	return result;
}

- (NSString *)volumePath
{
	NSString *volumePath;
	for (volumePath in [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths]) {
		if ([self hasPrefix:[volumePath stringByAppendingString:@"/"]])
			break;
	}
	if (!volumePath)
		volumePath = @"/";
	return volumePath;
}

- (unichar)lastCharacter {
	NSUInteger length = [self length];
	if (length < 1)
		return 0xffff;
	else
		return [self characterAtIndex:length - 1];
}
- (unichar)nextToLastCharacter {
	NSUInteger length = [self length];
	if (length < 2)
		return 0xffff;
	else
		return [self characterAtIndex:length - 2];
}
- (UTF32Char)lastLongCharacter {
	unichar nextToLast = [self nextToLastCharacter];
	unichar last       = [self lastCharacter];
	if (UCIsSurrogateHighCharacter(nextToLast) && UCIsSurrogateLowCharacter(last)) {
		return UCGetUnicodeScalarValueForSurrogatePair(nextToLast, last);
	} else {
		return last;
	}
}

+ (NSString *)uuid
{
	CFUUIDRef	uuid;
	NSString	*uuidStr;
	
	uuid = CFUUIDCreate(NULL);
	uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	
	return uuidStr;
}

+ (NSString *)stringWithCGFloat:(CGFloat)f maxDigits:(NSUInteger)numDigits
{
	//012345678 <-Indices.
	//42.123400 <-Assuming numDigits = 6.
	//^-----^   <-Returns this substring. (Trailing zeroes are deleted.)
	//42.000000
	//^^        <-Returns this substring (everything before the decimal point) for a whole number.
	NSString *format = numDigits ? [NSString stringWithFormat:@"%%.%luf", numDigits] : @"%f";
	NSString *str = [NSString stringWithFormat:format, (double)f];
	NSUInteger i = [str length];
	while (i-- > 0) {
		if ([str characterAtIndex:i] != '0') {
			//If we have run out of zeroes, this is a whole number. Leave off the decimal point.
			//Not incrementing i means that the decimal point will be dropped.
			if ([str characterAtIndex:i] != '.') ++i;
			break;
		}
	}
	return [str substringToIndex:i];
}

#pragma mark -

+ (NSCharacterSet *) characterSetWithLineBreakCharacters
{
	static NSCharacterSet *lineBreakCharacterSet = nil;
    
	if (!lineBreakCharacterSet) {
		static const unichar lineBreakCharacters[numberOfLineBreakCharacters] = { LINE_FEED, FORM_FEED, CARRIAGE_RETURN, NEXT_LINE, LINE_SEPARATOR, PARAGRAPH_SEPARATOR };
        
		lineBreakCharacterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:lineBreakCharacters length:numberOfLineBreakCharacters]];
	}
    
	return lineBreakCharacterSet;
}

- (NSRange) rangeOfLineBreakCharacterInRange:(NSRange)range
{
	NSRange lineBreakRange = [self rangeOfCharacterFromSet:[[self class] characterSetWithLineBreakCharacters] options:NSLiteralSearch range:range];
    
	//If we found a line-break…
	if (lineBreakRange.location != NSNotFound) {
		NSUInteger selfLength = [self length];
		//and this character is not the last in the string…
		if ((selfLength >= 2U) && (lineBreakRange.location < (selfLength - 1U))) {
			//and this character is a CR…
			if ([self characterAtIndex:lineBreakRange.location] == CARRIAGE_RETURN) {
				//and the next character is an LF…
				if ([self characterAtIndex:lineBreakRange.location + 1U] == LINE_FEED) {
					//then this is a CRLF sequence, which is a single line-break, which means we should return a two-character range.
					++lineBreakRange.length;
				}
			}
		}
	}
    
	return lineBreakRange;
}

- (NSRange) rangeOfLineBreakCharacterFromIndex:(NSUInteger)startIdx
{
	NSRange searchRange = { .location = startIdx, .length = [self length] };
    
	//Subtract the start index from our length, but don't subtract if the location is greater than the length, since that will be an exception either way.
	if (searchRange.location <= searchRange.length) {
		searchRange.length -= searchRange.location;
	}
	//Make sure we search at least one character, even if it's past the end of the string (in which case we'll raise an exception, which we want to do).
	if (searchRange.length == 0)
		searchRange.length = 1;
	//We don't need to throw the exception ourselves because rangeOfCharacterFromSet: will do that for us.
    
	return [self rangeOfLineBreakCharacterInRange:searchRange];
}

- (NSRange) rangeOfLineBreakCharacter
{
	return [self rangeOfLineBreakCharacterInRange:NSMakeRange(0U, [self length])];
}

- (NSArray *)allLinesWithSeparator:(NSObject *)separatorObj
{
	NSMutableArray *lines = [NSMutableArray array];
    
	NSUInteger selfLength = [self length];
	NSRange searchRange = { 0U, selfLength };
	NSRange lineBreakRange;
	NSRange substringRange = searchRange;
	while ((lineBreakRange = [self rangeOfLineBreakCharacterInRange:searchRange]).location != NSNotFound) {
		substringRange.length = lineBreakRange.location - searchRange.location;
        
		[lines addObject:[self substringWithRange:substringRange]];
		if (separatorObj) [lines addObject:[separatorObj copy]];
        
		searchRange.location = (lineBreakRange.location + lineBreakRange.length);
		searchRange.length = selfLength - searchRange.location;
        
		substringRange.location = searchRange.location;
	}
    
	substringRange.length = searchRange.length;
	[lines addObject:[self substringWithRange:substringRange]];
    
	return [NSArray arrayWithArray:lines];
}
- (NSArray *)allLines
{
	return [self allLinesWithSeparator:nil];
}

#endif //ndef BSD_LICENSE_ONLY

- (BOOL) isCaseInsensitivelyEqualToString:(NSString *)other {
	NSParameterAssert(other != nil);
	return [self caseInsensitiveCompare:other] == NSOrderedSame;
}

/*
 * @brief For AICompletingTextField
 */
- (NSComparisonResult)compareLength:(NSString *)aText
{
	if ([aText length] > [self length]) {
		return NSOrderedAscending;
	} else if ([aText length] == [self length]) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}

- (unsigned long long)unsignedLongLongValue
{
	return [[NSDecimalNumber decimalNumberWithString:self] unsignedLongLongValue];
}

- (NSString *)stringByAddingPercentEscapesForAllCharacters
{
	// RFC 2396:
	//       reserved    = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |	"$" | ","
	
	NSString *string = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (__bridge CFStringRef)self, 
                                                                                             NULL,
                                                                                             (CFStringRef)@";/?:@&=+$",
                                                                                             kCFStringEncodingUTF8);
    
	return string;
}

- (NSString*)removeAllSpace
{
    NSString* result = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"    " withString:@""];
    return result;
}

- (BOOL)allSpaceAllNewLine
{
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

@end
