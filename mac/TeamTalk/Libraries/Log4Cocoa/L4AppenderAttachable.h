// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

extern NSString * const kL4AppenderAddedEvent;
extern NSString * const kL4AppenderRemovedEvent;

/**
 * This (poorly named) class servers as the basis for the L4AppenderAttachable protocol.
 */
@interface L4AppenderAttachable : NSObject <L4AppenderAttachable>
/**
 * Appends event to appenders.
 * This message sends a doAppend: message to every appender in the appnderList attribute.
 * @param event the event to be appended.
 * @return the number of appenders the event was appended to.
 */
- (NSUInteger)appendLoopOnAppenders:(L4LogEvent *)event;

@end

