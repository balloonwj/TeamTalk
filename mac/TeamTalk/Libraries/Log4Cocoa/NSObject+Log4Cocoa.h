// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
@class L4Logger;

/**
 * Convience methods for all NSObject classes.
 * This catagory provedes methods to obtain an L4Logger instance from all classes and instances.
 * You may want to override these methods in your local base class and provide caching local iVar,
 * since these methods result in an NSDictionary lookup each time they are called.  Actually it's 
 * not a bad hit, but in a high volume logging environment, it might make a difference.
 *
 * Here is an example of what that might look like:
 * 
 * <em>CODE TO ADD TO YOUR BASE CLASS .h file declarations</em>
 * \code
 * L4Logger *myLoggerIVar; // instance variable
 * \endcode
 * 
 * <em>CODE TO ADD TO YOUR BASE CLASS .m file</em>
 * \code
 * static L4Logger *myLoggerClassVar; // static "class" variable
 * 
 * + (L4Logger *) log 
 * {
 * if( myLoggerClassVar == nil ) {
 *    myLoggerClassVar = [super l4Logger];  
 * }
 * 
 * return myLoggerClassVar;
 * }
 * 
 * - (L4Logger *) log
 * {
 * if( myLoggerIVar == nil ) {
 *    myLoggerIVar = [super l4Logger];  
 * }
 * 
 vreturn myLoggerIVar;
 * }
 * \endcode
 */
@interface NSObject (Log4Cocoa)

/**
 * Accessor for the L4Logger instance to be used from within class methods.
 */
+ (L4Logger *)l4Logger;

/**
 * Accessor for the L4Logger instance to be used from within instance methods.
 * The default implementation returns the L4Logger for the class.
 */
- (L4Logger *)l4Logger;
@end
