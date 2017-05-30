// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4Filter, L4Level, L4LogEvent, L4Properties;

/**
 * This class acts as a superclass for classes that want to log. It is not intended
 * to be instantiated, but as Objective C does not have the concept of abstract classes,
 * and as protocols can't have implementations, this class simply impliments some
 * standard, generic logging behaviour.
 */
@interface L4AppenderSkeleton : NSObject <L4Appender> {
    L4Filter        * _headFilter;  /**< The first filter used by this appender.*/
    L4Filter __weak * _tailFilter;  /**< The last filter used by this appender.*/
    BOOL              _closed;      /**< Tracks if this appender has been closed.*/
}

/** Accessor for the threshold attribute that tracks the level at wich this appnded will log an event.*/
@property (nonatomic) L4Level * threshold;

/** The layout used by this appender.*/
@property (atomic, strong) L4Layout * layout;

/** The name for this appender.*/
@property (atomic, strong) NSString * name;

/**
 * Initializes an instance from properties.
 * Refer to the L4PropertyConfigurator class for more information about standard configuration properties.
 * @param initProperties the proterties to use.
 */
- (id)initWithProperties:(L4Properties *)initProperties;

/**
 * Appends an event to the log.
 * @param anEvent the event to be appended.
 */
- (void)append:(L4LogEvent *)anEvent;

/**
 * Used to determine if a given event would be logged by this appender
 * given this appensers current threshold.
 * @param aLevel the level to be tested.
 * @return YES if this appended would log, NO otherwise.
 */
- (BOOL)isAsSevereAsThreshold:(L4Level *)aLevel;

@end


