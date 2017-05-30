#import <Foundation/Foundation.h>

@class L4Logger, L4Level, L4RendererMap;

/**
 * A factory to be used to instantiate L4Logging classes.
 */
@protocol L4LoggerFactory

/**
 * Creates a new logger with the given name.
 * @param aName the name to use for the new logger.
 * @return the newly created logger.
 */
- (L4Logger *)newLoggerInstance:(NSString *)aName;

@end

/**
 * A repository for logger instances in the framework.
 */
@protocol L4LoggerRepository <NSObject>

@property L4Level *threshold; /**< The minimum level to log.*/

/**
 * Is the repository disabled for a given level? The answer depends on the repository threshold and the 
 * <code>level</code> parameter.
 */
- (BOOL) isDisabled:(int) aLevel;

/**
 * Mutator for the threshold property.
 * @param aLevelName the  name of a L4LEvel to use as the new threshold level.
 */
- (void) setThresholdByName:(NSString *)aLevelName;

/**
 * Accessor for the root logger.
 * @returns the root logger for the system.
 */
- (L4Logger *)rootLogger;

/**
 * Returns the logger for a particular class.
 * @param aClass the class who's logger is being requested.
 * @return the logger for the given class, creating it if need be.
 */
- (L4Logger *)loggerForClass:(Class) aClass;

/**
 * Returns the logger for a particular class.
 * @param aName the classes name for the logger being requested.
 * @return the logger for the given class, creating it if need be.
 */
- (L4Logger *)loggerForName:(NSString *)aName;

/**
 * Returns the logger for a particular class.
 * @param aName the classes name for the logger being requested.
 * @param aFactory the factory to use to create the logger if it does not already exist.
 * @return the logger for the given class, creating it if need be.
 */
- (L4Logger *)loggerForName:(NSString *)aName factory:(id <L4LoggerFactory>) aFactory;

/**
 * Returns the collection of all loggers.
 * @return the loggers configured in the system.
 */
- (NSArray *)currentLoggers;

/**
 * Tells the logging system not to emi warning messages when an appender does not exist.
 * @param aLogger the logger to ignore.
 */
- (void) emitNoAppenderWarning:(L4Logger *)aLogger;

/**
 * Resets the configuration of the logging system.
 */
- (void) resetConfiguration;

/**
 * Shuts down the logging system.
 */
- (void) shutdown;

@end

// For copyright & license, see LICENSE.
