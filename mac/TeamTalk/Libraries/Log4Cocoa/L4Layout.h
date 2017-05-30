#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4LogEvent, L4SimpleLayout, L4Properties;

/**
 * This class represents formating a line of log output.
 */
@interface L4Layout : NSObject

/**
 * Create and return a simple layout.
 * This factory method is used to create a simple layout.
 * @return the new instance of L4SimpleLayout.
 */
+ (instancetype)simpleLayout;

/**
 * Initializes an instance from properties.  Currently there are no properties that apply to this class.
 * @param initProperties the proterties to use.
 */
- (id)initWithProperties:(L4Properties *) initProperties;

/**
 * Format a log event.
 * This method will format a given event based on our layout and return a string reasy for writing.
 * @param event the event to be formatted.
 * @return a string of the formatted event.
 */
- (NSString *)format:(L4LogEvent *) event;

/**
 * The MIME type of the string returned by the format:method.
 * @return the MIME type.
 */
- (NSString *)contentType;

/**
 * Any header content that should be written to the log.
 * @return the string header.
 */
- (NSString *)header;

/**
 * Any footer content that should be written to the log.
 * @return the string footer.
 */
- (NSString *)footer;

/**
 * Should this formatter format exceptions.
 * @return YES if this formatter should format an exception; NO if it should not.
 */
- (BOOL)ignoresExceptions;

@end
// For copyright & license, see LICENSE.
