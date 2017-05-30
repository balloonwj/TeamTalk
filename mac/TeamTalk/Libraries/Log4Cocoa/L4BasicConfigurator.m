/**
 * For copyright & license, see LICENSE.
 */

#import "L4BasicConfigurator.h"
#import "L4Properties.h"

@implementation L4BasicConfigurator

+ (L4BasicConfigurator *)basicConfigurator
{
    return [[L4BasicConfigurator alloc] init];
}

- (id) init
{
    self = [super initWithFileName:@""];

    if (self) {
        [properties setString:@"DEBUG, STDOUT" forKey:@"rootLogger"];
        [properties setString:@"L4ConsoleAppender" forKey:@"appender.STDOUT"];
        [properties setString:@"L4SimpleLayout" forKey:@"appender.STDOUT.layout"];
    }

    return self;
}

@end
