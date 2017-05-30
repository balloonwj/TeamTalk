// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>

@class L4Logger, L4Filter, L4Layout, L4LogEvent, L4Properties;

/**
 * Appenders are responsible for adding a log message to log.
 * This formal protocol defines the messages a class used for appending needs to support.
 */
@protocol L4Appender <NSObject>

/**
 * Accessor for unique name attribute for this appender.
 */
@property (readwrite) NSString * name;

/**
 * Accessor for layout of this appender.
 */
@property (readwrite) L4Layout * layout;

/**
 * Returns if the appender requires layout.
 */
@property (readonly) BOOL requiresLayout;

/**
 * Initializes an instance from a collection of configuration properties.  
 * For more information on the specific appender properties, see the documentation for the particular class.
 * @param initProperties the properties to use.
 */
- (id)initWithProperties:(L4Properties *)initProperties;

/**
 * Appender log this event.
 * @param anEvent the event to append.
 */
- (void)doAppend:(L4LogEvent *)anEvent;

/**
 * Appends to the end of list.
 * @param newFilter the filter to add.
 */
- (void)appendFilter:(L4Filter *)newFilter;

/**
 * Accessor for the head filter (the first in the list).
 * @return first filter or nil if there are none.
 */
- (L4Filter *)headFilter;

/**
 * Removes all filters from list.
 */
- (void)clearFilters;

/**
 * It is a programing error to append to a close appender.
 */
- (void)close;

@end


/**
 * This protocol defines messages used to chain L4Appender instances together.  The system supports having more than one
 * logging appender, so that a single logging event can be logged in more than one place.
 */
@protocol L4AppenderAttachable <NSObject>
/**
 * Adds an appender to be logged to.
 * @param newAppender the new appender to add.
 */
- (void)addAppender:(id <L4Appender>)newAppender;

/**
 * Accessor for the collection of log appenders.
 * @return an array of al appenders.
 */
- (NSArray *)allAppenders;

/**
 * Returns the L4Appender with the given name.
 * @param aName the name of the L4Appender of interest.
 * @return the L4Appender with the name aName, or nil if it does not exist.
 */
- (id <L4Appender>)appenderWithName:(NSString *)aName;

/**
 * Returns a BOOL value that indicates whether the parameter has been attached to the appender list.
 * @param appender the L4Appender of interest.
 * @return YES if appender has been attached, NO otherwise.
 */
- (BOOL)isAttached:(id <L4Appender>)appender;

/**
 * Clears all L4Appender instances that have been attached.
 */
- (void)removeAllAppenders;

/**
 * Removes a given L4Appender from those attached.
 * @param appender the L4Appender to remove.
 */
- (void)removeAppender:(id <L4Appender>)appender;

/**
 * Removes a L4Appender with the given name from those attached.
 * @param aName the name of the L4Appender to remove.
 */
- (void)removeAppenderWithName:(NSString *)name;

@end

