/**
 * For copyright & license, see LICENSE.
 */

#import "NSObject+Log4Cocoa.h"
#import "L4Logger.h"


@implementation NSObject (Log4Cocoa)

+ (L4Logger *)l4Logger
{
    return [L4Logger loggerForClass:(Class) self];
}

- (L4Logger *)l4Logger
{
    return [L4Logger loggerForClass:[self class]];
}

@end
