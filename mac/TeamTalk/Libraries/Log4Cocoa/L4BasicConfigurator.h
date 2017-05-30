#import <Foundation/Foundation.h>
#import "L4PropertyConfigurator.h"

/**
 * Use this class to quickly configure the package. For file based 
 * configuration see L4PropertyConfigurator.
 */
@interface L4BasicConfigurator : L4PropertyConfigurator

/**
 * Factory method to return an instance of the default, basic configurator.
 */
+ (L4BasicConfigurator *) basicConfigurator;

@end
