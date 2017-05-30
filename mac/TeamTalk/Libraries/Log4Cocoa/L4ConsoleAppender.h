// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"

/**
 * An implementation of L4Appender that writes messages to the console; either stdout or stderr.
 */
@interface L4ConsoleAppender : L4WriterAppender

/**
 * Creates and returns an L4ConsoleAppender on stdout with the given L4Layout.
 * @param aLayout the layout to use for the created appender.
 * @return the new appender.
 */
+ (L4ConsoleAppender *) standardOutWithLayout:(L4Layout *) aLayout;

/**
 * Creates and returns an L4ConsoleAppender on stderr with the given L4Layout.
 * @param aLayout the layout to use for the created appender.
 * @return the new appender.
 */
+ (L4ConsoleAppender *) standardErrWithLayout:(L4Layout *) aLayout;

/**
 * default init method.  Returned instance isn't connected to anything.
 * @return the new instance.
 */
- (id) init;

/**
 * Creates and returns a new console appender.
 * @param standardOut YES to use stdout; otherwise stderr is used.
 * @param aLayout the layout to use.
 * @return the new instance.
 */
- (id) initTarget:(BOOL) standardOut withLayout:(L4Layout *) aLayout;


/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>LogToStandardOut:</c> specifies if this appender should append to stdout or stderr.  If the value is true, then
 *        stdout will be used.  Otherwise stderr will be used.
 * If the values are being set in a file, this is how they could look:
 *    <code>log4cocoa.appender.A2.LogToStandardOut=false</code>
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *) initProperties;

/**
 * Accesor for isStandardOut attribute.
 * @return YES if this appender is for stdout; NO if it is for stderr.
 */
- (BOOL) isStandardOut;

@end
