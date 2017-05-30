#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Level, L4Logger;

/**
 * An event to be logged.  This class embodies all of the information needed to generate a log message to an appender.
 */
@interface L4LogEvent : NSObject

@property (readonly) L4Logger *     logger;     /**< The logger this event should use.*/
@property (readonly) L4Level *      level;      /**< The level of this event.*/

@property (readonly) NSNumber *     lineNumber; /**< The line number where the event was generated.*/
@property (readonly) NSString *     fileName;   /**< The name of the file where the event was generated.*/
@property (readonly) NSString *     methodName; /**< The name of the method where the event was generated.*/

@property (readonly) NSDate *       timestamp;  /**< The timestamp for when this event was generated.*/
@property (readonly) long           millisSinceStart; /**< Accessor for the millisSinceStart attribute.*/

@property (readonly) NSException *  exception;  /**< Any exception that was logged as part of this event.*/
@property (readonly) id             message;    /**< The message of this event.*/
@property (readonly) NSString *     renderedMessage; /**< The string version of message. */

/**
 * Set up the class for use. To do this we simply get the time the app was started; this value
 * is not exact; it is the time this class is initialized.  Should be fine.
 */
+ (void) initialize;

/**
 * The time the class was initialized; used to determine how long an event 
 * occured into the appliction run.
 * @return the start time of the application.
 */
+ (NSDate *) startTime;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aMessage the message to be logged.
 * @return the new logging event.
 */
+ (instancetype)logger:(L4Logger *) aLogger
                 level:(L4Level *) aLevel
               message:(id) aMessage;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @return the new logging event.
 */
+ (instancetype)logger:(L4Logger *) aLogger
                 level:(L4Level *) aLevel
               message:(id) aMessage
             exception:(NSException *) e;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aLineNumber the line number in the file where this event was generated.
 * @param aFileName the name of the file where this event was generated.
 * @param aMethodName the name of the method where this event was generated.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @return the new logging event.
 */
+ (instancetype)logger:(L4Logger *) aLogger
                 level:(L4Level *) aLevel
            lineNumber:(int) aLineNumber
              fileName:(const char *) aFileName
            methodName:(const char *) aMethodName
               message:(id) aMessage
             exception:(NSException *) e;

/**
 * Creates a logging event with the given parameters.
 * @param aLogger the logger this event should use.
 * @param aLevel the level of this log event.
 * @param aLineNumber the line number in the file where this event was generated.
 * @param aFileName the name of the file where this event was generated.
 * @param aMethodName the name of the method where this event was generated.
 * @param aMessage the message to be logged.
 * @param e an exception to go along with this log event.
 * @param aDate the time stamp for when this event was generated.
 * @return the new logging event.
 */
- (id)initWithLogger:(L4Logger *) aLogger
               level:(L4Level *) aLevel
          lineNumber:(int) aLineNumber
            fileName:(const char *) aFileName
          methodName:(const char *) aMethodName
             message:(id) aMessage
           exception:(NSException *) e
      eventTimestamp:(NSDate *) aDate;

@end
// For copyright & license, see LICENSE.
