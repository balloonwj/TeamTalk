#import <Foundation/Foundation.h>
#import "L4Filter.h"

@class L4Level, L4Properties;

/**
 * This is a very simple filter based on level matching.
 *
 * The filter admits two properties LevelToMatch and AcceptOnMatch. 
 *
 * If there is an exact match between the value of the LevelToMatch option and the level of the L4LoggingEvent, then the
 * decide: method returns L4FilterAccept in case the AcceptOnMatch option value is set to YES/TRUE, if
 * it is NO/FALSE then L4FilterDeny is returned. If there is no match, L4FilterNeutral is returned. 
 *
 * If levelToMatch is set to ALL, then any L4LoggingEvent is a match.
 */
@interface L4LevelMatchFilter : L4Filter

@property (nonatomic) BOOL acceptOnMatch;   /**< YES to allow logging on a match of levelToMatch, NO to prevent logging on a match. */
@property (nonatomic, weak) L4Level * levelToMatch; /**<  The level to test against. */

/**
 * Initializes an instance from properties.  The properties supported are:
 *    - <c>AcceptOnMatch:</c> a string that get's converted to a BOOL. YES/NO work well. See the documentation for [NSString 
 *        boolValue] for other options.
 *    - <c>LevelToMatch:</c> the name of the L4Level to match. See L4Level#levelWithName: for options.
 *
 * @param initProperties the proterties to use.
 * @throw L4PropertyMissingException if the LevelToMatch property is missing.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Initialze a new instance with the given values.
 * This is the default initializer, as the instance should have these two values set.
 *
 * @param shouldAccept YES to allow logging on a match of levelToMatch, NO to prevent logging on a match.
 * @param aLevel The level to test against.  Not allowed to be nil.
 * @throw NSInvalidArgumentException if aLevel is nil.
 */
- (id) initWithAcceptOnMatch:(BOOL)shouldAccept andLevelToMatch:(L4Level *)aLevel;



@end
// For copyright & license, see LICENSE.
