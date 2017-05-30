/**
 * For copyright & license, see LICENSE.
 */
#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"
#import "L4LoggerProtocols.h"
#import "L4Level.h"

@class L4AppenderAttachable, L4Level, L4LogEvent;

/**
 * This is the primary interface into the logging framework. 
 * The functionality of the class is broken down into the following areas:
 *    <dl> 
 *  <dt><b>Base methods</b></dt>
 *    <dd> responsible for setting the level at which messages get logged.</dd>
 *  <dt> <b>AppenderRelatedMethods methods</b></dt>
 *    <dd> responsible for adding, calling, and removing L4Appender instances.</dd>
 *  <dt> <b>CoreLoggingMethods methods </b></dt>
 *    <dd> the methods that do the actual logging.</dd>
 *  <dt> <b>LogManagerCoverMethods methods </b></dt>
 *    <dd> Class methods the handle the chain of L4Logger instances, and find the correct L4Logger
 *         instance for a given class or logger name.</dd>
 *  </dl>
 */
@interface L4Logger : NSObject {
    L4AppenderAttachable *aai;  /**< What does the actual appending for this logger.*/
}

/**
 * The level of this logger. Nil means use parent's
 */
@property (strong) L4Level * level;

/**
 * The name of this logger.
 */
@property (readonly) NSString * name;

/**
 * The parent of this logger.
 */
@property (strong) L4Logger * parent;

/**
 * Flag for if log messages are additive.  If YES, logging events are set to parent loggers.
 * If NO, parents are not called.
 */
@property BOOL additivity;

/**
 * Acccessor for this loggers repository.
 */
@property (strong) id <L4LoggerRepository> repository;


/**
 * DON'T USE, only for use of log manager
 * @param loggerName the name of this logger.
 */
- (id)initWithName:(NSString *)loggerName;

/**
 * The efective level for this logger.  Events with a level below this will not be logged.
 * @return the minimum level this logger will log.
 */
- (L4Level *)effectiveLevel;

/* ********************************************************************* */
#pragma mark AppenderRelatedMethods methods
/* ********************************************************************* */
/**
 * Appends the logging event to every appender attached to this logger. If this logger is additive, the
 * message propagates up the parent chain until all of them have been called, or one is found that is
 * not addative.
 * If no appender could be found to append to, a warning is emited to that effect.
 * @param event the logging event.
 */
- (void) callAppenders:(L4LogEvent *) event;

/**
 * Accessor for the appender attached to this logger.
 */
- (L4AppenderAttachable *) aai;

/**
 * Accessor for the appenders attached to this logger. A L4AppenderAttachableImpl can have more than one
 * logger attached to it.
 */
- (NSArray *) allAppenders;

/**
 * Accessor for named appender if in list.
 * @param aName the name of the appender to find.
 * @return if found the appender.  Otherwise, nil.
 */
- (id <L4Appender>) appenderWithName:(NSString *) aName;

/**
 * Adds an appender to those attached to this logger instance.
 * @param appender the L4Appender to add.  If nil, a new L4AppenderAttachableImpl is created and added.
 */
- (void) addAppender:(id <L4Appender>) appender;
/**
 * Determines if a given L4Appender is attached to this logger instance.
 * @param appender the L4Appender of interest.
 * @return YES if it is attached, NO if it is not.
 */
- (BOOL) isAttached:(id <L4Appender>) appender;

/**
 * Closes all appenders attached to this logging instance.
 */
- (void) closeNestedAppenders;

/**
 * Removes all appenders attached to this logging instance.
 */
- (void) removeAllAppenders;

/**
 * Removes the given appender from those attached to this logging instance.
 * @param appender to be removed.
 */
- (void) removeAppender:(id <L4Appender>) appender;

/**
 * Removes the appender with the given name from those attached to this logging instance.
 * @param aName the name of the appender to be removed.
 */
- (void) removeAppenderWithName:(NSString *) aName;

/* ********************************************************************* */
#pragma mark CoreLoggingMethods methods
/* ********************************************************************* */
/* ALL < TRACE < DEBUG < INFO < WARN < ERROR < FATAL < OFF */

/**
 * Determines if a trace message should be logged.
 * @return YES if debug messages are enabled, NO if they are not.
 */
- (BOOL)isTraceEnabled;

/**
 * Determines if a debug message should be logged.
 * @return YES if debug messages are enabled, NO if they are not.
 */
- (BOOL)isDebugEnabled;

/**
 * Determines if an info message should be logged.
 * @return YES if info messages are enabled, NO if they are not.
 */
- (BOOL)isInfoEnabled;

/**
 * Determines if a warn message should be logged.
 * @return YES if warn messages are enabled, NO if they are not.
 */
- (BOOL)isWarnEnabled;

/**
 * Determines if an error message should be logged.
 * @return YES if error messages are enabled, NO if they are not.
 */
- (BOOL)isErrorEnabled;

/**
 * Determines if a fatel message should be logged.
 * @return YES if fatel messages are enabled, NO if they are not.
 */
- (BOOL)isFatalEnabled;

/**
 * Determines if aLevel should be logged.
 * @param aLevel the L4Level to be checked.
 * @return YES if logging is enabled for the level, NO if it is not.
 */
- (BOOL)isEnabledFor:(L4Level *) aLevel;

/**
 * Logs an error message in an NSAssert is false.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the assertion is.
 * @param fileName the name of the source file containing the assertion.
 * @param methodName the name of the method containing the assertion.
 * @param anAssertion the NSAssert to be tested.
 * @param aMessage the message to be logged if the assertian is false.
 */
- (void)lineNumber:(int) lineNumber
           fileName:(char *) fileName
         methodName:(char *) methodName
             assert:(BOOL) anAssertion
                log:(NSString *) aMessage;


/**
 * Logs a message with an excpetion at a level of fatal.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param lineNumber the line number in the source file where the log statement is.
 * @param fileName the name of the source file containing the log statement.
 * @param methodName the name of the method containing the log statement.
 * @param aMessage the message to be logged.
 * @param aLevel the L4Level for this log message.
 * @param e the exception to be logged.
 */
- (void)lineNumber:(int) lineNumber
           fileName:(char *) fileName
         methodName:(char *) methodName
            message:(id) aMessage
              level:(L4Level *) aLevel
          exception:(NSException *) e;

/* This is the designated logging method that the others invoke. */
/**
 * Forwards the L4LoggingEvent to all attached appenders; the other methods in this class create
 * an L4LoggingEvent and call this method.
 * <b>This is considered a framework method, and probably should not be called from outside the framework.</b>
 *
 * @param event the event to be logged.
 */
- (void) forcedLog:(L4LogEvent *) event;


#pragma mark - Logger management methods

/**
 * Accessor for the logger repository.
 * @return the logger repository.
 */
+ (id <L4LoggerRepository>)loggerRepository;

/**
 * Accessor for the root logger.
 * @return the root logger.
 */
+ (instancetype)rootLogger;

/**
 * Accesses the logger for the given class.
 * @param aClass the class we want the logger for.
 * @return the logger for the class
 */
+ (instancetype)loggerForClass:(Class) aClass;

/**
 * Accesses the logger for the given name.
 * @param aName the name of the logger we want.
 * @return the logger for the class
 */
+ (instancetype)loggerForName:(NSString *) aName;

/**
 * Accesses the logger for the given name.
 * @param aName the name of the logger we want.
 * @param aFactory the factory to use to create the logger if it does not yet exist.
 * @return the logger for the class
 */
+ (instancetype)loggerForName:(NSString *) aName factory:(id <L4LoggerFactory>) aFactory;

/**
 * The array of loggers.
 * @return the current loggers.
 */
+ (NSArray *)currentLoggers;

/**
 * Shut down logging.
 */
+ (void)shutdown;

/**
 * Reset the logging configuration.
 */
+ (void)resetConfiguration;

@end

/**
 * This class is a dummy class; its only purpose is to facilitate logging from
 * methods.  It serves as the 'self' argument.  Log level for methods can be 
 * adjusted with this, but keep in mind that it applies to all function logging.
 */
@interface L4FunctionLogger :NSObject
{
    L4FunctionLogger *instance; /**< the singleon instance of this class. */
}
/**
 * Accessor for the singleton instance.
 */
+ (L4FunctionLogger *)instance;
@end
