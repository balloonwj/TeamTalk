/**
 * For copyright & license, see LICENSE.
 */

#import "L4SimpleLayout.h"
#import "L4LogEvent.h"
#import "L4Level.h"

@implementation L4SimpleLayout

- (NSString *)format:(L4LogEvent *)event
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
    NSString *timestamp = [df stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            timestamp,
            event.level.stringValue,
            event.renderedMessage];
    
    /*return [NSString stringWithFormat:@"%@ - %ldms (%@:%@) %@ - %@",
            event.level.stringValue,
            event.millisSinceStart,
            event.fileName,
            event.lineNumber,
            event.methodName,
            event.renderedMessage];*/
}

@end
