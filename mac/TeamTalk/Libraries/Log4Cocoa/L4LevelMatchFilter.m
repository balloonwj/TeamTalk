/**
 * For copyright & license, see LICENSE.
 */
#import "L4LevelMatchFilter.h"
#import "L4LogEvent.h"
#import "L4Level.h"
#import "L4Properties.h"

@implementation L4LevelMatchFilter

- (id) initWithAcceptOnMatch:(BOOL)shouldAccept andLevelToMatch:(L4Level *)aLevel
{
    self = [super init];
    if (self) {
        self.acceptOnMatch = shouldAccept;
        if (aLevel == nil) {
            self = nil;
            [NSException raise:NSInvalidArgumentException format:@"aLevel is not allowed to be nil."];
        } else {
            self.levelToMatch = aLevel;
        }
    }
    return self;
}

- (id) initWithProperties:(L4Properties *)initProperties
{
    self = [super initWithProperties:initProperties];
    if (self) {
        NSString *acceptIfMatched = [initProperties stringForKey:@"AcceptOnMatch"];
        self.acceptOnMatch = acceptIfMatched ? [acceptIfMatched boolValue] : YES;
        
        NSString *levelName = [initProperties stringForKey:@"LevelToMatch"];
        
        if (levelName) {
            // Returns nil if no level with specified name is found
            self.levelToMatch = [L4Level levelWithName:levelName];
            
            if (!self.levelToMatch) {
                [NSException raise:L4PropertyMissingException 
                            format:@"L4Level name [%@] not found.", levelName];
            }
        } else {
            [NSException raise:L4PropertyMissingException 
                        format:@"LevelToMatch is a required property."];
        }
    }
    return self;
}


- (L4FilterResult) decide:(L4LogEvent *)event 
{
    // Default stance.
    L4FilterResult action = L4FilterNeutral;
    if (event.level.intValue == self.levelToMatch.intValue || self.levelToMatch.intValue == [L4Level all].intValue){
        action =  self.acceptOnMatch ? L4FilterAccept : L4FilterDeny;
    }
    
    return action;
}

@end
