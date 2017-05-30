#import <Foundation/Foundation.h>
#import "L4Logger.h"

@class L4Level;

/**
 * This class serves as the root of the logging infrastructure; the logger that is typically
 * the first created when the logging system is initialized.
 */
@interface L4RootLogger : L4Logger

/**
 * Initialize the new instace with a specified level.
 * @param aLevel the level to use at start.
 */
- (id)initWithLevel:(L4Level *)aLevel;

/**
 * Access the level of this logger.
 * @return the current level for this logger.
 */
- (L4Level *)effectiveLevel;

@end
// For copyright & license, see LICENSE.
