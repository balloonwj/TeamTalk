// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>

// ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF

#define   OFF_INT  99
#define FATAL_INT  60
#define ERROR_INT  50
#define  WARN_INT  40
#define  INFO_INT  30
#define DEBUG_INT  20
#define TRACE_INT  10
#define   ALL_INT  0

@interface L4Level : NSObject

/**
 * The int value of this log level.
 */
@property (readonly) int intValue;

/**
 * The name of this level.
 */
@property (readonly) NSString * name;

/**
 * The int equivelent for syslog.
 */
@property (readonly) int syslogEquivalent;

/**
 * Creates and returns an instance with the provided values.
 * @param aLevel the level for this instance.
 * @param aName the neame for this level.
 * @param sysLogLevel the system log level for this instance.
 * @return the new instance.
 */
+ (L4Level *)level:(int)aLevel withName:(NSString *)aName syslogEquivalent:(int)sysLogLevel;

/**
 * Accessor for the default instance with a level of off.
 * @return the off instance.
 */
+ (L4Level *)off;

/**
 * Accessor for the default instance with a level of fatal.
 * @return the fatal instance.
 */
+ (L4Level *)fatal;

/**
 * Accessor for the default instance with a level of error.
 * @return the error instance.
 */
+ (L4Level *)error;

/**
 * Accessor for the default instance with a level of warn.
 * @return the warn instance.
 */
+ (L4Level *)warn;

/**
 * Accessor for the default instance with a level of info.
 * @return the info instance.
 */
+ (L4Level *)info;

/**
 * Accessor for the default instance with a level of debug.
 * @return debug off instance.
 */
+ (L4Level *)debug;

/**
 * Accessor for the default instance with a level of trace.
 * @return trace off instance.
 */
+ (L4Level *)trace;

/**
 * Accessor for the default instance with a level of all.
 * @return the all instance.
 */
+ (L4Level *)all;

/**
 * Create and return a new instance where the level is set to the string argument.
 * @param aLevel the name of the level requested.  The options are:
 *    - ALL 
 *    - DEBUG 
 *    - INFO 
 *    - WARN 
 *    - ERROR 
 *    - FATAL 
 *    - OFF 
 * @return the new L4Level.
 */
+ (L4Level *)levelWithName:(NSString *)aLevel;

/**
 * Create and return a new instance where the level is set to the string argument.  If no level matches the
 * argument, the defaultLevel is rturned.
 * @param aLevel the name of the level requested.  The options are:
 *    - ALL 
 *    - DEBUG 
 *    - INFO 
 *    - WARN 
 *    - ERROR 
 *    - FATAL 
 *    - OFF 
 * @param defaultLevel the level to use if aLevel can not be dereferenced.
 * @return the new L4Level. 
 */
+ (L4Level *)levelWithName:(NSString *)aLevel defaultLevel:(L4Level *)defaultLevel;

/**
 * Create and return a new instance where the level is set to the int argument.
 * @param aLevel the int specifier of the level requested.
 * @return the new L4Level.
 */
+ (L4Level *)levelWithInt:(int)aLevel;

/**
 * Create and return a new instance where the level is set to the int argument.  If no level matches the
 * argument, the defaultLevel is rturned.
 * @param aLevel the int specifier of the level requested.
 * @param defaultLevel the level to use if aLevel can not be dereferenced.
 * @return the new L4Level. 
 */
+ (L4Level *)levelWithInt:(int)aLevel defaultLevel:(L4Level *)defaultLevel;

/**
 * Initializes a new instance with the parameters supplied.
 * @param aLevel
 * @param aName
 * @param sysLogLevel
 * @return the newly initialized instance.
 */
- (id)initLevel:(int)aLevel withName:(NSString *)aName syslogEquivalent:(int)sysLogLevel;

/**
 * Used to access a textual representation of this level.
 * @return the string describing this instance.
 */
- (NSString *)description;

/**
 * Used to access a string representation of this level.
 * @return the string describing this instance.
 */
- (NSString *)stringValue;

/**
 * Used to determine if this instance is of greator or equal level to the argument.
 * @return YES if this instance is of at least equal level to he argument; NO if it is not.
 */
- (BOOL)isGreaterOrEqual:(L4Level *)aLevel;

/**
 * Used to determine if this instance is to be logged based on the level of the parameter.
 * @param aLevel the level that is the minimum to be logged.
 * @return YES if this level should be logged; we must be greater than the parameter to be true; NO
 *    if we ar eless.
 */
- (BOOL)isEnabledFor:(L4Level *)aLevel;

@end
