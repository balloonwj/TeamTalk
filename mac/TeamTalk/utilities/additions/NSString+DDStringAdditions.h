//
//  NSString+DDStringAdditions.h
//  Duoduo
//
//  Created by maye on 13-10-31.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DDStringAdditions)
+ (id)randomStringOfLength:(unsigned int)inLength;

+ (id)stringWithContentsOfUTF8File:(NSString *)path;

+ (id)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (id)stringWithBytes:(const void *)inBytes length:(unsigned)inLength encoding:(NSStringEncoding)inEncoding;

+ (id)ellipsis;
- (NSString *)stringByAppendingEllipsis;

- (NSString *)stringByTranslatingByOffset:(int)offset;

- (NSString *)compactedString;

- (NSString *)stringByExpandingBundlePath;
- (NSString *)stringByCollapsingBundlePath;

//- (NSString *)stringByEncodingURLEscapes;
//- (NSString *)stringByDecodingURLEscapes;

- (NSString *)safeFilenameString;

- (NSString *)stringWithEllipsisByTruncatingToLength:(NSUInteger)length;

- (NSString *)string;

/*!
 * @brief Wraps CFXMLCreateStringByEscapingEntities() with the addition of escaping whitespace if no entities dictionary is specified. See its documentation.
 */
- (NSString *)stringByEscapingForXMLWithEntities:(NSDictionary *)entities;

/*!
 * @brief Wraps CFXMLCreateStringByUnescapingEntities(). See its documentation.
 */
- (NSString *)stringByUnescapingFromXMLWithEntities:(NSDictionary *)entities;

- (NSString *)stringByEscapingForShell;
- (NSString *)stringByEscapingForRegexp;

//- (BOOL)isURLEncoded;

- (NSString *)stringByAddingPercentEscapesForAllCharacters;

/*examples:
 *	receiver                            result
 *	========                            ======
 *	/                                   /
 *	/Users/boredzo                      /
 *	/Volumes/Repository                 /Volumes/Repository
 *	/Volumes/Repository/Downloads       /Volumes/Repository
 *and if /Volumes/Toolbox is your startup disk (as it is mine):
 *	/Volumes/Toolbox/Applications       /
 */
- (NSString *)volumePath;

- (unichar)lastCharacter;
- (unichar)nextToLastCharacter;
- (UTF32Char)lastLongCharacter;

+ (NSString *)uuid;

+ (NSString *)stringWithCGFloat:(CGFloat)f maxDigits:(NSUInteger)numDigits;

/*!
 * @brief Finds a line-breaking character within a substring of a string.
 *
 * A line-breaking character is any of LF (U+000A), FF (U+000C), CR (U+000D),
 * NEXT LINE (U+0085), LINE SEPARATOR (U+2028), or PARAGRAPH SEPARATOR (U+2029).
 *
 * @par
 * If this method detects a CRLF sequence, it will turn the range covering both characters. For all other line breaks, the range it returns has length 1.
 *
 * @param range The range (within the receiver) where you want to look for a line-break character.
 * @throws NSRangeException Some part of \a range lies outside the receiver's bounds.
 * @result The range of the line break, or { NSNotFound, 0 } if no line-breaking character is present within the substring.
 */
- (NSRange) rangeOfLineBreakCharacterInRange:(NSRange)range;
/*!
 * @brief Finds a line-breaking character in the latter portion of a string.
 *
 * A line-breaking character is any of LF (U+000A), FF (U+000C), CR (U+000D),
 * NEXT LINE (U+0085), LINE SEPARATOR (U+2028), or PARAGRAPH SEPARATOR (U+2029).
 *
 * @par
 * If this method detects a CRLF sequence, it will turn the range covering both characters. For all other line breaks, the range it returns has length 1.
 *
 * @par
 * This method will look for the character within the range { startIdx, length - startIdx }.
 *
 * @param startIdx The index (within the receiver) from which you want to start looking for a line-break character.
 * @throws NSRangeException \a startIdx lies outside the receiver's bounds.
 * @result The range of the line break, or { NSNotFound, 0 } if no line-breaking character is present within the substring.
 */
- (NSRange) rangeOfLineBreakCharacterFromIndex:(NSUInteger)startIdx;
/*!
 * @brief Finds a line-breaking character within a string.
 *
 * A line-breaking character is any of LF (U+000A), FF (U+000C), CR (U+000D),
 * NEXT LINE (U+0085), LINE SEPARATOR (U+2028), or PARAGRAPH SEPARATOR (U+2029).
 *
 * @par
 * If this method detects a CRLF sequence, it will turn the range covering both characters. For all other line breaks, the range it returns has length 1.
 *
 * @result The range of the line break, or { NSNotFound, 0 } if no line-breaking character is present within the string.
 */
- (NSRange) rangeOfLineBreakCharacter;

//If you provide a separator object, it will be recorded in the array whenever a newline is encountered.
//Newline is any of CR, LF, CRLF, LINE SEPARATOR, or PARAGRAPH SEPARATOR.
//If you do not provide a separator object (pass nil or use the other method), separators are not recorded; you get only the lines, with nothing between them.
- (NSArray *)allLinesWithSeparator:(NSObject *)separatorObj;
- (NSArray *)allLines;

- (BOOL) isCaseInsensitivelyEqualToString:(NSString *)other;

- (NSComparisonResult)compareLength:(NSString *)aString;

- (unsigned long long)unsignedLongLongValue;

/**
 *  去除所有空格
 *
 *  @return 没有空格的字符串
 */
- (NSString*)removeAllSpace;

- (BOOL)allSpaceAllNewLine;
@end
