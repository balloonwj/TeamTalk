#import <Foundation/Foundation.h>
#import "L4Filter.h"

/**
 *
 * This filter drops all logging events. 
 * 
 * You can add this filter to the end of a filter chain to switch from the default "accept all unless instructed
 * otherwise" filtering behaviour to a "deny all unless instructed otherwise" behaviour. 
*/
@interface L4DenyAllFilter : L4Filter

@end
// For copyright & license, see LICENSE.
