#import <Foundation/Foundation.h>
#import "L4Filter.h"

@class L4Level;

/*
 * This is a very simple filter based on level matching, which can be used to
 * reject messages with priorities outside a certain range.
 * 
 * The filter admits three properties LevelMin, LevelMax and AcceptOnMatch.
 * 
 * If the level of the L4LoggingEvent is not between Min and Max (inclusive),
 * then L4FilterNeutral is returned.
 * 
 * If the L4LoggingEvent level is within the specified range, then if
 * AcceptOnMatch is true, L4FilterAccept is returned, and if AcceptOnMatch is
 * false, L4FilterDeny is returned.
 * 
 * If LevelMin is not defined, then there is no minimum acceptable level
 * (i.e. a level is never rejected for being too "low"/unimportant). 
 * If LevelMax is not defined, then there is no maximum acceptable level
 * (i.e. a level is never rejected for beeing too "high"/important). 
 */

@interface L4LevelRangeFilter : L4Filter {
    BOOL acceptOnMatch; /**< YES to allow logging on a match, NO to prevent logging on a match.*/
    L4Level *minimumLevelToMatch; /**< the minimum L4Level to match.*/
    L4Level *maximumLevelToMatch; /**< the minimum L4Level to match.*/
}

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>AcceptOnMatch:</c> a string that get's converted to a BOOL. YES/NO work well. See the documentation for [NSString 
 *        boolValue] for other options.
 * - <c>MinimumLevel:</c> the name of the minimum L4Level to match. See L4Level#levelWithName: for options.
 * - <c>MaximumLevel:</c> the name of the maximum L4Level to match. See L4Level#levelWithName: for options.
 *
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Initialze a new instance with the given values.
 * This is the default initializer, as the instance should have these two values set.
 *
 * @param shouldAccept YES to allow logging on a match of levelToMatch, NO to prevent logging on a match.
 *    @param minimumLevel: the name of the minimum L4Level to match. See L4Level#levelWithName: for options.
 *  @param maximumLevel: the name of the maximum L4Level to match. See L4Level#levelWithName: for options.
 */
- (id) initWithAcceptOnMatch:(BOOL)shouldAccept fromLevel:(L4Level *)minimumLevel toLevel:(L4Level *)maximumLevel;

/**
 * Accessor for the acceptOnMatch property. 
 */
- (BOOL) acceptOnMatch;

/**
 * Accessor for the minimumLevelToMatch property. 
 */
- (L4Level *) minimumLevelToMatch;

/**
 * Accessor for the maximumLevelToMatch property. 
 */
- (L4Level *) maximumLevelToMatch;

@end
// For copyright & license, see LICENSE.
