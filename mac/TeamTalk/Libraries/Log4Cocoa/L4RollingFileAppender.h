#import <Foundation/Foundation.h>
#import "L4FileAppender.h"

@class L4Layout;
@class L4LogEvent;

/**
 * The default maximum file size, which is 10MB.
*/
extern const unsigned long long kL4RollingFileAppenderDefaultMaxFileSize;

/**
 * This class allows you to automatically create up to a number of backup log files when the log file reaches a 
 * specified size.  This class is a subclass of L4FileAppender.
 */
@interface L4RollingFileAppender : L4FileAppender

/**
 * The maxBackupIndex determines how many backup files are kept before the oldest is erased. This method takes a
 * positive integer value. If set to zero, then there will be no backup files and the log file will be truncated when it
 * reaches maxFileSize.
 */
@property NSUInteger maxBackupIndex;

/** 
 * Returns the maximum file size allowed for log files.  If the file grows larger than this, it will be backed up and
 * any additional logging statements will be written to a new file.
 * By default, this is 10MB.
 */
@property NSUInteger maxFileSize;

/**
 * This method initializes a new instance of the L4RollingFileAppender class.
 * This method calls <code>initWithLayout:fileName:append:</code>, with the default values:nil, nil, and YES 
 * respectively.
 * return An initialized instance of this class
 */
- (id) init;

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>MaximumFileSize:</c> the maxamum size of the log file in bytes, before beginning a new one.  A suffix of MB and 
 *    KB can be used to specify mega and kilo bytes.
 * - <c>MaxBackupIndex:</c> specifies how many log files to keep.
 * If the values are being set in a file, this is how they could look:
 *    <code>log4cocoa.appender.A2.MaximumFileSize=10MB
 *    log4cocoa.appender.A2.MaxBackupIndex=3</code>
 * This specifies that three files should be maintained, in adition to the one currently being logged to, and that the
 * file should be rolled at 10 MB in size.
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *) initProperties;

/**
 * This method initialized a new instance of this class with the specified layout and file path
 * This method calls <code>initWithLayout:fileName:append:</code>, with the values:aLayout, aName, and YES 
 * respectively.
 * @param aLayout The layout object you want this appender to have.
 * @param aName The file path of the initial file you want created.  Backup files have the same name, but with the 
 *        backup file number appended to it (See the <code>rollOver</code> method). 
 * @return An initialized instance of this class.
 */
- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName;

/**
 * This method initialized a new instance of this class with the specified layout, file path, and append option
 * This is the class's designated initializer.
 * @param aLayout The layout object you want this appender to have.
 * @param aName The file path of the initial file you want created.  Backup files have the same name, but with the 
 *        backup file number appended to it (See the <code>rollOver</code> method).
 * @param flag YES = log output should be appended to the file.  NO = the file's previous contents should be 
 *        overwritten.
 * @return An initialized instance of this class
 */
- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName append:(BOOL) flag;

/**
 * Explicitly rolls a file over.
 * If maxBackupIndex is positive, then files {File.1, ..., File.MaxBackupIndex -1} are renamed to {
 * File.2, ..., File.MaxBackupIndex}. 
 * Moreover, File is renamed File.1 and closed. A new file is created to receive further log output.
 * If maxBackupIndex is equal to zero, then the File is truncated with no backup files created.
 */
- (void)rollOver;

@end

/**
 *These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4RollingFileAppender (ProtectedMethods)

/**
 * This method overrides the implementation in L4WriterAppender.  It checks if the maximum file size has been exceeded.  
 * If so, it rolls the file over according to the maxBackupIndex setting.
 * @param event An L4LoggingEvent that contains logging specific information
 */
- (void)subAppend:(L4LogEvent*)event;

@end
// For copyright & license, see LICENSE.
