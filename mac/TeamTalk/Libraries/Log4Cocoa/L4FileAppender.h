/**
 * This appender appends logging messages to a file whose path you specify.  This class is a subclass of L4WriterAppender.
 * The L4FileAppender does not support buffering configuration.  Any methods or arguments that refer to buffering are ignored.
 * For copyright & license, see LICENSE.
 */

#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"

@interface L4FileAppender : L4WriterAppender

/**
 * Tracks if we should append or over-right.
 */

@property (nonatomic, readonly) BOOL append;

/**
 * The path to the file to which log output should be written.
 */
@property (nonatomic, readonly) NSString * fileName;

/**
 * A basic initializer.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with layout and file name set to nil,
 * append is NO, bufferIO is NO, bufferSize is 0
 */
- (id)init;

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>File:</c> the full path of the file to use.
 * - <c>Append:</c> weather to append to the file, or create a new one.  Expected values are [true|false].
 * If the values are being set in a file, this is how they could look:
 *    <code>log4cocoa.appender.A2.File=/tmp/mylogfile.txt
 *    log4cocoa.appender.A2.Append=false</code>
 * @param initProperties the proterties to use.
 */
- (id)initWithProperties:(L4Properties *)initProperties;

/**
 * Initializes an L4FileAppender instance with the specified layout and file path name.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout and file name,
 * append is NO, bufferIO is NO, bufferSize is 0
 * @param aLayout The layout that this appender should use
 * @param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
 * @throws
 * @return An initialized L4FileAppender object
 */
- (id)initWithLayout:(L4Layout *)aLayout fileName:(NSString *)aName;

/**
 * Initializes an L4FileAppender instance with the specified layout, file path name, and append option.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout, file name, and append
 * option, bufferIO is NO, bufferSize is 0
 * @param aLayout The layout that this appender should use
 * @param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
 * @param flag YES = log output should be appended to the file.  NO = the file's previous contents should be overwritten
 * @throws
 * @return An initialized L4FileAppender object
 */
- (id)initWithLayout:(L4Layout *)aLayout fileName:(NSString *)aName append:(BOOL)flag;

@end

/**
 * These methods are "protected" methods and should not be called except by subclasses.
 */
@interface L4FileAppender (ProtectedMethods)

/**
 * This method closes and releases the underlying file handle.
 */
- (void)closeFile;

/**
 * This method is called to insure the file is set up to write to.
 */
- (void)setupFile;


@end
// For copyright & license, see LICENSE.
