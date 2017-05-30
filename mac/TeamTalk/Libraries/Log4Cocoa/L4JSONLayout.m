/**
 * For copyright & license, see LICENSE.
 */

#import "L4JSONLayout.h"
#import "L4LogEvent.h"
#import "L4Properties.h"
#import "L4Logger.h"

@implementation L4JSONLayout

+ (instancetype)JSONLayout
{
    return [[L4JSONLayout alloc] init];
}

- (NSString *)format:(L4LogEvent *)event
{
    /*
     {
          "logger": "%@"
          "level": "%@"
          "time": "%ldms"
          "file": "%@:%@"
          "method": "%@"
          "message": "%@"
     }
     */
    return [NSString stringWithFormat:
            @"{\n"
            "t\"logger\":\"%@\",\n"
            "\t\"level\":\"%@\",\n"
            "\t\"time\":\"%ldms\",\n"
            "\t\"file\":\"%@:%@\",\n"
            "\t\"method\":\"%@\",\n"
            "\t\"message\":\"%@\"\n"
            "}\n",
            event.logger.name,
            event.level.stringValue,
            event.millisSinceStart,
            event.fileName,
            event.lineNumber.stringValue,
            event.methodName,
            event.renderedMessage];
}

- (NSString *)contentType {
    return @"application/json";
}


@end
