// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
#import "L4Layout.h"

/**
 * A simple layout.
 * This class will format an event in the form:
 * "%@ - %ldms (%@:%@) %@ - %@"
 * the six substitutions are:
 * 1) the level of the event.
 * 2) the milliseconds since the app was started.
 * 3) the name of the file (implementation) the event was loggged from.
 * 4) the line number in the file the event was logged from.
 * 5) the name of the method the event was logged from.
 * 6) the message of the event, if supplied to the log message.
 */
@interface L4SimpleLayout : L4Layout


@end

