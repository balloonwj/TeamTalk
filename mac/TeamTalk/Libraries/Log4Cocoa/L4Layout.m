/**
 * For copyright & license, see LICENSE.
 */

#import "L4Layout.h"
#import "L4SimpleLayout.h"
#import "L4LogEvent.h"

@implementation L4Layout

+ (instancetype)simpleLayout
{
    return [[L4SimpleLayout alloc] init];
}

- (id)initWithProperties:(L4Properties *)initProperties
{
   return [super init];
}

- (NSString *)format:(L4LogEvent *)event
{
    return [event description];
}

- (NSString *)contentType
{
    return @"text/plain";
}

- (NSString *)header
{
    return nil;
}

- (NSString *)footer
{
    return nil;
}

- (BOOL)ignoresExceptions
{
    return YES;
}

@end
