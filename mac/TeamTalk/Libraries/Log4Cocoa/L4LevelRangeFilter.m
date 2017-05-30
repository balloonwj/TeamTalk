/**
 * For copyright & license, see LICENSE.
 */

#import "L4LevelRangeFilter.h"
#import "L4LogEvent.h"
#import "L4Level.h"
#import "L4LogLog.h"
#import "L4Properties.h"

@implementation L4LevelRangeFilter
- (id) initWithAcceptOnMatch:(BOOL)shouldAccept fromLevel:(L4Level *)minimumLevel toLevel:(L4Level *)maximumLevel
{
    self = [super init];
    if (self != nil) {
        acceptOnMatch = shouldAccept;
        minimumLevelToMatch = minimumLevel;
        maximumLevelToMatch = maximumLevel;
    }
    return self;
}

- (id) initWithProperties:(L4Properties *) initProperties
{
    self = [super initWithProperties:initProperties];
    if(self != nil) {
        NSString *acceptIfMatched = [initProperties stringForKey:@"AcceptOnMatch"];
        acceptOnMatch = YES;
        if (acceptIfMatched) {
            acceptOnMatch = [acceptIfMatched boolValue];
        }
        
        NSString *levelMinName = [initProperties stringForKey:@"MinimumLevel"];
        if (levelMinName != nil) {
            minimumLevelToMatch = [L4Level levelWithName:levelMinName];
        }
        
        NSString *levelMaxName = [initProperties stringForKey:@"MaximumLevel"];
        if (levelMaxName != nil) {
            maximumLevelToMatch = [L4Level levelWithName:levelMaxName];
        }
    }
    return self;
}


- (BOOL) acceptOnMatch
{
    return acceptOnMatch;
}

- (L4Level *) minimumLevelToMatch
{
    return minimumLevelToMatch;
}

- (L4Level *) maximumLevelToMatch
{
    return maximumLevelToMatch;
}

- (L4FilterResult) decide:(L4LogEvent *) logEvent
{
    L4FilterResult shouldAccept = L4FilterNeutral;
    BOOL matches = NO;
    if (minimumLevelToMatch == nil || ([[logEvent level] isGreaterOrEqual:minimumLevelToMatch] == YES)) {
        if (maximumLevelToMatch == nil || [[logEvent level] intValue] <= [maximumLevelToMatch intValue]) {
            matches = YES;
        } else {
            matches = NO;
        }
    }
    if (matches) {
        shouldAccept = (acceptOnMatch == YES) ? L4FilterAccept :L4FilterDeny;
    }
    
    return shouldAccept;
}

@end
