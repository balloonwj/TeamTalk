/**
 * For copyright & license, see LICENSE.
 */

#import <math.h>
#import "L4PatternLayout.h"
#import "L4Layout.h"
#import "L4LogEvent.h"
#import "L4Properties.h"
#import "L4LogLog.h"
#import "L4Level.h"
#import "L4Logger.h"

NSString* const L4PatternLayoutDefaultConversionPattern    = @"%m%n";
NSString* const L4InvalidSpecifierException = @"L4InvalidSpecifierException";
NSString* const L4NoConversionPatternException = @"L4NoConversionPatternException";
NSString* const L4InvalidBraceClauseException = @"L4InvalidBraceClauseException";

@implementation L4PatternLayout {
    NSMutableArray *_tokenArray;
}

- (id)init
{
    return [self initWithConversionPattern:L4PatternLayoutDefaultConversionPattern];
}

- (id) initWithProperties:(L4Properties *) initProperties
{
    self = [super initWithProperties:initProperties];

    if (self) {
        // Support for layout.ConversionPattern in properties configuration file
        NSString *buf = [initProperties stringForKey:@"ConversionPattern"];
        if (!buf) {
            [L4LogLog warn:@"ConversionPattern not specified in properties, will use default."];
            buf = L4PatternLayoutDefaultConversionPattern;
        }
        [self setConversionPattern:buf];
        _tokenArray = [[NSMutableArray alloc] initWithCapacity:3];
    }

    return self;
}

- (id)initWithConversionPattern:(NSString*)aConversionPattern
{
    L4Properties *properties = [L4Properties properties];
    [properties setString:aConversionPattern forKey:@"ConversionPattern"];
    return [self initWithProperties:properties];
}

- (NSString *)format:(L4LogEvent *)event
{
    BOOL            handled = NO;
    NSMutableString *formattedString = nil;
    int             index = -1;
    NSString        *convertedString = nil;

    @synchronized(self) {

        // check the conversion pattern to make sure it has been set, if not, throw an L4NoConversionPatternException
        if ([self conversionPattern] == nil) {
            [NSException raise:L4NoConversionPatternException
                        format:@"L4PatternLayout's conversion pattern is nil and must be set first using either initWithConversionPattern: or setConversionPattern:"];
        }

        formattedString = [NSMutableString stringWithCapacity:10];

        // let delegate handle it first
        if ([_parserDelegate respondsToSelector:@selector(parseConversionPattern:intoArray:)]) {
            if (_tokenArray.count <= 0) {
                NSMutableArray *newTokenArray;
                [_parserDelegate parseConversionPattern:_conversionPattern intoArray:&newTokenArray];
                _tokenArray = newTokenArray;
            }

            for (index = 0; index < _tokenArray.count; index++) {
                // reset converted string state to make sure we don't use an old value
                convertedString = [NSString string];

                // let delegate handle it first
                if ([_converterDelegate respondsToSelector:@selector(convertTokenString:withLoggingEvent:intoString:)]) {
                    handled = [_converterDelegate convertTokenString:_tokenArray[index]
                                                    withLoggingEvent:event
                                                          intoString:&convertedString];
                    if (!handled) {
                        [self convertTokenString:_tokenArray[index]
                                withLoggingEvent:event
                                      intoString:&convertedString];
                    }
                } else {
                    [self convertTokenString:_tokenArray[index]
                            withLoggingEvent:event
                                  intoString:&convertedString];
                }

                // only append string if it isn't nil
                if (convertedString != nil) {
                    [formattedString appendString:convertedString];
                }
            }
        } else {
            if (_tokenArray.count <= 0) {
                NSMutableArray *newTokenArray;
                [_parserDelegate parseConversionPattern:_conversionPattern intoArray:&newTokenArray];
                _tokenArray = newTokenArray;
            }

            for (index = 0; index < _tokenArray.count; index++) {
                // reset converted string state to make sure we don't use an old value
                convertedString = nil;

                // let delegate handle it first
                if ([_converterDelegate respondsToSelector:@selector(convertTokenString:withLoggingEvent:intoString:)]) {
                    handled = [_converterDelegate convertTokenString:_tokenArray[index]
                                                    withLoggingEvent:event
                                                          intoString:&convertedString];
                    if (!handled) {
                        [self convertTokenString:_tokenArray[index]
                                withLoggingEvent:event
                                      intoString:&convertedString];
                    }
                } else {
                    [self convertTokenString:_tokenArray[index]
                            withLoggingEvent:event
                                  intoString:&convertedString];
                }

                // only append string if it isn't nil
                if (convertedString != nil) {
                    [formattedString appendString:convertedString];
                }
            }
        }
    }
    return formattedString;
}

- (void)parseConversionPattern:(NSString*)cp intoArray:(NSMutableArray* __autoreleasing *)tokenStringArray
{
    NSScanner*                scanner = nil;
    NSCharacterSet*            percentCharacterSet = nil;
    NSMutableCharacterSet*    specifiersAndSpaceCharacterSet = nil;
    NSMutableDictionary*    locale = nil;
    NSMutableString*        token = nil, *tempString = nil;

    percentCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"%"];

    specifiersAndSpaceCharacterSet = (NSMutableCharacterSet*)[NSCharacterSet characterSetWithCharactersInString:@" "];
    [specifiersAndSpaceCharacterSet formUnionWithCharacterSet:L4PatternLayoutDefaultSpecifiers];

    // Get a copy of the user's default locale settings and set the NSDecimalSeparator key of the locale dictionary to
    // the string ".".  This way we can make sure that minimum and maximum length specifiers are scanned correctly by
    // the scanner.
    locale = [NSMutableDictionary
              dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    locale[NSLocaleDecimalSeparator] = @".";

    scanner = [NSScanner scannerWithString:cp];
    [scanner setLocale:locale];

    // don't skip any characters when parsing the string
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];

    while (![scanner isAtEnd]) {
        token = [NSMutableString stringWithCapacity:10];
        tempString = [NSMutableString stringWithCapacity:10];

        // scan until % is found or end of string is reached
        [scanner scanUpToCharactersFromSet:percentCharacterSet intoString:&token];

        // if end of string reached
        if ([scanner isAtEnd]) {
            // do nothing, this will force the execution to the end of the while loop where the token string is added to
            // the token string array
        } else if ([percentCharacterSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]]) {
            // if characters were scanned
            if ([token length] > 0) {
                // it should be a literal string and we are done for this iteration of the while loop
            } else {
                [token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
                [scanner setScanLocation:([scanner scanLocation] + 1)];
                [scanner scanUpToCharactersFromSet:specifiersAndSpaceCharacterSet intoString:&tempString];

                if ([scanner isAtEnd]) {
                    [NSException raise:L4InvalidSpecifierException
                                format:@"Expected a valid specifier character at position %d in the string '%@'",
                     [scanner scanLocation], [scanner string]];
                } else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)' ') {
                    [NSException raise:L4InvalidSpecifierException
                                format:@"Expected a valid specifier character at position %d in the string '%@'",
                     [scanner scanLocation], [scanner string]];
                } else {
                    [token appendString:tempString];
                    [token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
                    [scanner setScanLocation:([scanner scanLocation] + 1)];

                    if ([L4PatternLayoutTrailingBracesSpecifiers
                         characterIsMember:[[scanner string] characterAtIndex:([scanner scanLocation] - 1)]]) {
                        if ([scanner isAtEnd]) {
                            // do nothing, this will force the execution to the end of the while loop where the token
                            // string is added to the token string array
                        } else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)'{') {
                            [scanner scanUpToString:@"}" intoString:&tempString];

                            if ([scanner isAtEnd]) {
                                [NSException raise:L4InvalidBraceClauseException
                                            format:@"Expected a closing brace '}' character at position %d in the string '%@'",
                                 [scanner scanLocation], [scanner string]];
                            } else if ([[scanner string] characterAtIndex:[scanner scanLocation]] == (unichar)'}') {
                                [token appendString:tempString];
                                [token appendFormat:@"%C", [[scanner string] characterAtIndex:[scanner scanLocation]]];
                                [scanner setScanLocation:([scanner scanLocation] + 1)];
                            }
                        }
                    } // if specifier character can be followed by brace clause
                } // else
            } // else
        } // else if %  found

        // add final token string to the token string array
        [*tokenStringArray addObject:token];
    } // while

    // return YES;
}

- (BOOL)convertTokenString:(NSString*)token
          withLoggingEvent:(L4LogEvent*)logEvent
                intoString:(NSString**)convertedString
{

    if (token.length > 0 && [token characterAtIndex:0] != (unichar)'%') {
        *convertedString = [NSString stringWithString:token];
        return YES;
    }
    NSMutableString *finalResultString = [NSMutableString stringWithCapacity:10];

    NSCharacterSet *percentCharSet = [NSCharacterSet characterSetWithCharactersInString:@"%"];
    NSCharacterSet *specifiersCharSet = L4PatternLayoutDefaultSpecifiers;

    NSScanner *scanner = [NSScanner scannerWithString:token];

    // don't skip any characters
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@""];

    while (![scanner isAtEnd]) {
        NSString *tempString = @"";

        // reset parser state variables
        NSUInteger charsToSkip = 0;
        NSInteger minLength = 0;
        NSInteger maxLength = 0;
        BOOL leftJustify = NO;

        // check for specifier escape sequence (a percent (%))
        //DDLog(@"Checking for a percent at index %d", [scanner scanLocation]);
        if ([percentCharSet characterIsMember:[scanner.string characterAtIndex:scanner.scanLocation]]) {
            // found a percent sign
            charsToSkip++;

            // we will read the specifier justification and length as a string, so update scan location first
            [scanner setScanLocation:([scanner scanLocation] + charsToSkip)];
            charsToSkip = 0;

            NSString *fieldLength;
            if ([scanner scanUpToCharactersFromSet:specifiersCharSet intoString:&fieldLength]) {
                NSArray *fieldLengthArray = [fieldLength componentsSeparatedByString:@"."];

                // check for left justification character (-)
                leftJustify = [fieldLengthArray[0] rangeOfString:@"-"].location != NSNotFound;

                // check for minimum field width
                minLength = abs([fieldLengthArray[0] intValue]);

                if (fieldLengthArray.count > 1) {
                    maxLength = abs([fieldLengthArray[(fieldLengthArray.count - 1)] intValue]);
                }
            }

            // get the specifier character, if we are at the end of the string but haven't read a specifier
            // character yet, throw an L4InvalidSpecifierException
            //DDLog(@"Checking for the specifier character at index %d", ([scanner scanLocation] + charsToSkip));
            if ([scanner isAtEnd]) {
                [NSException raise:L4InvalidSpecifierException
                            format:@"Expected a valid specifier character at position %d in the string '%@'", scanner.scanLocation, scanner.string];
            }
            unichar specifierChar = [scanner.string characterAtIndex:(scanner.scanLocation + charsToSkip)];

            if ([specifiersCharSet characterIsMember:specifierChar]) {
                switch (specifierChar) {
                    case 'C':
                    {
                        // skip the 'C'
                        charsToSkip++;

                        tempString = logEvent.logger.name;

                        //DDLog(@"Checking for { after a C at index %d", ([scanner scanLocation] + charsToSkip));

                        // if skipping number of characters equal to value of charsToSkip doesn't put us at the end
                        // of the string and the next character (if we skipped charsToSkip characters) would be {
                        if ((scanner.scanLocation + charsToSkip) < scanner.string.length
                            && [scanner.string characterAtIndex:(scanner.scanLocation + charsToSkip)] == (unichar)'{') {
                            // there's an {, skip it and read the integer that follows
                            charsToSkip++;

                            // update the scanner's scan location because the following scan operation will advance
                            // the scan location, also reset the charsToSkip
                            scanner.scanLocation += charsToSkip;
                            charsToSkip = 0;

                            NSString *componentLengthString;
                            if ([scanner scanUpToString:@"}" intoString:&componentLengthString]) {
                                NSInteger componentLength = componentLengthString.integerValue;

                                if (componentLength > 0) {
                                    NSRange componentRange = NSMakeRange([tempString componentsSeparatedByString:@"."].count - componentLength,
                                                                         componentLength);
                                    tempString = [[[tempString componentsSeparatedByString:@"."]
                                                   subarrayWithRange:componentRange]
                                                  componentsJoinedByString:@"."];
                                } else {
                                    [NSException raise:L4InvalidBraceClauseException
                                                format:@"Expected a nonzero positive integer at position %d in conversion specifier %@.",
                                     scanner.scanLocation - componentLengthString.length, scanner.string];
                                }

                                // skip closing }
                                charsToSkip++;
                            }
                        }
                    }
                        break;

                    case 'd':
                    {
                        // skip the 'd'
                        charsToSkip++;

                        // if skipping number of characters equal to value of charsToSkip doesn't put us at the end
                        // of the string and the next character (if we skipped charsToSkip characters) would be {
                        if ((scanner.scanLocation + charsToSkip) < scanner.string.length
                            && [scanner.string characterAtIndex:(scanner.scanLocation + charsToSkip)] == (unichar)'{') {
                            // there's an {, skip it and read the string that follows
                            charsToSkip++;

                            // update the scanner's scan location because the following scan operation will advance
                            // the scan location, also reset the charsToSkip
                            scanner.scanLocation += charsToSkip;
                            charsToSkip = 0;

                            // if there's anything between the braces, get string description of the logging event's
                            // timestamp with the format we just found
                            NSString *dateFormat;
                            if ([scanner scanUpToString:@"}" intoString:&dateFormat]) {
                                // Format Date
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                dateFormatter.dateFormat = dateFormat;
                                tempString = [dateFormatter stringFromDate:logEvent.timestamp];

                                // skip closing brace
                                charsToSkip++;
                            }
                        } else {
                            tempString = logEvent.timestamp.description;
                        }
                    }
                        break;

                    case 'F':
                        // skip the 'F'
                        charsToSkip++;
                        tempString = logEvent.fileName;
                        break;

                    case 'l':
                        // skip the 'l'
                        charsToSkip++;
                        tempString = [NSString stringWithFormat:@"%@'s %@ (%@:%@)",
                                      logEvent.logger.name, logEvent.methodName, logEvent.fileName, logEvent.lineNumber];
                        break;

                    case 'L':
                        // skip the 'L'
                        charsToSkip++;
                        tempString = [NSString stringWithFormat:@"%@", logEvent.lineNumber];
                        break;

                    case 'm':
                        // skip the 'm'
                        charsToSkip++;
                        tempString = logEvent.renderedMessage ?: @"No message!";
                        break;

                    case 'M':
                        // skip the 'M'
                        charsToSkip++;
                        tempString = logEvent.methodName;
                        break;

                    case 'n':
                        // skip the 'n'
                        charsToSkip++;
                        tempString = @"\n";
                        break;

                    case 'p':
                        // skip the 'p'
                        charsToSkip++;
                        tempString = logEvent.level.description;
                        break;

                    case 'r':
                        // skip the 'r'
                        charsToSkip++;
                        tempString = [NSString stringWithFormat:@"%ld", logEvent.millisSinceStart];
                        break;

                    case 't':
                        // skip the 't'
                        charsToSkip++;
                        tempString = [NSThread currentThread].name ?: [NSString stringWithFormat:@"%p", [NSThread currentThread]];
                        break;

                    case '%':
                        // skip the '%'
                        charsToSkip++;
                        tempString = @"%";
                        break;
                }

                if (minLength > 0 && tempString.length < minLength) {
                    tempString = [NSString stringWithFormat:leftJustify ? @"%*s" : @"%-*s", minLength, tempString.UTF8String];
                }

                if (maxLength > 0 && tempString.length > maxLength) {
                    tempString = [tempString substringToIndex:maxLength];
                }

                [finalResultString appendString:tempString];
            }

            scanner.scanLocation += charsToSkip;
            continue;
        }

        if ([scanner scanUpToCharactersFromSet:percentCharSet intoString:&tempString]) {
            [finalResultString appendString:tempString];
        } else {
            [NSException raise:L4InvalidSpecifierException
                        format:@"Expected a valid specifier character at position %d in the string '%@'",
             [scanner scanLocation], [scanner string]];
        }
    }
    
    *convertedString = (NSString*) finalResultString;
    
    return YES;
}

/*
 * This is here for testing purposes.  Otherwise, the conversion pattern does not get parsed until a log event happens.
 */
- (NSArray *)tokenArray
{
    NSMutableArray *newTokenArray;
    [self parseConversionPattern:_conversionPattern intoArray:&newTokenArray];
    return newTokenArray;
}

@end
