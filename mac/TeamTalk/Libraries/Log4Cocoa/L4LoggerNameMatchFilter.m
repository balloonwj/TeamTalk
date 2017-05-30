/**
 * For copyright & license, see LICENSE.
 */

#import "L4LoggerNameMatchFilter.h"
#import "L4LogEvent.h"
#import "L4Properties.h"
#import "L4Logger.h"

@implementation L4LoggerNameMatchFilter

- (id) initWithAcceptOnMatch:(BOOL)shouldAccept stringToMatch:(NSString *)aString
{
    self = [super init];
    if (self) {
        acceptOnMatch = shouldAccept;
        if (aString == nil || [aString length] == 0) {
            self = nil;
            [NSException raise:NSInvalidArgumentException format:@"aString is not allowed to be nil."];
        } else {
            stringToMatch = aString;
        }
    }
    return self;
}

-(id) initWithProperties: (L4Properties *) initProperties
{
    self = [super initWithProperties: initProperties];
    if (self != nil) {
        NSString *acceptIfMatched = [initProperties stringForKey:@"AcceptOnMatch"];
        acceptOnMatch = YES;
        
        if (acceptIfMatched) {
            acceptOnMatch = [acceptIfMatched boolValue];
        }
        
        stringToMatch = [initProperties stringForKey:@"StringToMatch"];    
        if (stringToMatch == nil) {
            [NSException raise:L4PropertyMissingException format: @"StringToMatch is a required property."];
        }
    }
    return self;
}


-(BOOL) acceptOnMatch
{
    return acceptOnMatch;
}

-(NSString *) stringToMatch
{
    return stringToMatch;
}

-(L4FilterResult) decide:(L4LogEvent *) logEvent
{
    L4FilterResult filterResult = L4FilterNeutral;
    if ([[logEvent logger] name] != nil && [[[logEvent logger] name] rangeOfString:stringToMatch].location != NSNotFound) {
        filterResult = (acceptOnMatch ? L4FilterAccept : L4FilterDeny);
    }
    
    return filterResult;
}

@end
