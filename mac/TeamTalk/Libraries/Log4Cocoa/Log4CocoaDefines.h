/**
 * For copyright & license, see LICENSE.
 */

#ifndef _LOG4COCOADEFINES_H
#define _LOG4COCOADEFINES_H

#import <AvailabilityMacros.h>


//
//  defs for externs
//

#ifdef __cplusplus
#define LOG4COCOA_EXTERN            extern "C"
#define LOG4COCOA_PRIVATE_EXTERN    __private_extern__
#else
#define LOG4COCOA_EXTERN            extern
#define LOG4COCOA_PRIVATE_EXTERN    __private_extern__
#endif

#endif // _LOG4COCOADEFINES_H

