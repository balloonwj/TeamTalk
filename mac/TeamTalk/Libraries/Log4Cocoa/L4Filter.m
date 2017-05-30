/**
 * For copyright & license, see LICENSE.
 */

#import "L4Filter.h"
#import "L4LogEvent.h"


@implementation L4Filter

- (id)initWithProperties:(L4Properties *)initProperties
{
    return [super init];
}


- (L4FilterResult)decide:(L4LogEvent *)event
{
    return L4FilterNeutral;
}

@end
