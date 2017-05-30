#import <Foundation/Foundation.h>
#import "L4Filter.h"


/*
 * This is a very simple filter based on string matching.
 *
 * The filter admits two options StringToMatch and AcceptOnMatch. 
 *
 * If there is a match between the value of the StringToMatch option and the message of the L4LoggingEvent, then the
 * decide(L4LoggingEvent) method returns L4FilterAccept if the AcceptOnMatch option value is YES/TRUE, if it is 
 * NO/FALSE, then L4FilterDeny is returned. If there is no match, L4FilterNeutral is returned. 
 */
@interface L4StringMatchFilter : L4Filter {
    BOOL acceptOnMatch;     /**< YES to allow logging on a match, NO to prevent logging on a match. */
    NSString *stringToMatch; /**< The string that the logging events message must contain to match this filter. */
}

/**
 * Initializes an instance from properties.  The properties supported are:
 *    - <c>AcceptOnMatch:</c> a string that get's converted to a BOOL. YES/NO work well. See the documentation for [NSString 
 *        boolValue] for other options.
 *    - <c>StringToMatch:</c> the string that the logging events message must contain to match this filter.
 *
 * @param initProperties the proterties to use.
 * @throw L4PropertyMissingException if the StringToMatch property is missing.
 */
- (id) initWithProperties:(L4Properties *)initProperties;

/**
 * Initialze a new instance with the given values.
 * This is the default initializer, as the instance should have these two values set.
 *
 * @param shouldAccept YES to allow logging on a match of levelToMatch, NO to prevent logging on a match.
 * @param aString the string that the logging events message must contain to match this filter.
 * @throw NSInvalidArgumentException if aString is nil.
 */
- (id) initWithAcceptOnMatch:(BOOL)shouldAccept stringToMatch:(NSString *)aString;


/**
 * Accessor for the acceptOnMatch property. 
 */
- (BOOL) acceptOnMatch;

/**
 * Accessor for the stringToMatch property. 
 */
- (NSString *) stringToMatch;

@end
// For copyright & license, see LICENSE.
