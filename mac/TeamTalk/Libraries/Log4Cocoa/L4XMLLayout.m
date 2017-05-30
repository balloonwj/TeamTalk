/**
 * For copyright & license, see LICENSE
 */

#import "L4XMLLayout.h"

#import "L4LogEvent.h"
#import "L4Logger.h"

@implementation L4XMLLayout

+ (instancetype)XMLLayout
{
    return [[L4XMLLayout alloc] init];
}

- (NSString *)format:(L4LogEvent *) event
{
    NSMutableString *formattedEventString = [[NSMutableString alloc] initWithCapacity:1024];
    
    [formattedEventString appendFormat:@"<log4cocoa:event logger=\"%@\" timestamp=\"%ld\" level=\"%@\">\n", 
        event.logger.name,
        event.millisSinceStart,
        event.level.stringValue];
    
    [formattedEventString appendFormat:@"\t<log4cocoa:filename>%@:%@</log4cocoa:filename>\n", event.fileName, event.lineNumber];
    [formattedEventString appendFormat:@"\t<log4cocoa:method>%@</log4cocoa:method>\n", event.methodName];
    [formattedEventString appendFormat:@"\t<log4cocoa:message>%@</log4cocoa:message>\n", event.renderedMessage];
    
    [formattedEventString appendFormat:@"</log4cocoa:event>\n"];
    
    return formattedEventString;
}

- (NSString *)contentType {
    return @"application/xml";
}

@end
