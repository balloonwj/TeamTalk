#import <Foundation/Foundation.h>
#import "L4Layout.h"

/**
 *Defines the default conversion pattern for <code>L4PatternLayout</code> objects created with the <code>init</code> method
 */
extern NSString* const L4PatternLayoutDefaultConversionPattern;

/**
 * Defines the name for invalid format specifier exceptions
 */
extern NSString* const L4InvalidSpecifierException;

/**
 *Defines the name for the no conversion pattern exception
 * This exception is thrown if you try to use an L4PatternLayout before setting its conversion pattern
 */
extern NSString* const L4NoConversionPatternException;

/**
 * Defines the name for the invalid brace clause exception
 * Some of the format specifiers can be followed by content surrounded by braces ({}).  When this brace clause is invalid for 
 * any reason, the L4InvalidBraceClauseException is thrown
 */
extern NSString* const L4InvalidBraceClauseException;

/**
 * An NSCharacterSet that contains the default format specifier characters
 */
#define L4PatternLayoutDefaultSpecifiers    [NSCharacterSet characterSetWithCharactersInString:@"CdFlLmMnprt%"]

/**
 * An NSCharacterSet that contains the subset of characters from L4PatternLayoutDefaultSpecifiers that can have a brace clause 
 * after the character
 */
#define L4PatternLayoutTrailingBracesSpecifiers    [NSCharacterSet characterSetWithCharactersInString:@"Cd"]

@class L4LogEvent;
@class L4PatternParser;

/**
 * A layout that uses a conversion pattern to format logging messages
 * 
 * A flexible layout configurable with pattern string.
 * The goal of this class is to <code>format</code> a <code>LoggingEvent</code> and return the results as a String. The results
 * depend on the <em>conversion pattern</em>.
 * 
 * The conversion pattern is closely related to the conversion pattern of the printf function in C. A conversion pattern is
 * composed of literal text and format control expressions called <em>format specifiers</em>.
 * <i>You are free to insert any literal text within the conversion pattern.</i>
 * 
 * Each conversion specifier starts with a percent sign (%) and is followed by optional <em>format modifiers</em> and a <em>specifier
 * character</em>. The specifier character specifies the type of data, e.g. priority, date. The format modifiers control such things
 * as field width, padding, left and right justification. The following is a simple example.
 * 
 * Let the conversion pattern be <b>"%-5p :%m%n"</b> and assume that the Log4Cocoa environment was set to use an L4PatternLayout. Then the
 * statements
 * <pre>
 * log4Debug("Message 1");
 * log4Warn("Message 2");
 * </pre>
 * would yield the output
 * <pre>
 * DEBUG :Message 1
 * WARN  :Message 2
 * </pre>
 * 
 * Note that there is no explicit separator between text and conversion specifiers. The pattern parser knows when it has reached
 * the end of a conversion specifier when it reads a specifier character. In the example, above the conversion specifier
 * <b>%-5p</b> means the priority of the logging event should be left justified to a width of five characters.
 * 
 * The recognized conversion characters are:

 * <table border="1" CELLPADDING="8">
 * <tr>
 * <th>Conversion Character</th>
 * <th>Effect</th>
 * </tr>
 * <tr>
 * <td align=center><b>C</b></td>
 * <td>Used to output the fully qualified class name of the logger issuing the logging request. This conversion specifier
 * can be optionally followed by <em>precision specifier</em>, thatis a decimal constant in braces.
 * 
 * If a precision specifier is given, then only the corresponding number of right most components of the logger name will be
 * printed. By default the logger name is output in fully qualified form.
 * 
 * For example, for the class name "NSObject.MyClass.SubClass.SomeClass", the pattern <b>%C{1}</b> will output "SomeClass".
 * </td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>d</b></td>
 * 
 * <td>Used to output the date of the logging event. The date conversion specifier may be followed by a <em>date format specifier</em>
 * enclosed between braces. For example, <b>%d{%H:%M:%S}</b>.  If no date format specifier is given, then  an international format of 
 * "%Y-%m-%d %H:%M:%S %z" is used.
 * 
 * The date format specifier admits the same syntax as the calendar format string in <CODE>NSCalendarDate</CODE>'s 
 * descriptionWithCalendarFormat:method.
 * </td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>F</b></td>
 * <td>Used to output the file name where the logging request was issued.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>l</b></td>
 * <td>Used to output location information of the caller which generated the logging event.
 * 
 * The location information consists of the fully qualified name of the calling logger, the method the log request originated in, 
 * followed by the log request's source file name and line number between parentheses.
 * </td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>L</b></td>
 * <td>Used to output the line number from where the logging request was issued.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>m</b></td>
 * <td>Used to output the application supplied message associated with the logging event.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>M</b></td>
 * <td>Used to output the method name where the logging request was issued.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>n</b></td>
 * <td>Outputs the line separator character, <code>\\n</code>.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>p</b></td>
 * <td>Used to output the priority (level) of the logging event.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>r</b></td>
 * <td>Used to output the number of milliseconds elapsed since the start of the application until the creation of the logging event.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>t</b></td>
 * <td>Used to output the name of the thread where the logging event occured.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center><b>%</b></td>
 * <td>The sequence %% outputs a single percent sign.
 * </td>
 * </tr>
 * 
 * </table>
 * 
 * By default the relevant information is output as is. However, with the aid of format modifiers it is possible to change the
 * minimum field width, the maximum field width and justification.
 * 
 * The optional format modifier is placed between the percent sign and the conversion character.
 * 
 * The first optional format modifier is the <em>left justification flag</em> which is just the minus (-) character. Then comes the
 * optional <em>minimum field width</em> modifier. This is a decimal constant that represents the minimum number of characters to
 * output. If the data item requires fewer characters, it is padded on either the left or the right until the minimum width is
 * reached. The default is to pad on the left (right justify) but you can specify right padding with the left justification flag. The
 * padding character is space. If the data item is larger than the minimum field width, the field is expanded to accommodate the
 * data. The value is never truncated.
 * 
 * This behavior can be changed using the <em>maximum field width</em> modifier which is designated by a period followed by a
 * decimal constant. If the data item is longer than the maximum field, then the extra characters are removed from the
 * <em>beginning</em> of the data item and not from the end. For example, it the maximum field width is eight and the data item is
 * ten characters long, then the first two characters of the data item are dropped. This behavior deviates from the printf function in C
 * where truncation is done from the end.
 * 
 * Below are various format modifier examples for the category conversion specifier.
 * 
 * <TABLE BORDER=1 CELLPADDING=8>
 * <tr>
 * <th>Format modifier</th>
 * <th>left justify</th>
 * <th>minimum width</th>
 * <th>maximum width</th>
 * <th>comment</th>
 * </tr>
 * 
 * <tr>
 * <td align=center>%20C</td>
 * <td align=center>false</td>
 * <td align=center>20</td>
 * <td align=center>none</td>
 * <td>Left pad with spaces if the logger name is less than 20 characters long.</td>
 * </tr>
 * 
 * <tr> 
 * <td align=center>%-20C</td> 
 * <td align=center>true</td> 
 * <td align=center>20</td> 
 * <td align=center>none</td> 
 * <td>Right pad with spaces if the logger name is less than 20 characters long.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center>%.30C</td>
 * <td align=center>NA</td>
 * <td align=center>none</td>
 * <td align=center>30</td>
 * <td>Truncate from the beginning if the logger name is longer than 30 characters.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center>%20.30C</td>
 * <td align=center>false</td>
 * <td align=center>20</td>
 * <td align=center>30</td>
 * <td>Left pad with spaces if the logger name is shorter than 20 characters. However, if logger name is longer than 30 characters,
 * then truncate from the beginning.</td>
 * </tr>
 * 
 * <tr>
 * <td align=center>%-20.30C</td>
 * <td align=center>true</td>
 * <td align=center>20</td>
 * <td align=center>30</td>
 * <td>Right pad with spaces if the logger name is shorter than 20 characters. However, if logger name is longer than 30 characters,
 * then truncate from the beginning.</td>
 * </tr>
 * </table>
 * 
 */

@protocol L4PatternLayoutConverterDelegate;
@protocol L4PatternLayoutParserDelegate;

@interface L4PatternLayout :L4Layout

/**
 * Layout conversion pattern
 */
@property (copy) NSString * conversionPattern;

/**
 * When the pattern layout formats logging messages, it first takes the conversion 
 * pattern and parses it into token strings.  Then, it takes each token string and 
 * converts it into the corresponding part of the final formatted message.  
 * You can provide a converter delegate to override or extend how a pattern layout
 * converts its token strings.  By default, the pattern layout does nothing to 
 * literal string tokens and converts format specifiers as explained in the description of this class.
 * The converter delegate must respond to the convertTokenString:withLoggingEvent:intoString:method.
 */
@property (strong) id <L4PatternLayoutConverterDelegate> converterDelegate;

/**
 * When the pattern layout formats logging messages, it first takes the conversion pattern and parses it into token strings.
 * You can provide a parser delegate to override how a pattern layout parses the conversion pattern into token strings.  By
 * default, the pattern layout divides the conversion pattern into a series of literal strings and format specifiers.
 * The parser delegate must respond to the parseConversionPattern:intoArray:method.
 */
@property (strong) id <L4PatternLayoutParserDelegate> parserDelegate;

/**
 * Initializes an L4PatternLayout with the default conversion pattern, %m%n
 * Calls initWthConversionPattern:with the string defined by <code>L4PatternLayoutDefaultConversionPattern</code>
 * @return A newly initialized L4PatternLayout object
 */
- (id)init;

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>ConversionPattern:</c> the conversion pattern to use in this instance.
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Initializes an L4PatternLayout with a custom conversion pattern.
 * @param aConversionPattern The custom conversion pattern.
 * @return A newly initialized L4PatternLayout object.
 */
- (id)initWithConversionPattern:(NSString*)aConversionPattern;

/**
 * Uses this class's conversion pattern to format logging messages
 * @param event A logging event that contains information that the layout needs to format the logging message.
 * @throw L4InvalidSpecifierException if the pattern layout's conversion pattern contains an invalid conversion specifier.
 * @throw L4NoConversionPatternException if the pattern layout's conversion pattern is nil.  This should only happen if you
 *        have code like the following:<code>[patternLayout setConversionPattern:nil];</code>
 * @throw L4InvalidBraceClauseException when a conversion specifier's brace clause is invalid for any reason. 
 * @return    A formatted logging message that adheres to the L4PatternLayout's conversion pattern.
*/
- (NSString *)format:(L4LogEvent *)event;

@end

/*
 * This is here for testing purposes.  Otherwise, the conversion pattern does not get parsed until a log event happens.
 */
@interface L4PatternLayout (TestMethods)

- (NSArray *)tokenArray;

@end

/**
 * Declares methods that an L4PatternLayout's converter delegate must implement.
 */
@protocol L4PatternLayoutConverterDelegate <NSObject>

/**
 * Allows an object to override or extend how an L4PatternLayout converts its token strings into pieces of the final formatted.
 * logging message.
 * @param token The token string to convert
 * @param logEvent An L4LoggingEvent that contains information about the current logging request
 * @param convertedString A reference to an NSString that will contain the result of the token string's conversion upon exiting the method
 * @return Return YES to indicate that you have converted the token string.  Return NO to let the pattern layout's default behavior attempt to convert it.
 */
- (BOOL)convertTokenString:(NSString*)token withLoggingEvent:(L4LogEvent*)logEvent intoString:(NSString**)convertedString;

@end

/**
 * Declares methods that an L4PatternLayout's parser delegate must implement.
 */
@protocol L4PatternLayoutParserDelegate  <NSObject>

/**
 * Allows an object to override how an L4PatternLayout parses its conversion pattern into a series of token strings.
 * @param cp The conversion pattern to be parsed
 * @param tokenStringArray A mutable array to hold the parsed tokens
 */
- (void)parseConversionPattern:(NSString*)cp intoArray:(NSMutableArray* __autoreleasing *)tokenStringArray;

@end

// For copyright & license, see LICENSE.
