/**
 * For copyright & license, see LICENSE.
 */

#import "L4DenyAllFilter.h"


@implementation L4DenyAllFilter

- (L4FilterResult) decide:(L4LogEvent *) event
{
    return L4FilterDeny;
}

@end
